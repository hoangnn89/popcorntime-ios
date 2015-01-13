//
//  UserDefaultHelper.h
//  popcornTIme
//
//  Created by Sad  on 7/28/14.
//  Copyright (c) 2014 Sad. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULTS_PERCENT_KEY 1
#define DEFAULTS_MAX_BLOCK_KEY 2
#define DEFAULTS_TORRENT_INFO_KEY 3


#define keyLastTorrentFilePath @"keyLastTorrentFilePath"
#define keyIsReadySended @"keyIsReadySended"
#define keyStoredTitle @"keyStoredTitle"
#define keyLastPercent @"keyLastPercent"

void writeToDefaultsFloat(int key, float value);
float readFloatFromDefaults(int key);



void writeToDefaultsChar(int key, const char *value);
bool compareToDefaultsChar(int key, const char *value);


void writeToDefaultsInt(int key, int value);
int readIntFromDefaults(int key);





void cleanUserSettings();

