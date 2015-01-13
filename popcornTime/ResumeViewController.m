//
//  ResumeViewController.m
//  popcornTIme
//
//  Created by Sad  on 8/4/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "ResumeViewController.h"
#import "UserDefaultHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "PathManager.h"

@interface ResumeViewController ()

@end

@implementation ResumeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self fillOldFilm];

    self.lblTitle.minimumScaleFactor=0.2;
    self.lblTitle.adjustsFontSizeToFitWidth=YES;
    self.lblTitle2.lineBreakMode=NSLineBreakByWordWrapping;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setHandlersResume:(void (^)())resume

                  openWeb:(void (^)())openWeb{
    resumeHandler=resume;
    openWebHandler=openWeb;
}

- (IBAction)btnWebPressed:(id)sender {
    if(openWebHandler)
        openWebHandler();
 
}

- (IBAction)btnResumePressed:(id)sender {
    if(resumeHandler)
        resumeHandler();
}



-(void) viewWillLayoutSubviews{
    
       [super viewWillLayoutSubviews];
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
 
 
    if(UIInterfaceOrientationIsLandscape(currentOrientation)){
           [self.viewForPortrait removeFromSuperview];
        [self.view addSubview:self.viewForLandscape];
        [self.viewForLandscape setFrame:self.view.bounds];
        
        
    }else {
           [self.viewForLandscape removeFromSuperview];
        [self.view addSubview:self.viewForPortrait];
        [self.viewForPortrait setFrame:self.view.bounds];
    }
    
 
}


-(void) fillOldFilm{
    NSString *title=[[NSUserDefaults standardUserDefaults] objectForKey:keyStoredTitle];
    self.lblTitle.text=title;
    self.lblTitle2.text=title;
    
    NSInteger percent=(int)[[NSUserDefaults standardUserDefaults] floatForKey:keyLastPercent];
    
    self.lblPercent.text=[NSString stringWithFormat:@"Downloaded: %d%%",percent];
    self.lblPercent2.text=[NSString stringWithFormat:@"Downloaded: %d%%",percent];
   
    NSString *imagePath=[[PathManager documentsFolder] stringByAppendingPathComponent:@"poster.jpg"];
    
    UIImage *img=[UIImage imageWithContentsOfFile:imagePath];
  if(img)
  {
        self.imgPoster.image=img;
        self.imgPoster2.image=img;
      
      
      self.imgPoster.layer.borderColor=[UIColor whiteColor].CGColor;
      self.imgPoster.layer.borderWidth=3.0f;
      
      self.imgPoster2.layer.borderColor=[UIColor whiteColor].CGColor;
      self.imgPoster2.layer.borderWidth=3.0f;
      
  }
}




@end
