//
//  ProgressViewViewController.h
//  popcornTIme
//
//  Created by Sad  on 8/3/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"

@protocol ProgressViewViewControllerDelegate <NSObject>

-(void) progressBarWantsToClose;

@end

@interface ProgressViewViewController : UIViewController
@property (weak, nonatomic) IBOutlet YLProgressBar *bar;
@property (weak, nonatomic) IBOutlet UILabel *lblText;

-(void) setProgress:(float) progress;
@property (weak, nonatomic) IBOutlet UILabel *lblPeers;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;
- (IBAction)btnClosePressed:(id)sender;

@property (nonatomic,weak) id<ProgressViewViewControllerDelegate> delegate;


@end
