#pragma once
#include <string>

#define _DEBUG

#ifdef _DEBUG
    #define TORRENT_DEBUG
    #define USE_DEBUG(...)              DbgPrint( __VA_ARGS__)
extern "C" void DbgPrint( const char *FormatString, ... );
#endif

#ifndef USE_DEBUG
    #define USE_DEBUG(...)      
#endif

bool isExistsAndNotEmpty( std::string filePath );
bool tempDirValid();
std::string getTempDir();
void cleanTempDir();
void checkTempDir();

void replaceAll( std::string& str, const std::string& from, const std::string& to );
