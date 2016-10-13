//
//  SCLScanHudView.m
//  SDQRCoder
//
//  Created by songdh on 16/10/11.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "SCLScanHudView.h"

@interface SCLScanHudView ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation SCLScanHudView

-(instancetype)initWithStyle:(SCLScanHudStyle)style
{
    if (self = [super init]) {
        _style = style;
        [self commonInit];
    }
    return self;
}

-(void)removeFromSuperview
{
    [_indicatorView stopAnimating];
    [super removeFromSuperview];
}

-(void)commonInit
{
    self.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f].CGColor;
    
    if (_style == SCLScanHudWaitingStyle) {
        
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_indicatorView];
        [_indicatorView startAnimating];
        
    }else if (_style == SCLScanHudDetailStyle) {
        _descLabel = [[UILabel alloc]init];
        _descLabel.font = FontSize(14);
        _descLabel.textColor = __HEX_RGBACOLOR(0xaaa18a,1.0f);
        _descLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_descLabel];
    }
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = FontSize(16);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onGesture:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [_titleLabel sizeToFit];
    
    if (_style == SCLScanHudWaitingStyle) {
        
        CGFloat y = (CGRectGetHeight(self.interestRect) - _indicatorView.height - _titleLabel.height - 10)/2 + CGRectGetMinY(self.interestRect);
        _indicatorView.minY = y;
        _indicatorView.midX = self.midX;
        
        _titleLabel.minY = _indicatorView.maxY+10;
        _titleLabel.midX = self.midX;
    }else if (_style == SCLScanHudDetailStyle) {
        
        [_descLabel sizeToFit];
        CGFloat y = CGRectGetMinY(self.interestRect) + (CGRectGetHeight(self.interestRect) - _titleLabel.height - _descLabel.height-5)/2;
        _titleLabel.midX = self.midX;
        _titleLabel.minY = y;
        
        _descLabel.midX = self.midX;
        _descLabel.minY = _titleLabel.maxY+5;
    }
    
}

-(void)onGesture:(UITapGestureRecognizer*)gesture
{
    if (self.tapGestureBlock) {
        self.tapGestureBlock();
    }
}

@end
