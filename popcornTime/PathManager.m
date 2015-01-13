//
//  PathManager.m
//  popcornTIme
//
//  Created by Sad  on 9/13/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "PathManager.h"

@implementation PathManager




+(NSString *) documentsFolder{
#ifdef CYDIA_VERSION
    return @"/var/mobile/Library/PopcornTime";
#else
    return  [ NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] ;
    
#endif
    
  }
+(NSString *) torrentsFolder{
#ifdef CYDIA_VERSION
    return @"/var/mobile/Library/PopcornTime/Torrents";
#else
    return  [NSHomeDirectory()  stringByAppendingPathComponent:@"/Library/Caches/Torrents/"];
#endif
}


@end
