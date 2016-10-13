//
//  SDScanQRViewController.m
//  SDQRCoder
//
//  Created by songdh on 16/10/12.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "SDScanQRViewController.h"
#import "SDMyQRCodeViewController.h"
#import "SCLScanPreviewView.h"
#import "SCLScanHudView.h"
#import "ZBarSDK.h"

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface SDScanQRViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL isProcessing;//正在处理图片
}
@property (nonatomic, strong) SCLScanHudView *scanHudView;
@property (nonatomic, strong) SCLScanPreviewView *previewView;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) dispatch_queue_t metadataObjectsQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMetadataOutput *videoDeviceOutput;
@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation SDScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
    
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(onRightBarClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftBarClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _sessionQueue = dispatch_queue_create("atz.sessionQueue", DISPATCH_QUEUE_SERIAL);
    _metadataObjectsQueue = dispatch_queue_create("atz.metadataQueue", DISPATCH_QUEUE_SERIAL);
    _semaphore = dispatch_semaphore_create(0);
    
    [self setupUI];
    [self setupDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.setupResult) {
        case AVCamSetupResultSuccess:
        {
            [self addObservers];
            [self startScan];
            break;
        }
        case AVCamSetupResultCameraNotAuthorized:
        {
            NSString *message = @"请在iPhone的“设置-隐私-相机”选项中，允许黑白校园访问你的相机。";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                
                [Pub showPrivacySetting];
                
            }];
            [alertController addAction:settingsAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case AVCamSetupResultSessionConfigurationFailed:
        {
            NSString *message = @"未知错误，不能使用相机，请检查手机！";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.setupResult == AVCamSetupResultSuccess) {
        [self stopScan];
        [self removeObservers];
    }
    [super viewWillDisappear:animated];
}



#pragma mark - KVO and Notification
-(void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:self.session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStopRunning:) name:AVCaptureSessionDidStopRunningNotification object:self.session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWilEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationWilEnterForeground:(NSNotification*)notification
{
    [self addObservers];
    [self startScan];
}

-(void)sessionDidStartRunning:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewView startScroll];
        if (self.scanHudView.style == SCLScanHudWaitingStyle) {
            [self.scanHudView removeFromSuperview];
        }
    });
}

-(void)sessionDidStopRunning:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewView stopScroll];
    });
    
}

-(void)sessionRuntimeError:(NSNotification*)notification
{
    AVError errorCode = [notification.userInfo[AVCaptureSessionErrorKey] integerValue];
    if (errorCode == AVErrorMediaServicesWereReset ) {
        [self startScan];
    }
}


#pragma mark - UI
-(void)setupUI
{
    [self setupPreview];
    [self setupHudView];
}

//创建一个预览界面
-(void)setupPreview
{
    _previewView = [[SCLScanPreviewView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-NAV_BAR_HEIGHT)];
    WEAKSELF(weakSelf);
    _previewView.buttonActionBlock = ^{
        [weakSelf showMyQRCodeView];
    };
    [self.view insertSubview:_previewView atIndex:0];
}

//创建提示界面
-(void)setupHudView
{
    _scanHudView = [[SCLScanHudView alloc]initWithStyle:SCLScanHudWaitingStyle];
    _scanHudView.interestRect = _previewView.interestRect;
    _scanHudView.frame = _previewView.bounds;
    _scanHudView.titleLabel.text = @"正在加载...";
    [self.view addSubview:_scanHudView];
}

//初始化设备
-(void)setupDevice
{
    //创建采集会话，并且和预览图层进行连接
    self.session = [[AVCaptureSession alloc]init];
    self.previewView.session = self.session;
    self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //设置为当前支持的最高采集率
    NSArray *allSessionPresets = @[//AVCaptureSessionPreset3840x2160,
                                   AVCaptureSessionPreset1920x1080,
                                   AVCaptureSessionPresetiFrame1280x720,
                                   AVCaptureSessionPresetiFrame960x540,
                                   AVCaptureSessionPreset1280x720,
                                   AVCaptureSessionPreset640x480,
                                   AVCaptureSessionPreset352x288,
                                   AVCaptureSessionPresetHigh,
                                   AVCaptureSessionPresetMedium,
                                   AVCaptureSessionPresetLow,
                                   /*AVCaptureSessionPresetPhoto*/];
    for (NSString *sessionPreset in allSessionPresets) {
        if ([self.session canSetSessionPreset:sessionPreset]) {
            self.session.sessionPreset = sessionPreset;
            break;
        }
    }
    
    
    //检查采集设备权限
    [self checkAuthorizationStatus];
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

-(void)configureSession
{
    if (self.setupResult != AVCamSetupResultSuccess) {
        return;
    }
    
    [self.session beginConfiguration];
    
    //获取默认的设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (captureDevice) {
        
        //输入流
        NSError *error = nil;
        self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (error || !self.videoDeviceInput) {
            NSString *message = error.localizedDescription;
            if ([Pub isEmptyString:message]) {
                message = @"未知错误，不能使用相机，请检查手机！";
            }
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }];
                [alertController addAction:settingsAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } );
            
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }else{
   
            //添加输入流
            if ([self.session canAddInput:self.videoDeviceInput]) {
                [self.session addInput:self.videoDeviceInput];
            }
            
            //输出流，并设置代理，在子线程中执行
            self.videoDeviceOutput = [[AVCaptureMetadataOutput alloc] init];
            //添加输出流
            if ([self.session canAddOutput:self.videoDeviceOutput]) {
                [self.session addOutput:self.videoDeviceOutput];
                [self.videoDeviceOutput setMetadataObjectsDelegate:self queue:_metadataObjectsQueue];
                
                //设置输出类型，支持所有类型
                self.videoDeviceOutput.metadataObjectTypes = [self.videoDeviceOutput availableMetadataObjectTypes];
                
                //设置扫描范围.不设置，则整个屏幕都扫描
                //                  self.videoDeviceOutput.rectOfInterest = CGRectMake(0, 0, 1, 1);
            }else{
                self.setupResult = AVCamSetupResultSessionConfigurationFailed;
                [self.session commitConfiguration];
                return;
            }
            [self.session commitConfiguration];
            
        }
    }else{
        
        dispatch_async( dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"未检测到您的摄像头！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alertController addAction:settingsAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } );
        
        
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
    }
}


