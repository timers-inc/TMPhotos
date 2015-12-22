//
//  TMAssetsCollection.m
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

#import "TMAssetsCollection.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation TMAssetsCollection

#pragma mark - info

+ (BOOL)isAvailablePhotosFramework {
    return NSClassFromString(@"PHPhotoLibrary") != nil;
}

#pragma mark - filtering

+ (ALAssetsFilter *)filterWithMediaType:(TMAssetMediaType)mediaType {
    ALAssetsFilter *filter = [ALAssetsFilter allAssets];
    if (mediaType==TMAssetMediaTypeImage) filter = [ALAssetsFilter allPhotos];
    if (mediaType==TMAssetMediaTypeVideo) filter = [ALAssetsFilter allVideos];
    return filter;
}

#pragma mark - resources

+ (void)fetchCollectionsWithResult:(void (^)(NSArray *, NSError *))result {
    if (self.isAvailablePhotosFramework) {
        NSMutableArray *collections = [NSMutableArray array];
        // Smart album
        PHAssetCollectionType type = PHAssetCollectionTypeSmartAlbum;
        /* camera roll */
        PHAssetCollectionSubtype subType = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subType options:nil];
        if (fetchResult.count > 0) [collections addObjectsFromArray:(NSArray *)fetchResult];
        /* favorite */
        subType = PHAssetCollectionSubtypeSmartAlbumFavorites;
        fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subType options:nil];
        if (fetchResult.count > 0) [collections addObjectsFromArray:(NSArray *)fetchResult];
        /* recently added */
        subType = PHAssetCollectionSubtypeSmartAlbumRecentlyAdded;
        fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subType options:nil];
        if (fetchResult.count > 0) [collections addObjectsFromArray:(NSArray *)fetchResult];
        // Album
        type = PHAssetCollectionTypeAlbum;
        fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:PHAssetCollectionSubtypeAny options:nil];
        if (fetchResult.count > 0) [collections addObjectsFromArray:(NSArray *)fetchResult];
        if (result) result(collections, nil);
    } else {
        // fetch groups
        NSMutableArray *groups = [NSMutableArray array];
        [self.sharedAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [groups addObject:group];
            } else {
                // finish to enumerate groups
                if (result) result(groups, nil);
            }
        } failureBlock:^(NSError *error) {
            if (result) result(nil, error);
        }];
    }
}

+ (void)fetchAssetsInCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(NSArray <TMAsset *> *assets))result {
    NSMutableArray *assets = [NSMutableArray array];
    if (self.isAvailablePhotosFramework) {
        // get assets in collection
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        [options setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:options];
        for (PHAsset *asset in fetchResult) {
            if (mediaType==TMAssetMediaTypeAll||asset.mediaType==(PHAssetMediaType)mediaType) {
                TMAsset *assetWrapper = [TMAsset assetWrapperWithAsset:asset];
                [assets addObject:assetWrapper];
            }
        }
        if (result) result(assets);
    } else {
        // get assets in group
        ALAssetsGroup *group = (ALAssetsGroup *)collection;
        [group setAssetsFilter:[self filterWithMediaType:mediaType]];
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (*stop || !asset) {
                if (result) result(assets);
            } else {
                TMAsset *assetWrapper = [TMAsset assetWrapperWithAsset:asset];
                [assets addObject:assetWrapper];
            }
        }];
    }
}

+ (void)collectionNameWithCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(NSString *, NSInteger))result {
    if (self.isAvailablePhotosFramework) {
        // get collection name and photo count
        PHCollection *__collection = (PHCollection *)collection;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
        NSInteger count = 0;
        for (PHAsset *asset in fetchResult) {
            if (mediaType==TMAssetMediaTypeAll||asset.mediaType==(PHAssetMediaType)mediaType) count++;
        }
        if (result) result(__collection.localizedTitle, count);
    } else {
        // get group name and photo count
        ALAssetsGroup *group = (ALAssetsGroup *)collection;
        [group setAssetsFilter:[self filterWithMediaType:mediaType]];
        NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
        NSInteger count = group.numberOfAssets;
        if (result) result(name, count);
    }
}

+ (void)thumbnailImageWithCollection:(id)collection mediaType:(TMAssetMediaType)mediaType result:(void (^)(UIImage *, BOOL))result {
    if (self.isAvailablePhotosFramework) {
        // get latest asset from collection
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        [options setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:options];
        PHAsset *asset = nil;
        for (PHAsset *__asset in fetchResult) {
            if (mediaType==TMAssetMediaTypeAll||__asset.mediaType==(PHAssetMediaType)mediaType) {
                asset = __asset;
                break;
            };
        }
        // fetch image
        if (!asset) {
            if (result) result(nil, NO);
        } else {
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:AssetsCollectionThumbnailImageSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *image, NSDictionary *info) {
                if (result) result(image, [info[PHImageResultIsDegradedKey] boolValue]);
            }];
        }
    } else {
        // get group's poster image
        ALAssetsGroup *group = (ALAssetsGroup *)collection;
        [group setAssetsFilter:[self filterWithMediaType:mediaType]];
        if (result) result([UIImage imageWithCGImage:group.posterImage], NO);
    }
}

#pragma mark - shared

static ALAssetsLibrary *assetsLibrary;

+ (ALAssetsLibrary *)sharedAssetsLibrary {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}

@end
