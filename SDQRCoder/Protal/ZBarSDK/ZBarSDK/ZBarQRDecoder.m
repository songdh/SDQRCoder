//
//  ZBarQRDecoder.m
//  schoollife
//
//  Created by 宋东昊 on 16/10/12.
//  Copyright © 2016年 北京奥特智科技有限公司. All rights reserved.
//

#import "ZBarQRDecoder.h"
#import "debug.h"

#ifndef MIN_QUALITY
# define MIN_QUALITY 10
#endif

@interface ZBarQRDecoder ()
{
    double dt_frame;
    uint64_t t_frame;
    CGRect scanCrop;
    NSInteger maxScanDimension;
}
@end

@implementation ZBarQRDecoder

-(instancetype)init
{
    if (self = [super init]) {
        
        _scanner = [ZBarImageScanner new];
        [_scanner setSymbology:0 config:ZBAR_CFG_X_DENSITY to:2];
        [_scanner setSymbology:0 config:ZBAR_CFG_Y_DENSITY to:2];
        scanCrop = CGRectMake(0, 0, 1, 1);
        maxScanDimension = 640;
        
    }
    return self;
}

- (NSArray*)scanImage:(CGImageRef)image
{
    timer_start;
    
    NSInteger nsyms = [self scanImage:image withScaling:0];
    
    if(!nsyms && CGImageGetWidth(image) >= 640 && CGImageGetHeight(image) >= 640) {
        // make one more attempt for close up, grainy images
        nsyms = [self scanImage:image withScaling:0.5f];
    }
    
    NSMutableArray *syms = [NSMutableArray array];
    if(nsyms) {
        // quality/type filtering
        int max_quality = MIN_QUALITY;
        for(ZBarSymbol *sym in _scanner.results) {
            zbar_symbol_type_t type = sym.type;
            int quality;
            if(type == ZBAR_QRCODE)
                quality = INT_MAX;
            else
                quality = sym.quality;
            
            if(quality < max_quality) {
                zlog(@"    type=%d quality=%d < %d\n",
                     type, quality, max_quality);
                continue;
            }
            
            if(max_quality < quality) {
                max_quality = quality;
                if(syms)
                    [syms removeAllObjects];
            }
            zlog(@"    type=%d quality=%d\n", type, quality);
            if(!syms)
                syms = [NSMutableArray arrayWithCapacity: 1];
            
            [syms addObject: sym];
        }
    }
    
    zlog(@"read %d filtered symbols in %gs total\n",
         (!syms) ? 0 : [syms count], timer_elapsed(t_start, timer_now()));
    
    return [syms copy];
}


- (NSInteger)scanImage:(CGImageRef)image withScaling:(CGFloat) scale
{
    uint64_t now = timer_now();
    if(dt_frame) {
        dt_frame = (dt_frame + timer_elapsed(t_frame, now)) / 2;
    }else{
        dt_frame = timer_elapsed(t_frame, now);
    }
    t_frame = now;
    
    size_t w = CGImageGetWidth(image);
    size_t h = CGImageGetHeight(image);
    CGRect crop;
    if(w >= h) {
        crop = CGRectMake(scanCrop.origin.x * w, scanCrop.origin.y * h,
                          scanCrop.size.width * w, scanCrop.size.height * h);
    }else{
        crop = CGRectMake(scanCrop.origin.y * w, scanCrop.origin.x * h,
                          scanCrop.size.height * w, scanCrop.size.width * h);
    }
    
    CGSize size;
    if(crop.size.width >= crop.size.height && crop.size.width > maxScanDimension) {
        size = CGSizeMake(maxScanDimension,
                          crop.size.height * maxScanDimension / crop.size.width);
    }else if(crop.size.height > maxScanDimension) {
        size = CGSizeMake(crop.size.width * maxScanDimension / crop.size.height,
                          maxScanDimension);
    }else{
        size = crop.size;
    }
    
    if(scale) {
        size.width *= scale;
        size.height *= scale;
    }
    
    
    // limit the maximum number of scan passes
    int density;
    if(size.width > 720) {
        density = (size.width / 240 + 1) / 2;
    }else {
        density = 1;
    }
    
    [_scanner setSymbology:0 config:ZBAR_CFG_X_DENSITY to:density];
    
    if(size.height > 720) {
        density = (size.height / 240 + 1) / 2;
    }else{
        density = 1;
    }
    
    [_scanner setSymbology:0 config:ZBAR_CFG_Y_DENSITY to:density];
    
    
    ZBarImage *zimg = [[ZBarImage alloc]
                       initWithCGImage: image
                       crop: crop
                       size: size];
    NSInteger nsyms = [_scanner scanImage: zimg];
    return(nsyms);
}

@end
