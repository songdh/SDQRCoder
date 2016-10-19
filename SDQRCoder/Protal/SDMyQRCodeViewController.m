//
//  SDMyQRCodeViewController.m
//  SDQRCoder
//
//  Created by songdh on 16/10/12.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "SDMyQRCodeViewController.h"
#import "SDMyColorQRCodeViewController.h"

@interface SDMyQRCodeViewController ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *QRCodeImageView;
@end

@implementation SDMyQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的二维码";
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
    
    if (self.navigationController.viewControllers.count <= 1) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftBarClick:)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"彩色二维码" style:UIBarButtonItemStylePlain target:self action:@selector(onRightBarClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;

    
    
    [self setupUI];
    
    [self generateQRCode];
    
    [self drawSmallIcon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onLeftBarClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)onRightBarClick:(id)sender
{
    SDMyColorQRCodeViewController *controller = [[SDMyColorQRCodeViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)setupUI
{
    //背景卡片
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 4.0f;
    [self.view addSubview:_bgView];
    
    //个人信息
    //头像
    UIImageView *avatorView = [[UIImageView alloc]init];
    avatorView.layer.borderColor = __HEX_RGBACOLOR(0xdddddd,1.0f).CGColor;
    avatorView.layer.borderWidth = 1.0f;
    avatorView.contentMode = UIViewContentModeScaleAspectFit;
    avatorView.image = [UIImage imageNamed:@"avator.jpg"];
    [_bgView addSubview:avatorView];
    
    //二维码背景
    _cardView = [[UIView alloc]init];
    _cardView.backgroundColor = __HEX_RGBACOLOR(0x00449b, 1.0f);
    [_bgView addSubview:_cardView];
    
    
    //二维码图片
    _QRCodeImageView = [[UIImageView alloc]init];
    _QRCodeImageView.backgroundColor = [UIColor yellowColor];
    [_cardView addSubview:_QRCodeImageView];
    
    //tip
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.text = @"扫一扫上面的二维码图案，关注我";
    tipLabel.font = FontSize(12);
    tipLabel.textColor = __HEX_RGBACOLOR(0xaaa18a,1.0f);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:tipLabel];
    
    //背景
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(CGRatioFloat(22));
        make.right.equalTo(-CGRatioFloat(22));
        make.center.equalTo(0);
    }];
    
    CGFloat padding = 20;
    CGFloat interval = 20;
    //userInfo
    [avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(padding);
        make.height.equalTo(50);
        make.width.equalTo(50);
        make.top.equalTo(padding);
        make.bottom.equalTo(_cardView.mas_top).offset(-interval);
    }];
    
    //cardView
    [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(padding);
        make.right.equalTo(-padding);
        make.height.equalTo(_cardView.mas_width);
        make.top.equalTo(avatorView.mas_bottom).offset(interval);
        make.bottom.equalTo(tipLabel.mas_top).offset(-interval);
    }];
    
    //tipView
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-padding);
        make.centerX.equalTo(_bgView.mas_centerX);
        make.top.equalTo(_cardView.mas_bottom).offset(interval);
    }];
    
    //个人信息
    //name
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = @"小巷深深";
    nameLabel.font = BoldFontSize(15);
    nameLabel.textColor = __HEX_RGBACOLOR(0x37342c,1.0);
    nameLabel.numberOfLines = 0;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:nameLabel];
    
    //sex
    UIImageView *sexImageView = [[UIImageView alloc]init];
    sexImageView.image = [UIImage imageNamed:@"icon_female"];
    [_bgView addSubview:sexImageView];
    
    //company
    UILabel *companyLabel = [[UILabel alloc]init];
    companyLabel.font = BoldFontSize(13);
    companyLabel.text = @"不知道叫什么名字公司";
    companyLabel.textColor = __HEX_RGBACOLOR(0x74c2f3, 1.0f);
    [_bgView addSubview:companyLabel];
    
    //name
    [nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatorView.mas_right).offset(10);
        make.bottom.equalTo(avatorView.mas_centerY).offset(-2);
        make.width.lessThanOrEqualTo(300);
    }];
    
    //sex
    [sexImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel.mas_right).offset(5);
        make.centerY.equalTo(nameLabel.mas_centerY);
    }];
    //company
    [companyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatorView.mas_right).offset(10);
        make.top.equalTo(avatorView.mas_centerY).offset(2);
        make.width.lessThanOrEqualTo(300);
    }];
    
    
    //qrimage
    [_QRCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_cardView).insets(UIEdgeInsetsMake(50, 50, 50, 50));
    }];
    
}


#pragma mark - 生成二维码
- (void)generateQRCode
{
    // Create a new filter with the given name.
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    if (!filter) return;
    
    // -setDefaults instructs the filter to configure its parameters
    // with their specified default values.
    [filter setDefaults];
    
    //二维码数据
    NSString *QRMessage = @"http://www.jianshu.com/users/3688d37243de/latest_articles";
    //    官方建议使用 NSISOLatin1StringEncoding 来编码，但经测试这种编码对中文或表情无法生成，改用 NSUTF8StringEncoding 就可以了。
    NSData *inputData = [QRMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:inputData forKey:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    
    // 输出的图片比较小，需要放大。此处放大20倍
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    UIImage *QRImage = [UIImage imageWithCIImage:outputImage];
    _QRCodeImageView.image = QRImage;
}

-(void)drawSmallIcon
{
    UIImageView *iconView = [[UIImageView alloc]init];
    iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    iconView.layer.borderWidth = 2.0f;
    [_QRCodeImageView addSubview:iconView];
    
    UIImage *avator = [UIImage imageNamed:@"avator.jpg"];
    avator = [avator resizeToSize:CGSizeMake(100, 100)];
    iconView.image = avator;
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
        make.width.equalTo(_QRCodeImageView.mas_width).multipliedBy(0.2f);
        make.height.equalTo(iconView.mas_width);
    }];
}
@end
