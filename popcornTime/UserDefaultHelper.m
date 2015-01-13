//
//  UserDefaultHelper.m
//  popcornTIme
//
//  Created by Sad  on 7/28/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import "UserDefaultHelper.h"

void writeToDefaultsFloat(int key, float value)
{
    
    switch (key){
        case DEFAULTS_PERCENT_KEY:
            [[NSUserDefaults standardUserDefaults] setFloat:value forKey:keyLastPercent];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }
}



float readFloatFromDefaults(int key){
    float value=0;
    switch (key){
    case DEFAULTS_PERCENT_KEY:
            value=[[NSUserDefaults standardUserDefaults] floatForKey:keyLastPercent];
            return value;
        break;
        
    default:
        break;
 
    }
    return 0;
}


void writeToDefaultsInt(int key, int value)
{
    
    switch (key){
        case DEFAULTS_MAX_BLOCK_KEY:
            [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"maxBlock"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }
}


int readIntFromDefaults(int key){
    float value=0;
    switch (key){
        case DEFAULTS_MAX_BLOCK_KEY:
            value=[[NSUserDefaults standardUserDefaults] integerForKey:@"maxBlock"];
            return value;
            break;
            
        default:
            break;
            
    }
    return 0;
}





void writeToDefaultsChar(int key, const char *value)
{
    NSData *dt=[NSData dataWithBytes:value length:sizeof(value)];
    
    

       switch (key){
        case DEFAULTS_TORRENT_INFO_KEY:
            [[NSUserDefaults standardUserDefaults] setObject:dt forKey:@"torrentInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
            
        default:
            break;
    }
}




bool compareToDefaultsChar(int key, const char *value){
   
    NSData *dt=[NSData dataWithBytes:value length:sizeof(value)];
 
    
    NSData *storedData ;
    switch (key){
        case DEFAULTS_TORRENT_INFO_KEY:
            storedData =[[NSUserDefaults standardUserDefaults] objectForKey:@"torrentInfo"];
            if(!storedData)
                return false;
            return [dt isEqualToData:storedData];
            
            break;
            
        default:
            break;
    }
    
    return false;
    
    
}


void cleanUserSettings(){
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"torrentInfo"];
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"maxBlock"];
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyLastPercent];
  // [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyLastTorrentFilePath];
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyIsReadySended];
    
    
    
}

