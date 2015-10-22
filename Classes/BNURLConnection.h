//
//  BNURLConnection.h
//  zipDownloader
//
//  Created by Ravil 2 on 05.09.13.
//  Copyright (c) 2013 Ravil 2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGPageScrollViewSampleAppDelegate.h"
@class BNURLConnection;
@protocol BNURLConnectionProgressDelegate <NSObject>

- (void)updateBarWithProgress:(CGFloat)progress withObject:(BNURLConnection*)connection;
- (BOOL)finishDownloadFile:(NSString*)filePath withObject:(BNURLConnection*)connection; //должны ли мы удалить файл из папки загрузок
-(void)updateProcessWithCurrent:(CGFloat)current withTotal:(CGFloat)total withObject:(BNURLConnection*)connection withSpeed:(CGFloat)speed; //должны ли мы удалить файл из папки загрузок;
@end


@interface BNURLConnection : NSObject <NSURLConnectionDataDelegate,NSURLSessionDataDelegate> {
    NSURLConnection * URLConnect;
    NSMutableURLRequest * URLrequest;
    NSString * downloadsPath;
   
    NSMutableData*_dataToDownload;
    long long totalLen,currentLen;
    
    dispatch_queue_t downloadQueue;
    
    NSURLSessionDownloadTask *download;;
}
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property (nonatomic, strong)  NSString * currentFilePath;;
@property (nonatomic, strong) NSURL * connectionURL;
@property (nonatomic, strong) id <BNURLConnectionProgressDelegate> progressDelegate;
@property (nonatomic ,assign) BOOL isDownloadStop;
+(BNURLConnection *)resumeConnectionWithFilePath :(NSString *)filePath;
+ (BNURLConnection*)downloadFileByURL:(NSURL*)fileURL;
- (void) stopDownload;
- (void) resumeDownload;
- (void) prepareConnection;
-(void)resumeCurrnetDownload;
@end
