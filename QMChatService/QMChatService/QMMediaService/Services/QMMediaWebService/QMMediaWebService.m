//
//  QMMediaWebService.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 6/14/17.
//

#import "QMMediaWebService.h"
#import "QMMediaDownloadService.h"
#import "QMMediaUploadService.h"

@interface QMMediaWebService()

@property (nonatomic, strong) QMMediaUploadService *uploader;
@property (nonatomic, strong) QMMediaDownloadService *downloader;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *messagesWebProgress;
@end

@implementation QMMediaWebService

- (instancetype)init {
    
    QMMediaUploadService *uploader = [QMMediaUploadService new];
    QMMediaDownloadService *downloader = [QMMediaDownloadService new];
    
    return [self initWithUploader:uploader downloader:downloader];
}

- (instancetype)initWithUploader:(QMMediaUploadService *)uploader
                      downloader:(QMMediaDownloadService *)downloader {
    
    if (self = [super init]) {
        
        _messagesWebProgress = [NSMutableDictionary dictionary];
        _uploader = uploader;
        _downloader = downloader;
    }
    return self;
}


- (void)downloadMessage:(QBChatMessage *)message
           attachmentID:(NSString *)attachmentID
          progressBlock:(QMAttachmentProgressBlock)progressBlock
        completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.downloader downloadAttachmentWithID:attachmentID
                                    messageID:message.ID
                                progressBlock:^(float progress) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    [strongSelf setProgress:progress messageID:message.ID];
                                    progressBlock(progress);
                                }
                              completionBlock:completion];
}


- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
                withData:(NSData *)data
           progressBlock:(QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *uploadOperation))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.uploader uploadAttachment:attachment
                          messageID:messageID
                           withData:data
                      progressBlock:^(float progress) {
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf setProgress:progress messageID:messageID];
                          progressBlock(progress);
                      }
                    completionBlock:completion];
}

- (void)uploadAttachment:(QBChatAttachment *)attachment
               messageID:(NSString *)messageID
             withFileURL:(NSURL *)fileURL
           progressBlock:(_Nullable QMAttachmentProgressBlock)progressBlock
         completionBlock:(void(^)(QMUploadOperation *downloadOperation))completion {
    __weak typeof(self) weakSelf = self;
    [self.uploader uploadAttachment:attachment
                          messageID:messageID
                        withFileURL:fileURL
                      progressBlock:^(float progress) {
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf setProgress:progress messageID:messageID];
                          progressBlock(progress);
                      }
                    completionBlock:completion];
}

- (CGFloat)progressForMessageWithID:(NSString *)messageID {
    return _messagesWebProgress[messageID].floatValue;
}

- (void)setProgress:(CGFloat)progress messageID:(NSString *)messageID {
    _messagesWebProgress[messageID] = @(progress);
}

//MARK: - QMCancellableService

- (void)cancellOperationWithID:(NSString *)operationID {
    [self.messagesWebProgress removeObjectForKey:operationID];
    [self.downloader cancellOperationWithID:operationID];
    [self.uploader cancellOperationWithID:operationID];
    self.messagesWebProgress[operationID] = nil;
}

- (BOOL)isDownloadingMessageWithID:(NSString *)messageID {
    return  [self.downloader isDownloadingMessageWithID:messageID];
}

- (BOOL)isUploadingMessageWithID:(NSString *)messageID {
    return [self.uploader isUplodingMessageWithID:messageID];
}

- (void)cancelDownloadOperations {
    
    [self.downloader cancellAllOperations];
}

- (void)cancellAllOperations {
    
    [self.downloader cancellAllOperations];
    [self.uploader cancellAllOperations];
}
@end
