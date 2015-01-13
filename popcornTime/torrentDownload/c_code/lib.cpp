// lib.cpp : Defines the exported functions for the DLL application.
//

#include "lib.h"

#include "limits.h"

#include "common.h"
#include "streamerok.h"



dlInfo gDlInfo;
NetUsage gNnetUsage;

bool torrentInit()
{
    checkTempDir();
    if ( !Streamerok::sPtr )
    {
        Streamerok::sPtr = new Streamerok;
        USE_DEBUG( "Lib init\n" );
    }

    return tempDirValid();
}


void torrentDeInit()
{
    if ( !Streamerok::sPtr ) return;
    delete Streamerok::sPtr;
    Streamerok::sPtr = 0;
    cleanTempDir();
    USE_DEBUG( "Lib deinit\n" );
}


int torrentAddStart( const char *url, const char *fileName )
{
    if ( !url ) return 0;
    torrentInit();
    return Streamerok::sPtr->downloadTorrent( url, fileName );
}

int torrentAddImport( const char *torrentBody, int bodyLength, const char *fileName )
{
    if ( !torrentBody ) return -8;
    torrentInit();
    return Streamerok::sPtr->importTorrent( torrentBody, bodyLength, fileName );

}

const dlInfo* torrentGetInfo( int torrentId )
{
    torrentInit();
    gDlInfo = Streamerok::sPtr->getTorrentInfo( torrentId );
    USE_DEBUG( "Bytes: %I64d of %I64d, speed %i B/s\n", gDlInfo.downloaded, gDlInfo.total, gDlInfo.downloadRateBs );

    return &gDlInfo;
}

bool torrentGetFileUrl( int torrentId, char *buffer, int length )
{
    torrentInit();
    return Streamerok::sPtr->getFileUrl( torrentId, buffer, length );
}


const NetUsage* torrentGetNetUsage()
{
    torrentInit();
    gNnetUsage = Streamerok::sPtr->getNetworkUsage();
    return &gNnetUsage;
}

bool torrentStopDelete( int torrentId )
{
    torrentInit();
    return Streamerok::sPtr->deleteTorrent( torrentId );
}


