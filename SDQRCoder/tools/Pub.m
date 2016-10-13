//
//  Pub.m
//  project
//
//  Created by songdh on 16-2-16.
//  Copyright (c) 2016年 songdh. All rights reserved.
//

#import "Pub.h"

@implementation Pub

+ (BOOL)isEmptyString:(const NSString *)string
{
    return [string isKindOfClass:[NSString class]] && [string length] > 0 ? NO : YES;
}

//显示系统设置界面
+ (void)showPrivacySetting
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //区分ios10
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }else{
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (BOOL)isUrl:(NSString*)string
{
    NSString        *regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    NSPredicate     *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:string];
}


@end

CGRect CGRectSizeMake(CGFloat x, CGFloat y, CGSize size)
{
    CGRect rect;
    rect.origin.x = ceilf(x);
    rect.origin.y = ceilf(y);
    rect.size.width = ceilf(size.width);
    rect.size.height = ceilf(size.height);
    return rect;
}
