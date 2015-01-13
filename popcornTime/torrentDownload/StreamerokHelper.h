//
//  StreamerokHelper.h
//  popcornTIme
//
//  Created by Sad  on 7/31/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kTorrentsFolder @"/Library/Caches/Torrents/"

//Global fuctions to call from C


bool isHostReachable(const char *host);
bool isLocalhost(const char *host);



void cleanOldFiles();

@interface StreamerokHelper : NSObject

@end
