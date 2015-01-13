#include "common.h"
#include "streamerok.h"

#include "urlencode.h"


#include "libtorrent/alert_types.hpp"
#include <boost/foreach.hpp>
#include <boost/lexical_cast.hpp>
#include "UserDefaultHelper.h"
#include "StreamerokHelper.h"

#define FILEPATH_IN_URL	1

const int MAX_PRIORITY_PIECES = 5;
const int MIN_START_PIECES = 5;

using namespace libtorrent;

struct dlInfoExt : public dlInfo
{
    dlInfoExt()
    {
        downloadRateBs = 0;
        downloaded = 0;
        total = 0;
        piecesDone = 0;
        piecesTotal = 0;
        pieceSize = 0;
        seeders = 0;
        peers = 0;
    }
};

struct NetUsageExt : public NetUsage
{
    NetUsageExt( long long ulRate = 0, long long dlRate = 0, long long ulTotal = 0, long long dlTotal = 0 )
    {
        uploadRateBs = ulRate;
        downloadRateBs = dlRate;
        uploaded = ulTotal;
        downloaded = dlTotal;
    }
};


//void peridoicCallback();

//Streamerok *Streamerok::sPtr = 0;
std::string Streamerok::myTempDir;


tAux::tAux( libtorrent::torrent_handle hndl, int index, long long size )
   : handle( hndl ), fileIndex( index ), fileSize( size )
{
    if ( !handle.is_valid() ) return;
    handle.set_sequential_download( false );
    
    
    
    torrent_info ti = handle.get_torrent_info();
  
    
    
    std::vector<announce_entry>trackers= ti.trackers();
    std::vector<announce_entry> newTrackers;
    
    
  /*  bool isSomeHostReachable=false;
    for (int i=0; i<trackers.size(); i++) {
        announce_entry entry=trackers[i];
        std::string host=entry.url;
        bool isReachable=isHostReachable(host.c_str());
        if(isReachable)
        {
            isSomeHostReachable=true;
            newTrackers.push_back(entry);
        }
    }
    if(newTrackers.size()!=trackers.size())
    {
        handle.replace_trackers(newTrackers);
        handle.force_reannounce();
    }
    */
    
    
    
    fileFirstPiece = ti.map_file( fileIndex, 0, 1 ).piece;
    fileLastPiece = ti.map_file( fileIndex, fileSize - 1, 1 ).piece;
    handle.piece_priority( fileLastPiece, 7 );
    handle.piece_priority( fileLastPiece - 1, 7 );
    pieceLength = ti.piece_length();
    
    int minNotDownloaded=readIntFromDefaults(DEFAULTS_MAX_BLOCK_KEY)+1;
    if(fileFirstPiece<minNotDownloaded)
        fileFirstPiece=minNotDownloaded;
        
    for ( int i = fileFirstPiece; i < fileFirstPiece + MAX_PRIORITY_PIECES && i < fileLastPiece; ++i ) handle.piece_priority( i, 7 );
}





void tAux::prioritize()
{
    if ( !handle.is_valid() ) return;
    if ( !handle.have_piece( fileLastPiece ) ) return;
//  USE_DEBUG( "Prioritize\n" );
    int piecesToSet = MAX_PRIORITY_PIECES;
    int latestPiece = fileLastPiece;
    bool hadPiece = true;
    for ( int i = fileFirstPiece; i < fileLastPiece && i < latestPiece && piecesToSet; ++i )
    {
        if ( handle.have_piece( i ) ) continue;
        else if ( latestPiece >= fileLastPiece ) latestPiece = i + MAX_PRIORITY_PIECES;
        if ( handle.piece_priority( i ) != 7 )
        {
            handle.piece_priority( i, 7 );
            USE_DEBUG( "Prioritize piece %i\n", i );
        }
        --piecesToSet;
    }
}

bool tAux::canGetUrl()
{
    if ( !handle.is_valid() ) return false;
    bitfield pieces = handle.status( torrent_handle::query_pieces ).pieces;
    if ( !pieces.get_bit( fileLastPiece ) ) return false;
    int piecesToSet = 0;
//  handle.set_sequential_download( true );
    for ( int i = fileFirstPiece; i < fileLastPiece; ++i )
    {
        if ( !handle.have_piece( i ) ) return false;
        if ( ++piecesToSet >= MIN_START_PIECES ) return true;
    }
    return true;
}






