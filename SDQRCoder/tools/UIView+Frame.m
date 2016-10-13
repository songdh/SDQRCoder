//
//  UIView+Frame.m
//  SDQRCoder
//
//  Created by songdh on 16/7/13.
//  Copyright © 2016年 songdh. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

-(CGFloat)cellHeight
{
    NSAssert(nil, @"updateConstraint Method is not implement");
    return 0;
}


-(void)setMinX:(CGFloat)minX
{
    CGRect frame = self.frame;
    frame.origin.x = minX;
    self.frame = frame;
}
-(CGFloat)minX
{
    return CGRectGetMinX(self.frame);
}

-(void)setMinY:(CGFloat)minY
{
    CGRect frame = self.frame;
    frame.origin.y = minY;
    self.frame = frame;
}
-(CGFloat)minY
{
    return CGRectGetMinY(self.frame);
}

-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
-(CGFloat)width
{
    return CGRectGetWidth(self.bounds);
}

-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
-(CGFloat)height
{
    return CGRectGetHeight(self.bounds);
}

-(void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
-(CGSize)size
{
    return self.frame.size;
}

-(void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}
-(CGPoint)origin
{
    return self.frame.origin;
}


-(CGFloat)maxX
{
    return CGRectGetMaxX(self.frame);
}
-(CGFloat)maxY
{
    return CGRectGetMaxY(self.frame);
}
-(CGFloat)midX
{
    return CGRectGetMidX(self.frame);
}
-(void)setMidX:(CGFloat)midX
{
    CGPoint center = self.center;
    center = CGPointMake(midX, center.y);
    self.center = center;
}
-(CGFloat)midY
{
    return CGRectGetMidY(self.frame);
}
-(void)setMidY:(CGFloat)midY
{
    CGPoint center = self.center;
    center = CGPointMake(center.x, midY);
    self.center = center;
}
@end
