//
//  SCLScanPreviewView.h
//  SDQRCoder
//
//  Created by songdh on 16/10/10.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureVideoPreviewLayer;
@class AVCaptureSession;

@interface SCLScanPreviewView : UIView
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic, readonly) CGRect interestRect;

@property (nonatomic, copy) void (^buttonActionBlock)();

@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) UIButton *switchButton;

//扫描时的滚动条
-(void)startScroll;
-(void)stopScroll;

@end