Streamerok::Streamerok()
   : nextId( 0 ), ses( fingerprint( "uTorrent", LIBTORRENT_VERSION_MAJOR, LIBTORRENT_VERSION_MINOR, 0, 0 )
                       , std::pair<int, int>( 25675, 25690 )
                       , 0
                       , session::add_default_plugins
                       , alert::progress_notification
                      
                      )
{
     ses.set_log_path(Streamerok::myTempDir);
    ses.start_lsd();
    session_settings sets = ses.settings();
//  sets.cache_expiry = 5;
//  sets.peer_connect_timeout = 3;
//  sets.connections_limit = 80;
//  sets.connection_speed = 20;
//  sets.download_rate_limit = 0;

   /* proxy_settings p;
    p.type=proxy_settings::socks4;
    p.hostname="192.168.2.77";
    p.port=8889;
    p.proxy_hostnames=false;
    p.proxy_peer_connections=false;
    ses.set_proxy(p);
    

    */
    
    sets.announce_to_all_tiers=true;
    sets.announce_to_all_trackers=true;
    sets.prefer_udp_trackers=false;
    sets.max_peerlist_size=0;
    
    ses.set_settings(sets);
    

}

Streamerok::~Streamerok()
{
  //  SocketHandler::stop();
    sleep( 100 );
}

/*----- log path -------*/

void Streamerok::setLogPath( ){
   
}











int Streamerok::importTorrent( const char *torrentBody, int bodyLength, const char *fileName )
{
    if ( !torrentBody || !bodyLength ) return 0;
    error_code ec;
    
    maxDownloadedPieceFromStartCount=-1;
    boost::intrusive_ptr<torrent_info> t = new torrent_info( torrentBody, bodyLength, ec );
    if ( ec )
    {
        USE_DEBUG( "Torrent add error: %s\n", ec.message().c_str() );
//      USE_DEBUG( "Torrent add error %s: %s\n", url, ec.message().c_str() );
        return -8;
    }

    
   libtorrent::sha1_hash shahash=t->info_hash();
    std::string str=shahash.to_string();
    
   bool isStored=compareToDefaultsChar(DEFAULTS_TORRENT_INFO_KEY, str.c_str());
    
    if(!isStored){
        cleanOldFiles();
        cleanUserSettings();
        writeToDefaultsChar(DEFAULTS_TORRENT_INFO_KEY, str.c_str());
        writeToDefaultsInt(DEFAULTS_MAX_BLOCK_KEY, -1);
        writeToDefaultsFloat(DEFAULTS_PERCENT_KEY, 0);
        
    }
   
    
   // char *hash=t->info_hash();
 add_torrent_params p;
    p.ti = t;
   
    p.save_path = myTempDir;//tempDirValid() ? getTempDir() : std::string( "." );


    std::string selectedFileName;
    if ( fileName ) selectedFileName = std::string( fileName );

    std::vector<boost::uint8_t> filePrio;
    size_type longestSize = 0;
    int longestIndex = -1;

    for ( int i = 0; i < t->num_files(); ++i )
    {
        filePrio.push_back( 0 );
        const file_entry file = t->file_at( i );
        USE_DEBUG( "[%i] %08I64d %s\n", i, file.size, file.path.c_str() );
        if ( file.pad_file || longestSize == std::numeric_limits<int64_t>::max() ) continue;
        if ( file.size > longestSize )
        {
            longestSize = file.size;
            longestIndex = i;
        }
        if ( selectedFileName.size() && file.path.find( selectedFileName ) != std::string::npos )
        {
            longestIndex = i;
            longestSize = std::numeric_limits<int64_t>::max();
        }
    }
    if ( longestIndex < 0 && longestIndex >= t->num_files() )
    {
        USE_DEBUG( "no file selected\n", longestIndex );
        return -9;
    }
//  filePrio[longestIndex] = 1;
    USE_DEBUG( "selected [%i] %08I64d %s\n", longestIndex, t->file_at( longestIndex ).size, t->file_at( longestIndex ).path.c_str() );
//    p.file_priorities = &filePrio;
  p.file_priorities =filePrio;
    
    p.storage_mode = libtorrent::storage_mode_allocate;
    int index = getNextId();
    tMap.insert( torrentMap::value_type( index, tAux( ses.add_torrent( p, ec ), longestIndex, t->file_at( longestIndex ).size ) ) );
    if ( ec )
    {
        USE_DEBUG( "Torrent add error: %s\n", ec.message().c_str() );
        torrentMap::iterator it = tMap.find( index );
        if ( it != tMap.end() ) tMap.erase( it );
        return -10;
    }
    USE_DEBUG( "torrent added.\n" );
    return index;
}










