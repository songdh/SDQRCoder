//
//  UIView+Frame.h
//  SDQRCoder
//
//  Created by songdh on 16/7/13.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)
/**
 *  当前cell的高度
 *
 *  @return 高度
 */
-(CGFloat)cellHeight;

@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign, readonly) CGFloat maxX;
@property (nonatomic, assign, readonly) CGFloat maxY;
@property (nonatomic, assign) CGFloat midX;
@property (nonatomic, assign) CGFloat midY;

@end
