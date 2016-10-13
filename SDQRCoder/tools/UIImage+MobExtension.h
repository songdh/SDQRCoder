//
//  UIImage+MobExtension.h
//  project
//
//  Created by songdh on 16-4-12.
//  Copyright (c) 2016年 songdh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MobExtension)

/**
 *  调整图片大小，返回调整后的图片
 *
 *  @param newSize   新图片的尺寸
 *  @return image
 */
- (UIImage*)resizeToSize:(CGSize)newSize;

@end
