//
//  WebView.m
//  popcornTIme
//
//  Created by Sad on 24/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "WebView.h"
#import "Dwnl.h"
#import "Reachability.h"
#import "UserDefaultHelper.h"
#import "PathManager.h"
@interface WebView ()

@end


@implementation WebView
@synthesize storeFolder;

NSString *torrentSiteURL=@"http://ios.popcorn-time.se";

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
    webV=[[UIWebView alloc] initWithFrame:CGRectZero];
    webV.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:webV];
    webV.delegate=self;
    [webV setScalesPageToFit:YES];
    
    [(UIScrollView *) [webV.subviews objectAtIndex:0] setAlwaysBounceVertical:NO];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[webV]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(webV)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webV]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(webV)]];
    
    
    //set background color
    [self.view setBackgroundColor:[UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}


-(BOOL) openTorrentSite{
    NSString *host=[[NSURL URLWithString:torrentSiteURL] host];
    
    Reachability *r=[Reachability reachabilityWithHostName:host];
    NetworkStatus netStatus=[r currentReachabilityStatus];
    if(netStatus==NotReachable)
        return NO;
    
    webV.frame=self.view.bounds;
    NSURL *url=[NSURL URLWithString:torrentSiteURL];
    NSURLRequest *req=[NSURLRequest requestWithURL:url];
    [webV loadRequest:req];
    return YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    NSURL *requestURL=[request URL];
    if([requestURL.scheme isEqualToString:@"popcorn"])
    {
        
        NSString *command=[requestURL host];
        if([command isEqualToString:@"download"])
        {
            NSString *torrentURL=[requestURL.absoluteString stringByReplacingOccurrencesOfString:@"popcorn://download/" withString:@""];
            [self downloadFile:torrentURL];
            return NO;
        }
        
        if([command isEqualToString:@"poster"])
        {
            NSString *imageURL=[requestURL.absoluteString stringByReplacingOccurrencesOfString:@"popcorn://poster/" withString:@""];
            [self downloadImage:imageURL];
            return NO;
        }
        
        if([command isEqualToString:@"title"])
        {
            NSString *title=[requestURL.absoluteString stringByReplacingOccurrencesOfString:@"popcorn://title/" withString:@""];
            NSString *decodedString=(__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)title, CFSTR(""), kCFStringEncodingUTF8);
            [self storeTitle:decodedString];
            return NO;
        }
        
        if([command isEqualToString:@"json"])
        {
            NSString *urlWithCallback=[requestURL.absoluteString stringByReplacingOccurrencesOfString:@"popcorn://json/" withString:@""];
            NSURLComponents *comp=[NSURLComponents componentsWithString:urlWithCallback];
            NSString *query=comp.query;
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [query componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }

            comp.query=NULL;
            
            NSString *callbackFunction=params[@"callback"];
            NSString *movieId=params[@"movieId"];
            if(!dwnloader)
            {
                dwnloader=[[Dwnl alloc] init];
                [dwnloader setStoreFolder:self.storeFolder];
                dwnloader.delegate=self;
            }
            [dwnloader dataFromURL:[comp URL] returnBlock:^(NSString * answer) {
                if(answer)
                {
                    
                    
                    NSString *js=[NSString stringWithFormat:@"%@('%@','%@')",callbackFunction,answer,movieId];
                    js=[js stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    js=[js stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    js=[js stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    js=[js stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    [webView stringByEvaluatingJavaScriptFromString:js];
                }
            }];
             
            return NO;
        }
        if([command isEqualToString:@"subs"])
        {
            //delete old srt file
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *documentsPath=[PathManager documentsFolder] ;
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentsPath];
            
            
            NSString *subs;

            while ((subs = [enumerator nextObject]) != nil){
                if ([[subs pathExtension] isEqualToString:@"srt"]){
                    [fm removeItemAtPath:[documentsPath stringByAppendingPathComponent:subs] error:nil];
                    break;
                }
            }
            
            NSString *subsURL=[requestURL.absoluteString stringByReplacingOccurrencesOfString:@"popcorn://subs/" withString:@""];
            if(![subsURL isEqualToString:@"null"])
                [self downloadSubs:subsURL];
            return NO;
        }
        
        
    }
    
       return YES;
}




-(void) storeTitle:(NSString *)title{
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:keyStoredTitle];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void) downloadImage:(NSString *)image{
    
    if(!dwnloader)
    {
        dwnloader=[[Dwnl alloc] init];
        [dwnloader setStoreFolder:self.storeFolder];
        dwnloader.delegate=self;
    }
    [dwnloader downloadImage:image];
}

-(void) downloadSubs:(NSString *)subs{
    
    if(!dwnloader)
    {
        dwnloader=[[Dwnl alloc] init];
        [dwnloader setStoreFolder:self.storeFolder];
        dwnloader.delegate=self;
    }
    [dwnloader downloadSubs:subs];
}


-(void) downloadFile:(NSString *) file{
    
    
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    NSString* packagesPath = [PathManager documentsFolder];
    
	
	for (NSString* fileName in [fileManager contentsOfDirectoryAtPath:packagesPath error:nil])
	{
		NSString* absoluteFileName = [packagesPath stringByAppendingPathComponent:fileName];
		if ([fileName hasSuffix:@".torrent"] ){
			[fileManager removeItemAtPath:absoluteFileName error:nil];
		}
	}
    
    
    
    
    if(!dwnloader)
    {
        dwnloader=[[Dwnl alloc] init];
        [dwnloader setStoreFolder:self.storeFolder];
        dwnloader.delegate=self;
    }
    [dwnloader downloadUrl:file];
}

-(void) downloadComplete:(NSString*) torrentLink{
    [self.delegate downloadComplete:torrentLink];
}
-(void) downloadFailed{
    [self.delegate downloadFailed];
}
-(void) gotPercent:(NSInteger) percent{
    
}



@end
