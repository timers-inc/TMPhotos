//
//  TMAsset.h
//  Famm
//
//  Created by naru on 2014
//  Refactor by nori on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

@import Foundation;
@import AssetsLibrary;
@import Photos;

static CGSize TMAssetImageThumbnailSize = (CGSize){160.0f, 160.0f};

/**
 Wrapper class to handle assets in library for ALAsset(ALAssetsLibrary) and PHAsset(PhotoKit).
 
 - Request to fetch thumbnail or full size image.
 - Get creation date.
 - Cancel to request image (only for PHAsset).
 */
@interface TMAsset : NSObject

/**
 Wrapped asset object (ALAsset or PHAsset).
 */
@property (nonatomic, retain) id asset;

/**
 Creation date of asset.
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 A numeric identifier related to fetch image.
 */
@property (nonatomic, readonly) PHImageRequestID requestID;

/**
 Image size
 */
@property (nonatomic, readonly) CGSize imageSize;

/**
 Return An AssetWrapper object.
 
 @param asset An ALAsset or PHAsset object
 @return An AssetWrapper object
 */
+ (instancetype)assetWrapperWithAsset:(id)asset;

/**
 Fetching max size image with asset. Process is asynchoronously only for PHAsset.
 
 'image' can be nil if PHAsset failed to fetch image data.
 Return 'info' only for class of asset is PHAsset.
 You can check that fetched image is degrated or not from value info[PHImageResultIsDegradedKey].
 
 @param result blocks to handle result (UTI: Uniform Type Identifier)
 */
- (void)requestImage:(void (^)(UIImage *image, NSString *dataUTI, BOOL isDegraded))result;

/**
 Fetching max size image with asset.
 
 @param result blocks to handle result (UTI: Uniform Type Identifier)
 @param synchronous perform processing synchronously or not (only for PHAsset)
 */
- (void)requestImage:(void (^)(UIImage *image, NSString *dataUTI, BOOL isDegraded))result synchronous:(BOOL)synchronous;

/**
 Fetching thumbnail image with asset. Process is asynchoronously only for PHAsset.
 
 @param result blocks to handle result
 */
- (void)requestThumbnailImage:(void (^)(UIImage *image, NSString *dataUTI, BOOL isDegraded))result;

/**
 Fetching thumbnail image with asset.
 
 @param result blocks to handle result
 @param synchronous perform processing synchronously or not (only for PHAsset)
 */
- (void)requestThumbnailImage:(void (^)(UIImage *image, NSString *dataUTI, BOOL isDegraded))result synchronous:(BOOL)synchronous;

/**
 Cancel to fetch image. (only for PHAsset)
 */
- (void)cancelRequestImage;

/**
 Cancel to fetch thumbnail image. (only for PHAsset)
 */
- (void)cancelRequestThumbnailImage;


@end
