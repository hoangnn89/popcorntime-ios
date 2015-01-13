//
//  Downloader.h
//  popcornTIme
//
//  Created by Sad on 15/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "streamerok.h"

@interface Downloader : NSObject
{
    void (^successHandler)();
    void (^errorHandler)();
    void (^readyHandler)();
    void (^progressHandler)(float);
    void (^pieceChanged)(int);
    
    Streamerok *streamerok;
    
    BOOL isDownloading;
    
    NSTimer *timer;
    NSTimer *streamerokTimer;
    long long downloadedAlready;
    float calculatedPercent;
    float percent;
    int tInfo;
    BOOL isReadySended;
    int lastSendedBlock;
}


-(void) downloadTorrentFromFile:(NSURL *)fileUrl
                      onSuccess:(void (^)())success
                        onError:(void (^)())error
                  onReadyToView:(void (^)())ready
  onPiecesCountChanged:(void (^)(int block))pieceChanged
                     onProgress:(void (^)(float percent))progress;

-(float) currentPercent;
-(void) cancelDownload;
@end
