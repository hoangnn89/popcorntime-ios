//
//  ProgressViewViewController.m
//  popcornTIme
//
//  Created by Sad  on 8/3/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "ProgressViewViewController.h"
#import "NSNotific.h"
@interface ProgressViewViewController ()

@end

@implementation ProgressViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self connectNotification];
    }
    return self;
}

-(void) dealloc{
    [self disconnectNotification];
}

-(void) connectNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(periodicCall:) name:ntfProgress object:nil];
}

-(void) disconnectNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ntfProgress object:nil];
}



-(void) periodicCall:(NSNotification *)ntf{
    NSDictionary *params=[ntf userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setSpeedLabel:[params objectForKey:keySpeed]];
        [self setPeersLabel:[params objectForKey:keyPeers] seeds:[params objectForKey:keySeeds]];
        [self updateProgress:[params objectForKey:keyStartingPercent] blockNumber:[params objectForKey:keyMaxDownloadedBlock]];
    });
    
    
}


-(void) setPeersLabel:(NSNumber *)peers seeds:(NSNumber*)seeds{
    NSString *text=[NSString stringWithFormat:@"%@/%@",seeds,peers];
    [self.lblPeers setText:text];
 }


-(void) setSpeedLabel:(NSNumber *)speedNumber{
    long long speed=[speedNumber longLongValue];
    NSNumber *formatNumber;
    float divider=1.0f;
    NSString *sizeString=@"b";
    if (speed>1000000) {
        divider=1000000.0f;
         sizeString=@"mb";
    }
    else if(speed>1000) {
        divider=1000.0f;
         sizeString=@"kb";
    }
    
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    formatter.roundingIncrement=[NSNumber numberWithDouble:0.01];
    formatter.numberStyle=NSNumberFormatterDecimalStyle;
    
    formatNumber=[NSNumber numberWithFloat:(float)speed/divider];
    
    NSString *speedString=[NSString stringWithFormat:@"%@ %@",[formatter stringFromNumber:formatNumber],sizeString];
    self.lblSpeed.text=speedString;
    
    
    
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self initRoundedSlimProgressBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initRoundedSlimProgressBar
{
    
    UIColor *leftColor  = [UIColor colorWithRed:0/255.0f green:90/255.0f blue:255/255.0f alpha:1.0f];
   // UIColor *rightColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    NSArray *colors     = @[leftColor, leftColor];
    self.bar.progressTintColors=colors;
    self.bar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    self.bar.stripesColor             = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    self.bar.type=YLProgressBarTypeFlat;
}


-(void) updateProgress:(NSNumber *)startPercentObj
           blockNumber:(NSNumber *)maxDownloadedBlockObj{
    
    float startPercent=[startPercentObj floatValue];
    float blockPercent=([maxDownloadedBlockObj intValue]+1)/5;
    float percent=MAX(startPercent, blockPercent);
    
    [self.bar setProgress:percent/100.f];
    [self.lblPercent setText:[NSString stringWithFormat:@"%d%%",(int)percent]];
    
    
    
    
}

- (IBAction)btnClosePressed:(id)sender {
    [self.delegate progressBarWantsToClose];
}
@end
