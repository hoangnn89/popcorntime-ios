
//
//  ResumeViewController.h
//  popcornTIme
//
//  Created by Sad  on 8/4/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResumeViewController : UIViewController{
    NSMutableArray* _constraintsListPortrait;
    NSMutableArray* _constraintsListLandscape;
    
    void (^resumeHandler)();
    void (^openWebHandler)();
    
    

    
}


@property (weak, nonatomic) IBOutlet UIImageView *imgPoster;
@property (weak, nonatomic) IBOutlet UIImageView *imgPoster2;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent2;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle2;


@property (strong, nonatomic) IBOutlet UIView *viewForLandscape;

@property (strong, nonatomic) IBOutlet UIView *viewForPortrait;


-(void) setHandlersResume:(void (^)())resume

                  openWeb:(void (^)())openWeb;
- (IBAction)btnWebPressed:(id)sender;
- (IBAction)btnResumePressed:(id)sender;

@end