tAux* Streamerok::getAux( int torrentId )
{
    torrentMap::iterator it = tMap.find( torrentId );
    if ( it == tMap.end() ) return 0;
    tAux *t = &it->second;
    if ( t && t->handle.is_valid() ) return t;
    tMap.erase( it );
    return 0;
}


int Streamerok::maxDownloadedPieceFromStart( int torrentId )
{
    tAux *tInf = getAux( torrentId );
    if ( !tInf ) return 0;
    
    
    torrent_handle *t = &tInf->handle;
    
    std::vector<announce_entry> trackers=t->trackers();
    torrent_status ts = t->status( torrent_handle::query_pieces );
   
    bitfield b=ts.pieces;
    int size=b.size();
    if(maxDownloadedPieceFromStartCount<0)
        maxDownloadedPieceFromStartCount=0;
    
    for(int i=maxDownloadedPieceFromStartCount;i<size;i++){
        if (!b.get_bit(i)) {
            maxDownloadedPieceFromStartCount=i-1;
            break;
        }
    }
    writeToDefaultsInt(DEFAULTS_MAX_BLOCK_KEY, maxDownloadedPieceFromStartCount);
    return maxDownloadedPieceFromStartCount;
}


dlInfo Streamerok::getTorrentInfo( int torrentId )
{
    dlInfoExt result;

    tAux *tInf = getAux( torrentId );
    if ( !tInf ) return result;

    result.total = tInf->fileSize;

    torrent_handle *t = &tInf->handle;

//  torrent_status ts = t->status( 0 );
    torrent_status ts = t->status( torrent_handle::query_pieces );
    result.downloadRateBs = ts.download_payload_rate;
    result.seeders = ts.num_seeds;
    result.peers = ts.num_peers;
    result.piecesDone = ts.num_pieces;
    torrent_info ti = t->get_torrent_info();
    result.piecesTotal = ti.num_pieces(); ///@todo select pieces from file!!!
    result.pieceSize = ti.piece_length();
    result.downloaded = tInf->fileSize == ts.total_wanted_done ? tInf->fileSize : countPieces( ts.pieces, tInf->fileFirstPiece, tInf->fileLastPiece ) * ti.piece_length();
//  result.downloaded = ts.total_wanted_done;

    const int first = tInf->fileFirstPiece;
    const int last = tInf->fileLastPiece;
    USE_DEBUG( "File pieces %i..%i piece1:%i, piece2:%i, piece3:%i, piece4:%i, piece5:%i, last piece:%i, seq%i\n",
               first, last,
               ts.pieces.get_bit( first ),
               ts.pieces.get_bit( first + 1 ),
               ts.pieces.get_bit( first + 2 ),
               ts.pieces.get_bit( first + 3 ),
               ts.pieces.get_bit( first + 4 ),
               ts.pieces.get_bit( last ),
               t->is_sequential_download()
              );
//  std::string temp( "Active pieces: " );
//  for ( int i = first; i < last; ++i )
//  {
//      if ( ts.pieces.get_bit( i ) ) temp += boost::lexical_cast<std::string>( i ) + ",";
//  }
//  USE_DEBUG( temp.c_str() );
    return result;
}

//std::string Streamerok::getFileRelPath( int torrentId )
//{
//    std::string path;
//    tInfo *tInf = getHandle( torrentId );
//    if ( !tInf ) return path;
//
//    torrent_handle *t = &tInf->handle;
//    torrent_info ti = t->get_torrent_info();
//    for ( int i = 0; i < ti.num_files(); ++i )
//    {
//        if ( t->file_priority( i ) == 0 ) continue;
//        const file_entry file = ti.file_at( i );
//        path = file.path;
//        break;
//    }
//    if ( !isExistsAndNotEmpty( getTempDir() + "\\" + path ) ) return std::string();
//    return path;
//}

