//====================================================================
//    ZLIB  ヘッダ     ZLIB ver 1.1.3 対応版
//                                             2001.07.04
//====================================================================

unit TkZLIB;

interface

type
  TZLIBAlloc = function (AppData: Pointer; Items, Size: Integer): Pointer;
  TZLIBFree = procedure (AppData, Block: Pointer);

  // Internal structure.  Ignore.
  TZStreamRec = packed record
    next_in: PChar;       // next input byte
    avail_in: Integer;    // number of bytes available at next_in
    total_in: Integer;    // total nb of input bytes read so far

    next_out: PChar;      // next output byte should be put here
    avail_out: Integer;   // remaining free space at next_out
    total_out: Integer;   // total nb of bytes output so far

    msg: PChar;           // last error message, NULL if no error
    internal: Pointer;    // not visible by applications

    zalloc: TZLIBAlloc;   // used to allocate the internal state
    zfree: TZLIBFree;     // used to free the internal state
    AppData: Pointer;     // private data object passed to zalloc and zfree

    data_type: Integer;   //  best guess about the data type: ascii or binary
    adler: Integer;       // adler32 value of the uncompressed data
    reserved: Integer;    // reserved for future use
  end;

const
  ZLIB_VERSION: pchar='1.1.2';

const
  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;

  Z_OK            = 0;
  Z_STREAM_END    = 1;
  Z_NEED_DICT     = 2;
  Z_ERRNO         = (-1);
  Z_STREAM_ERROR  = (-2);
  Z_DATA_ERROR    = (-3);
  Z_MEM_ERROR     = (-4);
  Z_BUF_ERROR     = (-5);
  Z_VERSION_ERROR = (-6);

  Z_NO_COMPRESSION       =   0;
  Z_BEST_SPEED           =   1;
  Z_BEST_COMPRESSION     =   9;
  Z_DEFAULT_COMPRESSION  = (-1);

  Z_FILTERED            = 1;
  Z_HUFFMAN_ONLY        = 2;
  Z_DEFAULT_STRATEGY    = 0;

  Z_BINARY   = 0;
  Z_ASCII    = 1;
  Z_UNKNOWN  = 2;

  Z_DEFLATED = 8;

{$L deflate.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L trees.obj}
{$L adler32.obj}
{$L infblock.obj}
{$L infcodes.obj}
{$L infutil.obj}
{$L inffast.obj}
{$L zutil.obj}
{$L crc32.obj}

function crc32(n1: integer; pp: pointer; n2: integer): integer; external;

procedure _tr_init; external;
procedure _tr_tally; external;
procedure _tr_flush_block; external;
procedure _tr_align; external;
procedure _tr_stored_block; external;
procedure adler32; external;
procedure inflate_blocks_new; external;
procedure inflate_blocks; external;
procedure inflate_blocks_reset; external;
procedure inflate_blocks_free; external;
procedure inflate_set_dictionary; external;
procedure inflate_trees_bits; external;
procedure inflate_trees_dynamic; external;
procedure inflate_trees_fixed; external;
//procedure inflate_trees_free; external;
procedure inflate_codes_new; external;
procedure inflate_codes; external;
procedure inflate_codes_free; external;
procedure _inflate_mask; external;
procedure inflate_flush; external;
procedure inflate_fast; external;

procedure zcAlloc; external;  // この関数は使わないこと
procedure zcFree; external;   // この関数は使わないこと

procedure _memset(P: Pointer; B: Byte; count: Integer);cdecl;
procedure _memcpy(dest, source: Pointer; count: Integer);cdecl;

// deflate compresses data
function deflateInit_(var strm: TZStreamRec; level: Integer; version: PChar;
  recsize: Integer): Integer; external;
function deflateInit2_(var strm: TZStreamRec; level,method,windowBits,memLevel,strategy: integer;
  version: PChar; recsize: Integer): Integer; external;
function deflate(var strm: TZStreamRec; flush: Integer): Integer; external;
function deflateEnd(var strm: TZStreamRec): Integer; external;
function deflateReset(var strm: TZStreamRec): Integer; external;

// inflate decompresses data
function inflateInit_(var strm: TZStreamRec; version: PChar;
  recsize: Integer): Integer; external;
function inflateInit2_(var strm: TZStreamRec; windowBits: Integer; version: PChar;
  recsize: Integer): Integer; external;
function inflate(var strm: TZStreamRec; flush: Integer): Integer; external;
function inflateEnd(var strm: TZStreamRec): Integer; external;
function inflateReset(var strm: TZStreamRec): Integer; external;

function zlibAllocMem(AppData: Pointer; Items, Size: Integer): Pointer;
procedure zlibFreeMem(AppData, Block: Pointer);
function inflateInit(var strm: TZStreamRec): integer;
function inflateInit2(var strm: TZStreamRec; windowBits: integer): integer;
function deflateInit(var strm: TZStreamRec; level: Integer): integer;
function deflateInit2(var strm: TZStreamRec;
 level, method, windowBits, memLevel, strategy: Integer): integer;

implementation

procedure _memset(P: Pointer; B: Byte; count: Integer);cdecl;
begin
  FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: Integer);cdecl;
begin
  Move(source^, dest^, count);
end;

function zlibAllocMem(AppData: Pointer; Items, Size: Integer): Pointer;
begin
  GetMem(Result, Items*Size);
end;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
  FreeMem(Block);
end;


function deflateInit(var strm: TZStreamRec; level: Integer): integer;
begin
 result:=DeflateInit_(strm,level,ZLIB_VERSION,sizeof(TZStreamRec));
end;


function deflateInit2(var strm: TZStreamRec;
 level, method, windowBits, memLevel, strategy: Integer): integer;
begin
 result:=deflateInit2_(strm,level,method,windowBits,memLevel,
                       strategy,ZLIB_VERSION,sizeof(TZStreamRec));
end;


function inflateInit(var strm: TZStreamRec): integer;
begin
 result:=inflateInit_(strm,ZLIB_VERSION,sizeof(TZStreamRec));
end;


function inflateInit2(var strm: TZStreamRec; windowBits: integer): integer;
begin
 result:=inflateInit2_(strm,windowBits,ZLIB_VERSION,sizeof(TZStreamRec));
end;

end.




