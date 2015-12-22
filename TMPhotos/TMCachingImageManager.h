//
//  TMCachingImageManager.h
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMImageCache.h"
#import "TMAssetsCollection.h"

typedef NS_ENUM(NSInteger, TMImageContentMode)
{
    TMImageContentModeAspectFit = 0,
    TMImageContentModeAspectFill = 1,
    TMImageContentModeDefault = TMImageContentModeAspectFit
};


@interface TMCachingImageManager : NSObject

- (void)requestImageForAsset:(TMAsset * _Nonnull)asset targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode resultHandler:(void (^ _Nullable)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler;

- (void)startCachingImagesForAssets:(NSArray<TMAsset *> * _Nonnull)assets targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode;
- (void)stopCachingImagesForAssets:(NSArray<TMAsset *> * _Nonnull)assets targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode;
- (void)stopCachingImagesForAllAssets;

@end
