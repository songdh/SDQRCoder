//
//  Pub.h
//  project
//
//  Created by songdh on 16-2-16.
//  Copyright (c) 2016年 sondh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pub : NSObject

//判断字符串是否为空
+ (BOOL)isEmptyString:(const NSString *)string;

//显示系统设置界面
+ (void)showPrivacySetting;

//判断字符串是否是http链接
+ (BOOL)isUrl:(NSString*)string;
@end

CGRect CGRectSizeMake(CGFloat x, CGFloat y, CGSize size);
