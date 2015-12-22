//
//  TMCachingImageManager.m
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

#import "TMCachingImageManager.h"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface TMCachingImageManager ()

@property (nonatomic) PHCachingImageManager *phImageManager;
@property (nonatomic) TMImageCache *imageCache;

@end

@implementation TMCachingImageManager

- (BOOL)isAvailablePhotosFramework {
    return NSClassFromString(@"PHPhotoLibrary") != nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self isAvailablePhotosFramework]) {
            _phImageManager = [PHCachingImageManager new];
        } else {
            _imageCache = [TMImageCache new];
            _imageCache.countLimit = 100;
        }
        
    }
    return self;
}

- (void)requestImageForAsset:(TMAsset * _Nonnull)asset targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode resultHandler:(void (^ _Nullable)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler
{
    if ([self isAvailablePhotosFramework]) {
        [_phImageManager requestImageForAsset:asset.asset targetSize:targetSize contentMode:[self imageContentMode:contentMode] options:nil resultHandler:resultHandler];
    } else {
        
        ALAsset *aasset = (ALAsset *)asset.asset;
        UIImage *image = [_imageCache imageForPath:[aasset.defaultRepresentation.url absoluteString]];
        if (image) {
            if (resultHandler) {
                resultHandler(image, nil);
            }
            return;
        }
        
        [asset requestImage:^(UIImage *image, NSString *dataUTI, BOOL isDegraded) {
            resultHandler(image, nil);
            if (image) {
                [_imageCache setImage:image forPath:dataUTI];
            }
        }];
    }
}

- (PHImageContentMode)imageContentMode:(TMImageContentMode)imageContentMode
{
    switch (imageContentMode) {
        case TMImageContentModeAspectFill: return PHImageContentModeAspectFill;
        case TMImageContentModeAspectFit: return PHImageContentModeAspectFit;
    }
}

- (NSArray <PHAsset *>*)assets:(NSArray <TMAsset *>*)assets
{
    if (assets.count == 0) {
        return @[];
    }
    NSMutableArray *_assets = @[].mutableCopy;
    [assets enumerateObjectsUsingBlock:^(TMAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_assets addObject:obj.asset];
    }];
    return _assets;
}

- (void)startCachingImagesForAssets:(NSArray<TMAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode
{
    if ([self isAvailablePhotosFramework]) {
        [_phImageManager startCachingImagesForAssets:[self assets:assets] targetSize:targetSize contentMode:[self imageContentMode:contentMode] options:nil];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (targetSize.width * targetSize.height <= (190 * 190)) {
                [assets enumerateObjectsUsingBlock:^(TMAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                    [asset requestThumbnailImage:^(UIImage *image, NSString *dataUTI, BOOL isDegraded) {
                        [_imageCache setImage:image forPath:dataUTI];
                    }];
                }];
            } else {
                [assets enumerateObjectsUsingBlock:^(TMAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
                    [asset requestImage:^(UIImage *image, NSString *dataUTI, BOOL isDegraded) {
                        [_imageCache setImage:image forPath:dataUTI];
                    }];
                }];
            }
        });
    }
}

- (void)stopCachingImagesForAssets:(NSArray<TMAsset *> *)assets targetSize:(CGSize)targetSize contentMode:(TMImageContentMode)contentMode
{
    if ([self isAvailablePhotosFramework]) {
        [_phImageManager stopCachingImagesForAssets:[self assets:assets] targetSize:targetSize contentMode:[self imageContentMode:contentMode] options:nil];
    } else {
        
    }
}

- (void)stopCachingImagesForAllAssets
{
    if ([self isAvailablePhotosFramework]) {
        [_phImageManager stopCachingImagesForAllAssets];
    } else {
        
    }
}


@end
