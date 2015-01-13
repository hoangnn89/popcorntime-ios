//
//  WebView.h
//  popcornTIme
//
//  Created by Sad on 24/06/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dwnl.h"

@protocol webProtocol <NSObject>

-(void) downloadComplete:(NSString*) fileName;
-(void) downloadFailed;


@end


@interface WebView : UIViewController<UIWebViewDelegate,dwnlProtocol>
{
    UIWebView *webV;
    Dwnl *dwnloader;
}

@property (nonatomic) id<webProtocol> delegate;
@property (nonatomic,retain) NSString *storeFolder;

-(BOOL) openTorrentSite;



@end
