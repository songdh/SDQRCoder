//
//  ZBarQRDecoder.h
//  schoollife
//
//  Created by 宋东昊 on 16/10/12.
//  Copyright © 2016年 北京奥特智科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBarQRDecoder : NSObject
@property (nonatomic, readonly) ZBarImageScanner *scanner;
- (NSArray*)scanImage:(CGImageRef)image;
@end
