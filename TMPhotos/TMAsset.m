//
//  TMAsset.m
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

#import "TMAsset.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation TMAsset{
    PHImageRequestID _requestID;
    PHImageRequestID _thumbnailRequestID;
}

#pragma mark - info

- (BOOL)isAvailablePhotosFramework {
    return NSClassFromString(@"PHPhotoLibrary") != nil;
}

- (NSDate *)creationDate {
    if (self.isAvailablePhotosFramework) {
        PHAsset *asset = (PHAsset *)_asset;
        return asset.creationDate;
    } else {
        ALAsset *asset = (ALAsset *)_asset;
        return [asset valueForProperty:ALAssetPropertyDate];
    }
}

- (CGSize)imageSize
{
    if (self.isAvailablePhotosFramework) {
        PHAsset *asset = (PHAsset *)_asset;
        return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    } else {
        ALAsset *asset = (ALAsset *)_asset;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        return representation.dimensions;
    }
}

#pragma mark - fetch image

- (void)requestImage:(void (^)(UIImage *, NSString *, BOOL))result {
    [self requestImage:result synchronous:NO];
}

- (void)requestImage:(void (^)(UIImage *, NSString *, BOOL))result synchronous:(BOOL)synchronous {
    if (!_asset) {
        if (result) result(nil, nil, NO);
        return;
    }
    if (self.isAvailablePhotosFramework) {
        PHAsset *asset = (PHAsset *)_asset;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setNetworkAccessAllowed:YES];
        [options setSynchronous:synchronous];
        _requestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info){
            UIImage *image = [UIImage imageWithData:imageData];
            if (result) result(image, dataUTI, [info[PHImageResultIsDegradedKey] boolValue]);
        }];
    } else {
        ALAsset *asset = (ALAsset *)_asset;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        UIImage *image = [UIImage imageWithCGImage:representation.fullScreenImage scale:representation.scale orientation:0];
        if (result) result(image, [representation.url absoluteString], NO);
    }
}

- (void)requestThumbnailImage:(void (^)(UIImage *, NSString *, BOOL))result {
    [self requestThumbnailImage:result synchronous:NO];
}

- (void)requestThumbnailImage:(void (^)(UIImage *, NSString *, BOOL))result synchronous:(BOOL)synchronous {
    if (!_asset) {
        if (result) result(nil, nil, NO);
        return;
    }
    if (self.isAvailablePhotosFramework) {
        PHAsset *asset = (PHAsset *)_asset;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setNetworkAccessAllowed:YES];
        [options setSynchronous:synchronous];
        _requestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info){
            UIImage *image = [UIImage imageWithData:imageData];
            if (result) result(image, dataUTI, [info[PHImageResultIsDegradedKey] boolValue]);
        }];
    } else {
        ALAsset *asset = (ALAsset *)_asset;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail scale:asset.defaultRepresentation.scale orientation:0];
        if (result) result(image, [representation.url absoluteString], NO);
    }
}

- (void)cancelRequestImage {
    if (self.isAvailablePhotosFramework) {
        [[PHImageManager defaultManager] cancelImageRequest:_requestID];
    }
}

- (void)cancelRequestThumbnailImage {
    if (self.isAvailablePhotosFramework) {
        [[PHImageManager defaultManager] cancelImageRequest:_thumbnailRequestID];
    }
}

#pragma mark - life cycle

+ (instancetype)assetWrapperWithAsset:(id)asset {
    return [[TMAsset alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(id)asset {
    if (self = [super init]) {
        self.asset = asset;
    }
    return self;
}

- (void)dealloc {
    self.asset = nil;
}

@end