std::string Streamerok::getFileUrl( int torrentId )
{
    tAux *tInf = getAux( torrentId );
    if ( !tInf ) return std::string();

    if ( tInf->fileUri.size() )
    {
//      USE_DEBUG( "GetUrl: already made\n" );
        return tInf->fileUri;
    }

    if ( !tInf->canGetUrl() )
    {
//      USE_DEBUG( "GetUrl: no pieces\n" );
        return std::string();
    }

    torrent_handle *t = &tInf->handle;
    if ( !t || !t->is_valid() )
    {
//      USE_DEBUG( "GetUrl: torrent is invalid\n" );
        return std::string();
    }
    torrent_info ti = t->get_torrent_info();
    const file_entry file = ti.file_at( tInf->fileIndex );
    std::string path = file.path;

    if ( !path.size() )
    {
        USE_DEBUG( "GetUrl: torrent is invalid\n" );
        return std::string();
    }
    if ( !isExistsAndNotEmpty( getTempDir() + "\\" + path ) ) return std::string();
    tInf->filePath = path;
    replaceAll( tInf->filePath, "\\", "/" );
    USE_DEBUG( "URL before encoding %s\n", path.c_str() );
#ifdef FILEPATH_IN_URL
    path.insert( 0, "\"" + getTempDir() + "\\" );
    path += "\"";
#else
    path = urlEncode( path );
    path.insert( 0, SocketHandler::getUrlBase() );
#endif
    tInf->fileUri = path;
    USE_DEBUG( "URL made %s\n", path.c_str() );
    return path;
}

bool Streamerok::getFileUrl( int torrentId, char *buffer, int length )
{
    if ( !buffer || !length )
    {
        USE_DEBUG( "getFileUrl buffer error\n" );
        return false;
    }
    *buffer = 0;
    const unsigned int len = length;
    const std::string path = getFileUrl( torrentId );
    if ( !path.size() || path.size() >= len ) return false;
    buffer[path.size()] = 0;
    USE_DEBUG( "getFileUrl have URL\n" );
    return path.copy( buffer, path.size() ) == path.size();
}

tAux* Streamerok::getAuxByUriPath( const char *uri )
{
    if ( !uri || !*uri  ) return 0;
    std::string sUri;
    if ( *uri == '/' ) sUri = std::string( uri + 1 );
    else sUri = std::string( uri );
//  USE_DEBUG( "Searching for uri %s\n", sUri.c_str() );
    BOOST_FOREACH( torrentMap::value_type & v, tMap )
    {
        if ( v.second.filePath.find( sUri ) == std::string::npos )
        {
//          USE_DEBUG( "Skipping file with uri %s\n", v.second.filePath.c_str() );
            continue;
        }
//      USE_DEBUG( "torrent found index %i\n", v.first );
        return &v.second;

//      std::string filePath = getFileRelPath( v.first );
//      if ( !filePath.size() ) continue;ƒ
//      replaceAll( filePath, "\\", "/" );
//      if ( filePath.find( sUri ) == std::string::npos )
//      {
//          USE_DEBUG( "Skipping file with uri %s\n", filePath.c_str() );
//          continue;
//      }
//      USE_DEBUG( "torrent found index %i\n", v.first );
//      return getTorrentInfo( v.first );
    }
    USE_DEBUG( "torrent not found\n" );
    return 0;
}

int Streamerok::getIndexByUriPath( const char *uri )
{
    if ( !uri || !*uri  ) return -1;
    std::string sUri;
    if ( *uri == '/' ) sUri = std::string( uri + 1 );
    else sUri = std::string( uri );
    USE_DEBUG( "Searching for uri %s\n", sUri.c_str() );
    BOOST_FOREACH( torrentMap::value_type & v, tMap )
    {
        if ( v.second.filePath.find( sUri ) == std::string::npos )
        {
            USE_DEBUG( "Skipping file with uri %s\n", v.second.filePath.c_str() );
            continue;
        }
        USE_DEBUG( "torrent found index %i\n", v.first );
        return v.first;

    }
    USE_DEBUG( "torrent not found\n" );
    return -2;

}

NetUsage Streamerok::getNetworkUsage()
{
    session_status ss = ses.status();
    return NetUsageExt( ss.upload_rate, ss.download_rate, ss.total_upload, ss.total_download );
}

