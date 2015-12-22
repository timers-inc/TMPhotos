//
//  TMAssetsCollection.h
//  Famm
//
//  Created by naru on 2014
//  Refactor by nori on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

@import Foundation;
@import AssetsLibrary;
@import Photos;

#import "TMAsset.h"

typedef NS_ENUM(NSInteger, TMAssetMediaType) {
    TMAssetMediaTypeAll   = 0,
    TMAssetMediaTypeImage = 1,
    TMAssetMediaTypeVideo = 2,
};

static CGSize AssetsCollectionThumbnailImageSize = (CGSize){160.0f, 160.0f};

/**
 Manager class for ALAssetsGroup and PHAssetsCollection.
 
 Collection is called 'Group' in ALAssetLibrary.
 */
@interface TMAssetsCollection : NSObject

/**
 Return the presence of the framework.
 */
+ (BOOL)isAvailablePhotosFramework;

/**
 Return photo collections of library.
 
 Fetch PHAssetCollections if Photos Framework is avalable. Otherwise, return all ALAssetGroups.
 */
+ (void)fetchCollectionsWithResult:(void (^)(NSArray *collections, NSError *error))result;

/**
 Get collection name and count.
 
 @param collection collection(group) to get name
 @param mediaType all, image, video
 @param result blocks to handle result
 */
+ (void)collectionNameWithCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(NSString *name, NSInteger photoCount))result;

/**
 Get collection latest content's thumbnail image.
 
 @param collection collection to get thumbnail image
 @param mediaType all, image, video
 @param result blocks to handle result
 */
+ (void)thumbnailImageWithCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(UIImage *image, BOOL isDegraded))result;

/**
 Fetch assets in collection.
 
 @param collection collection containing assets
 @param mediaType all, image, video
 @param result blocks to handle result
 */
+ (void)fetchAssetsInCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(NSArray <TMAsset *> *assets))result;



@end