//检查采集设备的使用权限
-(void)checkAuthorizationStatus
{
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
}


#pragma mark - action
-(void)startScan
{
    dispatch_async(self.sessionQueue, ^{
        
        if (self.setupResult == AVCamSetupResultSuccess) {
            if (![self.session isRunning] && !isProcessing) {
                [self.session startRunning];
            }
        }
    });
}

-(void)stopScan
{
    //    dispatch_async(self.sessionQueue, ^{
    
    if (self.setupResult == AVCamSetupResultSuccess) {
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
    }
    //    });
}

-(void)onLeftBarClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)onRightBarClick:(id)sender
{
    [self showPhotoLibrary];
}

-(void)showPhotoLibrary
{
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

/**
 *  显示我的二维码界面
 *
 */
-(void)showMyQRCodeView
{
    SDMyQRCodeViewController *controller = [[SDMyQRCodeViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
/*!
 @discussion
 Delegates receive this message whenever the output captures and emits new objects, as specified by its metadataObjectTypes property. Delegates can use the provided objects in conjunction with other APIs for further processing. This method will be called on the dispatch queue specified by the output's metadataObjectsCallbackQueue property. This method may be called frequently, so it must be efficient to prevent capture performance problems, including dropped metadata objects.
 
 Clients that need to reference metadata objects outside of the scope of this method must retain them and then release them when they are finished with them.
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (AVMetadataObject *object in metadataObjects) {
            
            AVMetadataMachineReadableCodeObject *codeObj = (AVMetadataMachineReadableCodeObject *)object;
            if ([codeObj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
                NSString *QRMessage = codeObj.stringValue;
                if (![Pub isEmptyString:QRMessage]) {
                    [self stopScan];
                    
                    [self operateQRMessage:QRMessage];
                    //解锁释放线程
                    dispatch_semaphore_signal(_semaphore);
                }
            }
        }
        
    });
    
    // dispatch_semaphore_wait is used to drop new notifications if old ones are still processing, to avoid queueing up a bunch of stale data.
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
}



#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (_scanHudView.superview) {
        [_scanHudView removeFromSuperview];
    }
    _scanHudView = [[SCLScanHudView alloc]initWithStyle:SCLScanHudWaitingStyle];
    _scanHudView.interestRect = _previewView.interestRect;
    _scanHudView.frame = _previewView.bounds;
    _scanHudView.titleLabel.text = @"正在处理照片...";
    [self.view addSubview:_scanHudView];
    isProcessing = YES;
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self stopScan];
            NSString *message = [self decodeQRImage:image];
            isProcessing = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self operateQRMessage:message];
            });
        });
        
        
    }];
}

/**
 *  解析图中的二维码
 *
 *  @param image 二维码图片
 */
- (NSString *)decodeQRImage:(UIImage*)image
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    
    //如果使用系统发发不能识别图中二维码，再采用ZBar尝试一次
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features firstObject];
        return feature.messageString;
    }else {
        //采用ZBar识别
        CGImageRef cgImageRef = image.CGImage;
        
        ZBarQRDecoder *QRDecoder = [[ZBarQRDecoder alloc] init];
        NSArray *symbols = [QRDecoder scanImage:cgImageRef];
        
        for (ZBarSymbol *symbol in symbols) {
            return symbol.data;
        }
        
    }
    return nil;
}

/**
 *  处理解析后的二维码信息
 *
 *  @param QRMessage 解析后的二维码信息
 */
-(void)operateQRMessage:(NSString*)QRMessage
{
    if ([Pub isEmptyString:QRMessage]) {
        
        if (_scanHudView.superview) {
            [_scanHudView removeFromSuperview];
        }
        _scanHudView = [[SCLScanHudView alloc]initWithStyle:SCLScanHudDetailStyle];
        _scanHudView.interestRect = _previewView.interestRect;
        _scanHudView.frame = _previewView.bounds;
        _scanHudView.titleLabel.text = @"未发现二维码";
        _scanHudView.descLabel.text = @"轻触屏幕继续扫描";
        [self.view addSubview:_scanHudView];
        
        WEAKSELF(weakSelf);
        _scanHudView.tapGestureBlock = ^(){
            [weakSelf.scanHudView removeFromSuperview];
            [weakSelf startScan];
        };
        
        return;
    }else{
        if (_scanHudView.superview) {
            [_scanHudView removeFromSuperview];
        }
    }
    
    
    [self playSoundWithName:@"dingdong.caf"];
    if ([Pub isUrl:QRMessage]) {
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QRMessage] options:@{UIApplicationOpenURLOptionsSourceApplicationKey: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QRMessage]];
        }
        
    }else {
            
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:QRMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancenAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startScan];
        }];
        [alertController addAction:cancenAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

/**
 *  播放声音文件
 *
 *  @param name 文件名
 */
- (void)playSoundWithName:(NSString *)name
{
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    // 获得声音ID
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    //    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 播放音频
    AudioServicesPlaySystemSound(soundID);
}

@end
