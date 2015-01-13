//
//  MainViewController.m
//  popcornTIme
//
//  Created by Sad on 05/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "MainViewController.h"
#import "Downloader.h"
#include <MobileVLCKit/VLCMediaPlayer.h>
//#import "AVPlayerViewController.h"
#import "WebView.h"
#import "VDLPlaybackViewController.h"
#import "UserDefaultHelper.h"
#import "ProgressViewViewController.h"
#import "ResumeViewController.h"
#import "NSNotific.h"
#import "BackViewController.h"
#import "PathManager.h"

@interface MainViewController ()<ProgressViewViewControllerDelegate>
-(void) progressBarWantsToClose;

@end

@implementation MainViewController{
    BOOL isDownloadRunning;
    BackViewController *back;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeVideoPlayer:) name:ntfCloseVideo object:nil];
        isDownloadRunning=NO;
        
    }
    return self;
}


 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createStoreFolder];
    
    _constraintsListPortrait = [NSMutableArray new];
    _constraintsListLandscape= [NSMutableArray new];
    [self addBackgroundImage];
    
}

-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}



-(void) addBackgroundImage{
 /*   back=[[BackViewController alloc] init];
    [self.view addSubview:back.view];
    [self.view sendSubviewToBack:back.view];*/
}

-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(statusBarOrientation))
    {
        
        [self.imgBackground setImage:[UIImage imageNamed:@"Landscape.png"]];
    }
    else
        [self.imgBackground setImage:[UIImage imageNamed:@"Default.png"]];
    
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    

    [self.view removeConstraints:_constraintsListPortrait];
    [self.view removeConstraints:_constraintsListLandscape];
    
    if (self.resumeView) {
        if(UIInterfaceOrientationIsLandscape(currentOrientation)){
            
            [self.view addConstraints:_constraintsListLandscape];
            
            
            
        }else {
            
            [self.view addConstraints:_constraintsListPortrait];
            
            
        }
    }
}



-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self openStartsView];


    
}







#pragma mark layouts
-(void) buildConstraints{
    
    
    
    // constraints for Landscape mode
    // this constraints has 1000 priority. (default value)
    // please modify offset value (20 or 40) to match your case.
    
    NSDictionary *views= @{@"resumeView": self.resumeView.view};
    
    
    [_constraintsListLandscape addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[resumeView]|"
                                                                                           options:0 metrics:nil
                                                                                             views:views]];
    [_constraintsListLandscape addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[resumeView]|"
                                                                                           options:0 metrics:nil
                                                                                             views:views]];
    
    
    
    
    
    [_constraintsListPortrait addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[resumeView]|"
                                                                                          options:0 metrics:nil
                                                                                            views:views]];
    [_constraintsListPortrait addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[resumeView]|"
                                                                                          options:0 metrics:nil
                                                                                            views:views]];
    
    
    
    [_constraintsListLandscape addObject:[NSLayoutConstraint constraintWithItem:self.resumeView.view
                                                                      attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0.0]];
    
    [_constraintsListPortrait addObject:[NSLayoutConstraint constraintWithItem:self.resumeView.view
                                                                     attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.4 constant:0.0]];
    
    
}


-(void) removeConstraints{
    [_constraintsListPortrait removeAllObjects];
    [_constraintsListLandscape removeAllObjects];
}


-(void) openStartsView{
    NSString *lastTitle=[[NSUserDefaults standardUserDefaults] objectForKey:keyStoredTitle];
    
    [self showWeb];
    
    if(lastTitle)
        [self showResumeView];
}



-(void) resumeLastFilm{
    bool isReadySended=[[NSUserDefaults standardUserDefaults] boolForKey:keyIsReadySended];
    if(isReadySended)
        [self startToViewplayer];
    NSString *lastTorrentFile=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:keyLastTorrentFilePath];
    if(!lastTorrentFile)
        return;
    [self downloadTorrentFromFile:lastTorrentFile];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark video player

-(void) startToViewplayer{
    
    
    [self hideProgressView];
    
    if(!movieView)
    {
        movieView=[[VDLPlaybackViewController alloc] initWithNibName:@"VDLPlaybackViewController" bundle:nil];
        [movieView.view setFrame:self.view.bounds];
        [self.view addSubview:movieView.view];
    }
    else{
        
        
        return;
    }
    if(dwnldr)
        [movieView setDownloaded:[dwnldr currentPercent]];
    else
    {
        float percent=readFloatFromDefaults(DEFAULTS_PERCENT_KEY);
        [movieView setDownloaded:percent];
    }
    NSString *path=[PathManager torrentsFolder];
    NSArray *videos=[self recursivePathsForVideosinDirectory:path];
    NSString *video=videos[0];
    [movieView playMediaFromURL:[NSURL fileURLWithPath:video]];
    
    
}



