//
//  Dwnl.m
//  Yedioth Viewer
//
//  Created by Sad on 18/05/14.
//
//

#import "Dwnl.h"
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "PathManager.h"

@implementation Dwnl

@synthesize storeFolder;

-(id) init{
    self=[super init];
    
    operationQueue=[[NSOperationQueue alloc] init];
    return self;
    
    
}




-(void) downloadUrl:(NSString*) urlString{
    
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
 
    
    
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString *downloadURL=[[PathManager torrentsFolder] stringByAppendingPathComponent:[url lastPathComponent]];
    

    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req] ;
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadURL  append:NO];
    
    float ver=[[[UIDevice currentDevice] systemVersion] floatValue];
    if(ver>=6.0){
        [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [operation setFailureCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        
    }
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        int percent=(int)(totalBytesRead*100/totalBytesExpectedToRead);
        [self.delegate gotPercent:percent];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        

        [self.delegate downloadComplete:downloadURL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate downloadFailed];
    
    }];
    
    
    
    
    [operationQueue addOperation:operation];
    
    
}

#pragma mark image

-(void) downloadImage:(NSString *)image{
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:image]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
   
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      //  NSLog(@"Response: %@", responseObject);
       // _imageView.image = [UIImage imageWithData:responseObject];
        NSData *data=(NSData *)responseObject;
        NSString *path=[[PathManager documentsFolder] stringByAppendingPathComponent:@"poster.jpg"];
        
        [data writeToFile:path  atomically:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}


-(void) downloadSubs:(NSString *)subs{
    
    
    
    
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:subs]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //  NSLog(@"Response: %@", responseObject);
        // _imageView.image = [UIImage imageWithData:responseObject];
        NSData *data=(NSData *)responseObject;
        NSString *path=[[PathManager documentsFolder] stringByAppendingPathComponent:@"subs.zip"];
        
        [data writeToFile:path  atomically:YES];
        
        BOOL isFileUnzipped=[SSZipArchive unzipFileAtPath:path toDestination:[PathManager documentsFolder]];
        
        if(isFileUnzipped)
           [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}



-(void) dataFromURL:(NSURL *)url returnBlock:(void (^)(NSString *))returnBlock{
    
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      
        NSString *json=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        returnBlock(json);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        returnBlock(nil);
    }];
    [requestOperation start];
}

@end
