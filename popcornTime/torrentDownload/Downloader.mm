//
//  Downloader.m
//  popcornTIme
//
//  Created by Sad on 15/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "Downloader.h"
#import "UserDefaultHelper.h"
#import "StreamerokHelper.h"
#import "NSNotific.h"
#import "PathManager.h"

#define REFRESHDATA_SECONDS 5

@implementation Downloader{
    long long prevSessionDownloaded;
}



-(id) init{
    self=[super init];
    
    [self setupStreamerok];
    
    return self;
}




-(void) setupStreamerok{
    NSString *path=[PathManager torrentsFolder];
    
    std::string pth([path UTF8String]);
    Streamerok::myTempDir=pth;
    
    
    streamerok=new Streamerok;
    
}

-(void) downloadTorrentFromFile:(NSURL *)fileUrl
                      onSuccess:(void (^)())success
                        onError:(void (^)())error
                  onReadyToView:(void (^)())ready
           onPiecesCountChanged:(void (^)(int block))piece
                     onProgress:(void (^)(float percent))progress{
    
    successHandler=success;
    errorHandler=error;
    readyHandler=ready;
    progressHandler=progress;
    pieceChanged=piece;
    NSData *data=[NSData dataWithContentsOfURL:fileUrl];
    NSString *name=@"file.dat";
    
    NetUsage net =streamerok->getNetworkUsage();
    prevSessionDownloaded=net.downloaded;
    
    
    tInfo=streamerok->importTorrent((const char*)[data bytes],[data length],(const char*)[name UTF8String] );
    if(tInfo<0)
        return;
    isDownloading=YES;
    
    percent=-1;
    calculatedPercent=0;
    downloadedAlready=0;
    lastSendedBlock=-1;
    isReadySended=NO;
    
   
    //streamerok callback timer
    
    
    if(!streamerokTimer)
    {
        streamerokTimer=[NSTimer timerWithTimeInterval:3 target:self selector:@selector(streamerokCallback:) userInfo:Nil repeats:YES ];
    }
    [streamerokTimer fire];
    [[NSRunLoop currentRunLoop] addTimer:streamerokTimer forMode:NSDefaultRunLoopMode];
    
    
}

-(void) streamerokCallback:(NSTimer *) tmr{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        streamerok->peridoicCallback();
        [self periodicCall];
    });
}




-(void) timerFunction:(NSTimer *) tmr{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      
    });
}
        
        
        
        
-(void) periodicCall{
    
    @synchronized(self)
    {
        NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
        
        NetUsage net =streamerok->getNetworkUsage();
        NSLog(@"net usage d%lld ",net.downloadRateBs);
        [params setObject:[NSNumber numberWithLongLong:net.downloadRateBs] forKey:keySpeed];
        
        
        dlInfo dl=streamerok->getTorrentInfo(tInfo);
        NSLog(@"d%lld ",dl.downloaded);
        
        [params setObject:[NSNumber numberWithLongLong:dl.peers] forKey:keyPeers];
        [params setObject:[NSNumber numberWithLongLong:dl.seeders] forKey:keySeeds];
        
        
        //calculatedPercent
        long long needToDownload=dl.pieceSize*7; //7 pieces
        downloadedAlready+=(100-calculatedPercent)*net.downloadRateBs;
        long long downloadedInCurrentTorrent=net.downloaded-prevSessionDownloaded;
        float percentOfStartingBlock=downloadedInCurrentTorrent*100.0f/needToDownload;
        if(percentOfStartingBlock>95)
            percentOfStartingBlock=95;
        
        
        
        [params setObject:[NSNumber numberWithFloat:percentOfStartingBlock] forKey:keyStartingPercent];
        
        
        int maxDownloadedPick=streamerok->maxDownloadedPieceFromStart(tInfo);
        long long fullPick=dl.piecesTotal;
        float currentPercent=(((float)maxDownloadedPick+1)*100.0f/fullPick);
        if(currentPercent>percent)
        {
            percent=currentPercent;
            if(progressHandler)
                progressHandler(percent);
            writeToDefaultsFloat(DEFAULTS_PERCENT_KEY, percent);
            
        }
        
        [params setObject:[NSNumber numberWithFloat:currentPercent] forKey:keyExactPercent];
        
        tAux *aux=streamerok->getAux(tInfo);
        
        if(lastSendedBlock<maxDownloadedPick){
            lastSendedBlock=maxDownloadedPick;
            if(pieceChanged)
                pieceChanged(maxDownloadedPick);
        }
        
        
        [params setObject:[NSNumber numberWithInt:maxDownloadedPick] forKey:keyMaxDownloadedBlock];
        
        
        
        NSLog(@"max downloaded %d",maxDownloadedPick);
        if(!isReadySended)
        {
            bool isReady=aux->canGetUrl();
            if(isReady)
            {
                isReadySended=YES;
                if(readyHandler)
                    readyHandler();
                
                
            }
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ntfProgress object:nil userInfo:params];
        
        
        if(percent>=100.0)
        {
            //stop download
            [self cancelDownload];
            
        }
    }
}


-(float) currentPercent{
    
    return percent;
}



-(void) cancelDownload{
    @synchronized(self)
    {
    [streamerokTimer invalidate];
    streamerokTimer=nil;
    streamerok->deleteTorrent(tInfo);
    }
}

@end