bool Streamerok::deleteTorrent( int torrentId )
{
    torrentMap::iterator it = tMap.find( torrentId );
    if ( it == tMap.end() )
    {
        USE_DEBUG( "Can't find data for torrent index %i\n", torrentId );
        return false;
    }
    torrent_handle *t = &it->second.handle;
    const bool hadTorrent = t && t->is_valid();
    //changed by Sad
    //do not delete files on torrent delete
    //if ( hadTorrent ) ses.remove_torrent( *t, session::delete_files );
    if ( hadTorrent ) ses.remove_torrent( *t, 0 );
    else USE_DEBUG( "Cant't associate torrent index %i\n", torrentId );
    tMap.erase( it );
    USE_DEBUG( "Torrent %i removed\n", torrentId );
    return hadTorrent;
}

int getTorrentIndex( const char *uri )
{
    if ( !Streamerok::sPtr ) return -3;
    return Streamerok::sPtr->getIndexByUriPath( uri );
}

unsigned long long getFileSize( int torrentId )
{
    if ( !Streamerok::sPtr ) return 0;
    tAux *ta = Streamerok::sPtr->getAux( torrentId );
    if ( !ta ) return 0;
    return ta->fileSize;
}

int Streamerok::countPieces( libtorrent::bitfield& pieces, int first, int last )
{
    int piecesDone = 0;
    for ( int i = first; i <= last; ++i ) if ( pieces.get_bit( i ) ) ++piecesDone;
        else break;
    return piecesDone;
}

unsigned long long getFileDownloaded( int torrentId )
{
    if ( !Streamerok::sPtr ) return 0;
    tAux *ta = Streamerok::sPtr->getAux( torrentId );
    if ( !ta ) return 0;

    torrent_status ts = ta->handle.status( torrent_handle::query_pieces );
    if ( ta->fileSize == ts.total_wanted_done ) return ta->fileSize;
    return Streamerok::countPieces( ts.pieces, ta->fileFirstPiece, ta->fileLastPiece ) * ta->pieceLength;
}

bool Streamerok::handle_alert( libtorrent::alert *a )
{

    if ( piece_finished_alert *p = alert_cast<piece_finished_alert>( a ) )
    {
       // NSLog( "Piece %d finish alert\n", p->piece_index );
        USE_DEBUG( "Piece %i finish alert\n", p->piece_index );
        BOOST_FOREACH( torrentMap::value_type & v, tMap )
        {
            if ( v.second.handle != p->handle ) continue;
            v.second.prioritize();
//              USE_DEBUG( "Reprioritize\n" );
            return true;
        }
        return true;
    }
//  else if ( torrent_finished_alert *p = alert_cast<torrent_finished_alert>( a ) )
//  {
//      p->handle.set_max_connections( max_connections_per_torrent / 2 );
//
//      // write resume data for the finished torrent
//      // the alert handler for save_resume_data_alert
//      // will save it to disk
//      torrent_handle h = p->handle;
//      h.save_resume_data();
//      ++num_outstanding_resume_data;
//  }
//  else if ( state_update_alert *p = alert_cast<state_update_alert>( a ) )
//  {
//      bool need_filter_update = false;
//      for ( std::vector<torrent_status>::iterator i = p->status.begin();
//            i != p->status.end(); ++i )
//      {
//          boost::unordered_set<torrent_status>::iterator j = all_handles.find( *i );
//          // don't add new entries here, that's done in the handler
//          // for add_torrent_alert
//          if ( j == all_handles.end() ) continue;
//          if ( j->state != i->state
//               || j->paused != i->paused
//               || j->auto_managed != i->auto_managed ) need_filter_update = true;
//          ((torrent_status&) *j) = *i;
//      }
//      if ( need_filter_update ) update_filtered_torrents( all_handles, filtered_handles, counters );
//
//      return true;
//  }
    return false;
}


void Streamerok::peridoicCallback()
{
   // if ( !Streamerok::sPtr ) return;
   // libtorrent::session *ses = this->ses;
    ses.post_torrent_updates();

    std::deque<alert *> alerts;
    ses.pop_alerts( &alerts );
    for ( std::deque<alert *>::iterator i = alerts.begin(), end( alerts.end() ); i != end; ++i )
    {
        TORRENT_TRY
        {
            if ( !handle_alert( *i ) )
            {
//              libtorrent::alert const *a = *i;
//              USE_DEBUG( "Alert not handled %s\n", a->message().c_str() );
            }
        }
           TORRENT_CATCH( std::exception & e )
        {
            (void) e;
            USE_DEBUG( "alert exception\n" );
        }

        delete *i;
    }
    alerts.clear();
}


