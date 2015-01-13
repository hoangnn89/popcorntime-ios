#pragma once

#define TORRENT_NO_ASSERTS 1
//#define TORRENT_NO_DEPRECATE 1
#define TORRENT_DISK_STATS 1

#include "lib.h"
#include <unordered_map>
#include "libtorrent/session.hpp"



struct tAux
{
    tAux( libtorrent::torrent_handle hndl, int index, long long size );
    void prioritize();
    bool canGetUrl();
    libtorrent::torrent_handle handle;
    int fileIndex;
    long long fileSize;
    int pieceLength;
    int fileFirstPiece;
    int fileLastPiece;
    std::string fileUri;
    std::string filePath;
};

typedef std::unordered_map<int, tAux> torrentMap;

class Streamerok
{
public:
    Streamerok();
    ~Streamerok();

    // returns positive integer for torrent, negative for error
    int downloadTorrent( const char *url, const char *fileName = 0 );
    int importTorrent( const char *torrentBody, int bodyLength, const char *fileName = 0 );
    
    
    int maxDownloadedPieceFromStart( int torrentId );
    dlInfo getTorrentInfo( int torrentId );
    bool getFileUrl( int torrentId, char *buffer, int length );
    tAux* getAuxByUriPath( const char *uri );
    tAux* getAuxByIndex( int torrentId );
    int getIndexByUriPath( const char *uri );
    NetUsage getNetworkUsage();
    virtual bool deleteTorrent( int torrentId );
    tAux* getAux( int torrentId );
    int getNextId()
    {
        if ( nextId + 1 == INT_MAX ) nextId = 0;
        return ++nextId;
    }
    static std::string myTempDir;
    static Streamerok *sPtr;
    static int countPieces( libtorrent::bitfield &pieces, int first, int last );
    void setLogPath();
    void peridoicCallback();

private:
    std::string getFileUrl( int torrentId );
//  std::string getFileRelPath( int torrentId );

    bool handle_alert( libtorrent::alert *a );
    libtorrent::session ses;
    torrentMap tMap;
    int nextId;
    int maxDownloadedPieceFromStartCount;
};

extern "C" int getTorrentIndex( const char *uri );
extern "C" unsigned long long getFileSize( int torrentId );
extern "C" unsigned long long getFileDownloaded( int torrentId );

