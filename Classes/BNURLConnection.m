//
//  BNURLConnection.m
//  zipDownloader
//
//  Created by Ravil 2 on 05.09.13.
//  Copyright (c) 2013 Ravil 2. All rights reserved.
//

#import "BNURLConnection.h"

@implementation BNURLConnection
@synthesize isDownloadStop;
@synthesize currentFilePath;
@synthesize backgroundSession;
+(BNURLConnection *)downloadFileByURL:(NSURL *)fileURL {
    BNURLConnection * connection = [[BNURLConnection alloc] init];
    connection.connectionURL = fileURL;
    [connection prepareConnection];
    return connection;
}
+(BNURLConnection *)resumeConnectionWithFilePath :(NSString *)filePath{
    BNURLConnection * connection = [[BNURLConnection alloc] init];
    NSDictionary *  contentArray = (NSDictionary *)[NSDictionary dictionaryWithContentsOfFile:filePath];
    connection.connectionURL = [NSURL URLWithString:[contentArray objectForKey:@"url"]];
    
    connection.currentFilePath =[[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];

    [connection resumeDownload];

    return connection;
}
NSTimeInterval start;
-(void)prepareConnection {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    downloadsPath = [basePath stringByAppendingPathComponent:@"downloads"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"%@",_connectionURL.absoluteString);
    NSArray * urlElements = [[_connectionURL absoluteString] componentsSeparatedByString:@"/"];
    NSArray *arrPath = [[[_connectionURL absoluteString] lastPathComponent] componentsSeparatedByString:@".mp4"];
    if (arrPath.count==2) {
        currentFilePath = [downloadsPath stringByAppendingPathComponent:[[arrPath objectAtIndex:0] stringByAppendingPathExtension:@"mp4"]];

    }
    else if ([_connectionURL.absoluteString.lastPathComponent rangeOfString:@".mp4"].location == NSNotFound){
        
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"downloadcount"];
        currentFilePath = [downloadsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"VideoPlayback%ld.mp4",(long)count]];
        [[NSUserDefaults standardUserDefaults]setInteger:count+1 forKey:@"downloadcount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      
    }
    else{
        currentFilePath = [downloadsPath stringByAppendingPathComponent:[urlElements lastObject]];
    }
    
    
    downloadQueue = dispatch_queue_create("DownlodFileQueue", NULL);
    
    BOOL needsCreatenewFile = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentFilePath]) {
        NSDictionary * fileAttributes = [self getFileAttributes];
        if (fileAttributes) {
            currentLen = [fileAttributes[@"currentSize"] longLongValue];
            totalLen = [fileAttributes[@"totalSize"] longLongValue];
            [self resumeDownload];
            return;
        } else {
            currentLen = 0;
            totalLen = 0;
            [[NSFileManager defaultManager] removeItemAtPath:currentFilePath error:nil];
            needsCreatenewFile = YES;
        }
    } else
        needsCreatenewFile = YES;
    
    if (needsCreatenewFile)
        [[NSFileManager defaultManager] createFileAtPath:currentFilePath contents:nil attributes:nil];
    
    
    
    NSInteger randomNumber = arc4random() % 1000000;
    NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfiguration: [NSString stringWithFormat:@"testSession.foo.%ld", (long)randomNumber]];

    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = self.connectionURL;
    download = [self.backgroundSession downloadTaskWithURL:url];
    
    [download resume];
    
    return;
    URLrequest = [NSMutableURLRequest requestWithURL:_connectionURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    URLConnect = [NSURLConnection connectionWithRequest:URLrequest delegate:self];
    [_progressDelegate updateBarWithProgress:0 withObject:self];
    [URLConnect start];
    
     start= [NSDate timeIntervalSinceReferenceDate];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connection isEqual:URLConnect]) {
        dispatch_async(downloadQueue, ^{
            NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:currentFilePath];
            [handle seekToEndOfFile];
            [handle writeData:data];
            [handle closeFile];
            
            currentLen += [data length];
            
            [self setCurrentlFileSizeToAttributes:currentLen];
            dispatch_async(dispatch_get_main_queue(), ^{
                double speed = [data length] / ([NSDate timeIntervalSinceReferenceDate] - start);
                [_progressDelegate updateProcessWithCurrent:(float)currentLen withTotal:(float)totalLen withObject:self withSpeed:speed];


            });
        });
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
   // progressBar.progress=0.0f;
   // _downloadSize=[response expectedContentLength];
    [_progressDelegate updateBarWithProgress:0 withObject:self];

    _dataToDownload=[[NSMutableData alloc]init];
    
    dispatch_async(downloadQueue, ^{
        if (!totalLen) {
            totalLen = [response expectedContentLength];
            [self setTotalFileSizeToAttributes:totalLen];
        }
        
    });
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
   // [_dataToDownload appendData:data];
   // progressBar.progress=[ _dataToDownload length ]/_downloadSize;
    
   
    dispatch_async(downloadQueue, ^{
        NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:currentFilePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle closeFile];
        
        currentLen += [data length];
        
        [self setCurrentlFileSizeToAttributes:currentLen];
        dispatch_async(dispatch_get_main_queue(), ^{
            double speed = [data length] / ([NSDate timeIntervalSinceReferenceDate] - start);
            [_progressDelegate updateProcessWithCurrent:(float)currentLen withTotal:(float)totalLen withObject:self withSpeed:speed];
            
            
        });
    });

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    currentLen = 0;
    totalLen = 0;
    [[NSFileManager defaultManager] moveItemAtPath:currentFilePath toPath:[DOCUMENT_PATH stringByAppendingPathComponent:[currentFilePath lastPathComponent]] error:nil];
    //   [[NSFileManager defaultManager] removeItemAtPath:currentFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[[currentFilePath stringByDeletingPathExtension]stringByAppendingString:@".plist"] error:nil];
    
    [_progressDelegate finishDownloadFile:[DOCUMENT_PATH stringByAppendingPathComponent:[currentFilePath lastPathComponent]] withObject:self];
}
- (NSDictionary*)getFileAttributes {
    NSString * attrPath = [[currentFilePath stringByDeletingPathExtension] stringByAppendingString:@".plist"];
    NSDictionary * attrsDict = [NSDictionary dictionaryWithContentsOfFile:attrPath];
    
    return attrsDict;
}

