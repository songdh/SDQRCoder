//
//  SCLScanHudView.h
//  SDQRCoder
//
//  Created by songdh on 16/10/11.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM( NSInteger, SCLScanHudStyle ) {
    SCLScanHudWaitingStyle = 0,//等待动画和标题
    SCLScanHudDetailStyle = 1,//标题和详情两个文字框
};



@interface SCLScanHudView : UIView
//提示信息都在此区域中展示
@property (nonatomic, assign, readonly) SCLScanHudStyle style;
@property (nonatomic, assign) CGRect interestRect;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, copy) void (^tapGestureBlock)();

-(instancetype)initWithStyle:(SCLScanHudStyle)style;
@end
