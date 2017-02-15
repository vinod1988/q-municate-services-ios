//
//  QMMediaService.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/8/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaServiceDelegate.h"

@class QMChatAttachmentService;

@interface QMMediaService : NSObject <QMMediaServiceDelegate>

@property (copy, nonatomic) QMAttachmentMessageStatusBlock onMessageDidChangeAttachmentStatus;
@property (copy, nonatomic) QMAttachmentMesssageUploadProgressBlock onMessageDidChangeUploadingProgress;

@end
