//
//  MainViewController.h
//  popcornTIme
//
//  Created by Sad on 05/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "WebView.h"
#import "Reachability.h"
#import "StreamerokHelper.h"

@class Downloader;
@class AVPlayerViewController;
@class VDLPlaybackViewController;
@class ProgressViewViewController;
@class ResumeViewController;

@interface MainViewController : UIViewController<webProtocol>{
    
    Downloader *dwnldr;
    
    
    VDLPlaybackViewController *movieView;
     WebView *web;
    
    ProgressViewViewController *progressView;
    

    
    
    NSMutableArray* _constraintsListPortrait;
    NSMutableArray* _constraintsListLandscape;
}



-(void) downloadComplete:(NSString*) fileName;
-(void) downloadFailed;

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (nonatomic) ResumeViewController *resumeView;

@end
