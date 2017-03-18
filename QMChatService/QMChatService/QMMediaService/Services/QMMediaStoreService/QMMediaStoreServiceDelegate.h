//
//  QMMediaStoreServiceDelegate.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMMediaItem;

@class  QBChatAttachment;

@protocol QMMediaStoreServiceDelegate <NSObject>

- (NSURL *)saveMediaItem:(QMMediaItem *)mediaItem;

- (void)updateMediaItem:(QMMediaItem *)mediaItem;

- (QMMediaItem *)mediaItemFromAttachment:(QBChatAttachment *)attachment;

- (void)localImageForMediaItem:(QMMediaItem *)item completion:(void(^)(UIImage *image))completion;

@end
