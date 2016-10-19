//
//  SCLScanPreviewView.m
//  SDQRCoder
//
//  Created by songdh on 16/10/10.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "SCLScanPreviewView.h"
@import AVFoundation;

@interface SCLScanPreviewView ()
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIImageView *scrollLine;
@end
@implementation SCLScanPreviewView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInt];
        [self createButtons];
    }
    return self;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.videoPreviewLayer.session = session;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    // Create the path for the mask layer. We use the even odd fill rule so that the region of interest does not have a fill color.
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:self.interestRect]];
    path.usesEvenOddFillRule = YES;
    _maskLayer.path = path.CGPath;
    
}

-(UIImageView*)scrollLine
{
    if (!_scrollLine.superview) {
        _scrollLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QR_scroll_line"]];
        _scrollLine.frame = self.interestRect;
        _scrollLine.height = 2.5f;
        [self addSubview:_scrollLine];
    }
    return _scrollLine;
}


-(void)commonInt
{
    //创建提示信息区域。并计算扫描区域大小
    [self setupTipView];
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillRule = kCAFillRuleEvenOdd;
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
    _maskLayer.opacity = 0.6f;
    [self.layer addSublayer:_maskLayer];
    
    
    CAShapeLayer *regionOfInterestOutline = [CAShapeLayer layer];
    regionOfInterestOutline.path = [UIBezierPath bezierPathWithRect:self.interestRect].CGPath;
    regionOfInterestOutline.fillColor = [UIColor clearColor].CGColor;
    regionOfInterestOutline.strokeColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:regionOfInterestOutline];
    
    CGFloat side = CGRectGetWidth(_interestRect);
    //leftTopImageView
    UIImage *angleImage = [UIImage imageNamed:@"QR_angle"];
    
    CALayer *leftTopView = [CALayer layer];
    leftTopView.contents = (__bridge id _Nullable)(angleImage.CGImage);
    leftTopView.frame = CGRectSizeMake(CGRectGetMinX(_interestRect)-2, CGRectGetMinY(_interestRect)-2, angleImage.size);
    [self.layer addSublayer:leftTopView];
    
    
    //rightTopView
    CALayer *rightTopView = [CALayer layer];
    rightTopView.contents = (__bridge id _Nullable)(angleImage.CGImage);
    [rightTopView setAffineTransform:CGAffineTransformMakeRotation(M_PI_2)];
    rightTopView.frame = CGRectOffset(leftTopView.frame, side-angleImage.size.width*2+angleImage.size.width+2*2, 0);
    [self.layer addSublayer:rightTopView];
    
    //leftBottomView
    CALayer *leftBottomView = [CALayer layer];
    leftBottomView.contents = (__bridge id _Nullable)(angleImage.CGImage);
    [leftBottomView setAffineTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    leftBottomView.frame = CGRectOffset(leftTopView.frame, 0, side-angleImage.size.height*2+angleImage.size.height+2*2);
    [self.layer addSublayer:leftBottomView];
    
    //rightBottomView
    CALayer *rightBottomView = [CALayer layer];
    rightBottomView.contents = (__bridge id _Nullable)(angleImage.CGImage);
    [rightBottomView setAffineTransform:CGAffineTransformMakeRotation(M_PI)];
    rightBottomView.frame = CGRectOffset(leftBottomView.frame, side-angleImage.size.width*2+angleImage.size.width+2*2, 0);
    [self.layer addSublayer:rightBottomView];
}

-(void)setupTipView
{
    UILabel *label = [[UILabel alloc]init];
    label.text = @"将二维码放入框内，即可自动扫描";
    label.textColor = [UIColor whiteColor];
    label.font = FontSize(14);
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    [self addSubview:label];
    
    label.midX = self.midX;
    label.minY = 15;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"我的二维码" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    button.titleLabel.font = FontSize(16);
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self addSubview:button];
    button.midX = self.midX;
    button.minY = label.maxY + 15;
    
    //计算扫描区域范围
    CGFloat side = screenWidth - 100;
    
    _interestRect= CGRectSizeMake((self.width - side)/2, (self.height-side-button.maxY)/2, CGSizeMake(side, side));
    
    //refreshOrigin
    label.minY = CGRectGetMaxY(_interestRect)+15;
    button.minY = label.maxY + 15;
}

-(void)onClick:(id)sender
{
    if (self.buttonActionBlock) {
        self.buttonActionBlock();
    }
}

-(void)createButtons
{
    _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lightButton setImage:[UIImage imageNamed:@"QR_light"] forState:UIControlStateNormal];
    [self addSubview:_lightButton];
    
    _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchButton setImage:[UIImage imageNamed:@"QR_switch"] forState:UIControlStateNormal];
    [self addSubview:_switchButton];
    
    [_lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 35));
        make.centerX.equalTo(self.mas_centerX).offset(-50);
        make.bottom.equalTo(-30);
    }];
    
    [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(40, 35));
        make.centerX.equalTo(self.mas_centerX).offset(50);
        make.bottom.equalTo(-30);
    }];
}

#pragma mark - action
-(void)startScroll
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollLine];
        [self startAnimation];
    });
}

-(void)startAnimation
{
    [UIView beginAnimations:@"moveAnimation" context:(__bridge void * _Nullable)(self.scrollLine)];
    [UIView setAnimationDuration:2.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    self.scrollLine.center = CGPointMake(CGRectGetMidX(self.interestRect), CGRectGetMaxY(self.interestRect));
    [UIView commitAnimations];
}

-(void)stopScroll
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollLine removeFromSuperview];
    });

}

@end
