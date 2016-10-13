//
//  UIImage+MobExtension.m
//  project
//
//  Created by songdh on 16-4-12.
//  Copyright (c) 2016年 songdh. All rights reserved.
//

#import "UIImage+MobExtension.h"

#pragma mark -
@implementation UIImage (MobExtension)

- (UIImage *)resizeToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