- (void)saveArttributes:(NSDictionary*)attrs {
    NSString * attrPath = [[currentFilePath stringByDeletingPathExtension] stringByAppendingString:@".plist"];
    [attrs setValue:_connectionURL.absoluteString forKey:@"url"];
    [attrs setValue:[self.currentFilePath lastPathComponent] forKey:@"name"];
    [attrs writeToFile:attrPath atomically:YES];
}

- (void)setTotalFileSizeToAttributes:(long long) size {
    NSMutableDictionary * attrs = [[self getFileAttributes] mutableCopy];
    if (!attrs) {
        attrs = [NSMutableDictionary dictionary];
    }
    [attrs setObject:@(size) forKey:@"totalSize" ];
    [self saveArttributes:attrs];
}

- (void)setCurrentlFileSizeToAttributes:(long long) size {
    NSMutableDictionary * attrs = [[self getFileAttributes] mutableCopy];
    if (!attrs) {
        attrs = [NSMutableDictionary dictionary];
    }
    [attrs setObject:@(size) forKey:@"currentSize" ];
    [self saveArttributes:attrs];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    dispatch_async(downloadQueue, ^{
        if (!totalLen) {
            totalLen = [response expectedContentLength];
            [self setTotalFileSizeToAttributes:totalLen];
        }

    });
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(downloadQueue, ^{
        
        currentLen = 0;
        totalLen = 0;
            [[NSFileManager defaultManager] moveItemAtPath:currentFilePath toPath:[DOCUMENT_PATH stringByAppendingPathComponent:[currentFilePath lastPathComponent]] error:nil];
         //   [[NSFileManager defaultManager] removeItemAtPath:currentFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[[currentFilePath stringByDeletingPathExtension]stringByAppendingString:@".plist"] error:nil];
        
        [_progressDelegate finishDownloadFile:[DOCUMENT_PATH stringByAppendingPathComponent:[currentFilePath lastPathComponent]] withObject:self];
    });
   
}

- (void)stopDownload {
    
    [download suspend];;
    isDownloadStop = true;

    return;
    [URLConnect cancel];
}
-(void)resumeCurrnetDownload{
    [download resume];;
    isDownloadStop = false;

}

-(void)resumeDownload {
    if (!downloadQueue) {
        downloadQueue = dispatch_queue_create("DownlodFileQueue", NULL);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        downloadsPath = [basePath stringByAppendingPathComponent:@"downloads"];
        
        NSDictionary * fileAttributes = [self getFileAttributes];
        if (fileAttributes) {
            currentLen = [fileAttributes[@"currentSize"] longLongValue];
            totalLen = [fileAttributes[@"totalSize"] longLongValue];
        }
    }
    isDownloadStop = false;
    NSDictionary * attributes = [self getFileAttributes];
    URLrequest = [NSMutableURLRequest requestWithURL:_connectionURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSString * val = [NSString stringWithFormat:@"bytes=%@-%@",[attributes objectForKey:@"currentSize"] ,[attributes objectForKey:@"totalSize"]];
    [URLrequest setValue:val forHTTPHeaderField:@"Range"];
    URLConnect = [NSURLConnection connectionWithRequest:URLrequest delegate:self];
    [_progressDelegate updateBarWithProgress:(float)currentLen/(float)totalLen withObject:self];
    [URLConnect start];
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    HGPageScrollViewSampleAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}
@end