-(void) closeVideoPlayer:(NSNotification*) ntf {
    
    [movieView.view removeFromSuperview];
    movieView=nil;
    if(dwnldr){
       [dwnldr cancelDownload];
    }
    [self openStartsView];
    
}



- (NSArray *)recursivePathsForVideosinDirectory:(NSString *)directoryPath{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        if (
            [[filePath pathExtension] isEqualToString:@"mkv"]||
            [[filePath pathExtension] isEqualToString:@"mkv"]||
            [[filePath pathExtension] isEqualToString:@"avi"]||
            [[filePath pathExtension] isEqualToString:@"mpeg"]||
            [[filePath pathExtension] isEqualToString:@"divx"]||
            [[filePath pathExtension] isEqualToString:@"mp4"]||
            [[filePath pathExtension] isEqualToString:@"mpg"]
            
            
            ){
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
        }
    }
    
    return filePaths;
}


-(void) createStoreFolder{
    NSString *folder=[PathManager torrentsFolder];
    NSError *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:folder])
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    
}

#pragma web view


-(void) showWeb{
    
    web=[[WebView alloc] init];
    [web setStoreFolder:kTorrentsFolder];
    web.view.frame=CGRectZero;
    
    UIView *webView=web.view;
    [self.view addSubview:web.view];
    webView.translatesAutoresizingMaskIntoConstraints=NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    
    web.delegate=self;
    [self.view bringSubviewToFront:web.view];
    BOOL isOpened=[web openTorrentSite];
    if(!isOpened)
        [self hideWeb];
    
}


-(void) hideWeb{
    [web.view removeFromSuperview];
}







-(void) downloadComplete:(NSString*) fileName{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:keyLastTorrentFilePath];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self downloadTorrentFromFile:fileName];
    });
    
    
}
-(void) downloadFailed{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideWeb];
        //  lblMessage.text=@"Torrent download failed";
    });
    
    
}



-(void) downloadTorrentFromFile:(NSString *)fileName{
    isDownloadRunning=YES;
    [self hideWeb];
    float percent=[[NSUserDefaults standardUserDefaults] floatForKey:keyLastPercent];
    if(percent>=100)
        return; //downloaded
    
    
    if(!movieView) { // mo movie on screen
        [self showProgressView];
        //  [progressView setProgress:0];
        
    }
    
    if(!dwnldr)
    {
        dwnldr=[[Downloader alloc] init];
        
    }
    [dwnldr downloadTorrentFromFile:[NSURL fileURLWithPath:fileName]
                          onSuccess:nil
                            onError:nil
     
                      onReadyToView:^(void){
                          if(isDownloadRunning)
                          {
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyIsReadySended];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  
                                  [self startToViewplayer];
                                  
                              });
                          }
                          
                      }
                      onPiecesCountChanged:^(int block) {
                      }
                      onProgress:^(float percent){
                       }];
    
}


-(void) cancelDownload{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [dwnldr cancelDownload];
        
        isDownloadRunning=NO;
    });
 
}



-(void) showProgressView{
    if(!progressView)
    {
        progressView=[[ProgressViewViewController alloc] init];
        progressView.delegate=self;
        progressView.view.frame=self.view.bounds;
        [self.view addSubview:progressView.view];
        
        
        
    }
    
}

-(void) hideProgressView{
    [progressView.view removeFromSuperview];
    progressView=nil;

}


-(void) progressBarWantsToClose{
    [self hideProgressView];
    [self openStartsView];
    [dwnldr cancelDownload];
}


#pragma mark resume view



-(void) showResumeView{
    
    if(!self.resumeView)
    {
        self.resumeView=[[ResumeViewController  alloc] init];
        self.resumeView.view.frame=CGRectZero;
        self.resumeView.view.translatesAutoresizingMaskIntoConstraints=NO;
        [self.view addSubview:self.resumeView.view];
        
        //shadow
        self.resumeView.view.layer.masksToBounds = NO;
        self.resumeView.view.layer.cornerRadius = 8; // if you like rounded corners
        self.resumeView.view.layer.shadowOffset = CGSizeMake(0, 0);
      // self.resumeView.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.resumeView.view.bounds].CGPath;
        self.resumeView.view.layer.shadowRadius = 10;
        self.resumeView.view.layer.shadowOpacity = 1.0;
        
        [self buildConstraints];
        __weak MainViewController *weakSelf=self;
        [self.resumeView setHandlersResume:^{
            [weakSelf.resumeView.view setHidden:YES];
            [weakSelf resumeLastFilm];
            [weakSelf.resumeView.view removeFromSuperview];
            weakSelf.resumeView=nil;
            [weakSelf removeConstraints];
        } openWeb:^{
            
            [weakSelf.resumeView.view setHidden:YES];
             [weakSelf removeConstraints];
            [weakSelf.resumeView.view removeFromSuperview];
            weakSelf.resumeView=nil;
            
        }];
        
        
    }
    
    
}




@end
