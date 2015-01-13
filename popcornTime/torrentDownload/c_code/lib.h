#ifndef __StreamerokLib__
    #define __StreamerokLib__
// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the LIB_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see
// LIB_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#include <Foundation/Foundation.h>
#include <string>

#ifdef LIB_EXPORTS
    #define LIB_API __declspec(dllexport)
#else
    #define LIB_API __declspec(dllimport)
#endif

struct dlInfo
{
    long long downloadRateBs;
    long long downloaded;
    long long total;
    long long piecesDone;
    long long piecesTotal;
    long long pieceSize;
    long long seeders;
    long long peers;
};

struct NetUsage
{
    long long uploadRateBs;
    long long downloadRateBs;
    long long uploaded;
    long long downloaded;
};

extern "C" LIB_API bool torrentInit( void );
extern "C" LIB_API void torrentDeInit( void );

extern "C" LIB_API int torrentAddStart( const char *url, const char *fileName = 0 );
extern "C" LIB_API int torrentAddImport( const char *torrentBody, int bodyLength, const char *fileName = 0 );
extern "C" LIB_API const dlInfo* torrentGetInfo( int torrentId );
extern "C" LIB_API bool torrentGetFileUrl( int torrentId, char *buffer, int length );
extern "C" LIB_API const NetUsage* torrentGetNetUsage( void );
extern "C" LIB_API bool torrentStopDelete( int torrentId );

#endif
