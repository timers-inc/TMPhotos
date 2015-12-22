//
//  TMImageCache.h
//  Famm
//
//  Created by 1amageek on 2015/10/08.
//  Copyright © 2015年 Timers. All rights reserved.
//

@import UIKit;

@interface TMImageCache : NSCache

+ (instancetype)sharedCache;

// String
- (void)setImage:(UIImage *)image forPath:(NSString *)path;
- (UIImage *)imageForPath:(NSString *)path;


// URL
- (void)setImage:(UIImage *)image forURL:(NSURL *)url;
- (UIImage *)imageForURL:(NSURL *)url;

@end
