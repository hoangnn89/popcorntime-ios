#include "common.h"

#import <Foundation/Foundation.h>

#include "boost/filesystem.hpp"

boost::filesystem::path tempDir;

bool isExistsAndNotEmpty( std::string filePath )
{
    boost::filesystem::path path( filePath );
    boost::system::error_code ec;
    if ( !boost::filesystem::exists( path, ec ) ) return false;
    if ( boost::filesystem::is_empty( path, ec ) ) return false;
    return true;
}

bool tempDirValid() { return !tempDir.empty() && boost::filesystem::exists( tempDir ) && boost::filesystem::is_directory( tempDir ); }
std::string getTempDir()
{
    return tempDir.string();

}
void cleanTempDir() { if ( tempDirValid() ) boost::filesystem::remove_all( tempDir ); }

void checkTempDir()
{
    if ( tempDirValid() ) return;
    USE_DEBUG( "Making temp dir\n" );
    boost::system::error_code ec;
    tempDir = boost::filesystem::unique_path( boost::filesystem::temp_directory_path( ec ) / "%%%%-%%%%-%%%%" );
    if ( !boost::filesystem::create_directory( tempDir, ec ) || ec ) USE_DEBUG( "Failed creating\n" );
    USE_DEBUG( "TempPath is %s, %s, %s, %s\n", tempDir.empty() ? "empty" : "ok",
               boost::filesystem::is_directory( tempDir ) ? "dir" : "not dir",
               boost::filesystem::exists( tempDir ) ? "exists" : "not exists",
               tempDir.string().c_str() );
}


void DbgPrint( const char *FormatString, ... )
{
#ifdef DEBUG
    char *dbgout = new char[1024];
    va_list  vaList;

    va_start( vaList, FormatString );
   printf( dbgout, FormatString, vaList );
  
    printf(FormatString,vaList);
    va_end( vaList );

    delete[] dbgout;
#endif
}

void replaceAll( std::string& str, const std::string& from, const std::string& to )
{
    if ( from.empty() ) return;
    size_t start_pos = 0;
    while ( (start_pos = str.find( from, start_pos )) != std::string::npos )
    {
        str.replace( start_pos, from.length(), to );
        start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
    }
}
