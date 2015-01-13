//
//  Dwnl.h
//  Yedioth Viewer
//
//  Created by Sad on 18/05/14.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@protocol dwnlProtocol <NSObject>

-(void) downloadComplete:(NSString*) fileName;
-(void) downloadFailed;
-(void) gotPercent:(NSInteger) percent;

@end

@interface Dwnl : NSObject{
    NSOperationQueue *operationQueue;
 
}

@property (nonatomic,retain) NSString *storeFolder;
@property (nonatomic) id<dwnlProtocol> delegate;

-(void) downloadUrl:(NSString*) urlString;
-(void) downloadImage:(NSString *)image;
-(void) downloadSubs:(NSString *)subs;
-(void ) dataFromURL:(NSURL *)url returnBlock:(void (^)(NSString *))returnBlock;

@end
