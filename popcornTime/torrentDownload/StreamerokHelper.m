//
//  StreamerokHelper.m
//  popcornTIme
//
//  Created by Sad  on 7/31/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "StreamerokHelper.h"
#import "Reachability.h"
#include <netdb.h>
#include <arpa/inet.h>
#import "UserDefaultHelper.h"


bool isHostReachable(const char *host){
    bool isLocal=isLocalhost(host);
    if(isLocal)
        return false;
    
    NSString *stringURL=[NSString stringWithUTF8String:host];
    NSString *hostString=[[NSURL URLWithString:stringURL] host];
    Reachability *r=[Reachability reachabilityWithHostName:hostString];
    NetworkStatus netStatus=[r currentReachabilityStatus];
    if(netStatus!=NotReachable)
        return true;
    else
        return false;
    
}




bool isLocalhost(const char *host){
    
    NSString *stringURL=[NSString stringWithUTF8String:host];
    NSString *hostString=[[NSURL URLWithString:stringURL] host];
    
    struct hostent *remoteHostEnt = gethostbyname([hostString UTF8String]);
    if (!remoteHostEnt) {
        return false;
    }
    // Get address info from host entry
    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
    // Convert numeric addr to ASCII string
    char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
    // hostIP
    NSString* hostIP = [NSString stringWithUTF8String:sRemoteInAddr];
    if ([[hostIP substringToIndex:3] isEqualToString:@"127"]) {
        return true;
    }
    
    return false;
    
    
    
    
    
}


void cleanOldFiles(){
    NSString *torrentPath=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:keyLastTorrentFilePath];
    if(!torrentPath)
        return;
    
    NSString *folder=[torrentPath stringByDeletingLastPathComponent];
    NSError *error;
    NSArray *contents=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    for (NSString *file in contents) {
        NSString *path=[folder stringByAppendingPathComponent:file];
        if(![path isEqualToString:torrentPath])
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    
    
}


@implementation StreamerokHelper

@end
