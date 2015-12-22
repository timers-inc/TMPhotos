//
//  TMImageCache.m
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

#import "TMImageCache.h"

@implementation TMImageCache

static NSString *FAMImageCacheKeyFromURL(NSURL *url) {
    return [url absoluteString];
}

static TMImageCache  *sharedCache = nil;
+ (instancetype)sharedCache
{
    if (!sharedCache) {
        @synchronized(self) {
            sharedCache = [TMImageCache new];
        }
    }
    return sharedCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setImage:(UIImage *)image forPath:(NSString *)path
{
    if (image) {
        [self setObject:image forKey:path];
    }
}

- (UIImage *)imageForPath:(NSString *)path
{
    return [self objectForKey:path];
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url {
    [self setObject:image forKey:FAMImageCacheKeyFromURL(url)];
}

- (UIImage *)imageForURL:(NSURL *)url {
    return [self objectForKey:FAMImageCacheKeyFromURL(url)];
}

@end
