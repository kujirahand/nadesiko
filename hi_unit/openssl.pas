unit openssl;

interface

uses
	Windows, SysUtils;

const
	SSL_ERROR_NONE             = 0;
	SSL_ERROR_SSL              = 1;
	SSL_ERROR_WANT_READ        = 2;
	SSL_ERROR_WANT_WRITE       = 3;
	SSL_ERROR_WANT_X509_LOOKUP = 4;
	SSL_ERROR_SYSCALL          = 5; // os error check errno etc
	SSL_ERROR_ZERO_RETURN      = 6;
	SSL_ERROR_WANT_CONNECT     = 7;

type
	PSSL_METHOD = ^TSSL_METHOD;
	TSSL_METHOD = record end;
	PSSL_CTX = ^TSSL_CTX;
	TSSL_CTX = record end;
	PSSL = ^TSSL;
	TSSL = record end;

var
	haveSSL : boolean;
	SSL_new : function (ctx:PSSL_CTX):PSSL;  cdecl;
	SSL_CTX_new : function (method:PSSL_METHOD):PSSL_CTX;  cdecl;
	SSLv23_method : function ():PSSL_METHOD; cdecl;
	SSLv2_client_method : function ():PSSL_METHOD; cdecl;
	SSLv3_client_method : function ():PSSL_METHOD; cdecl;
	SSLv23_client_method : function ():PSSL_METHOD; cdecl;
	SSL_free : procedure (ssl:PSSL); cdecl;
	SSL_CTX_free : procedure (ctx:PSSL_CTX); cdecl;
	SSL_set_fd : function (ssl:PSSL; fd:Integer):Integer; cdecl;
	SSL_connect : function (ssl:PSSL):Integer; cdecl;
	SSL_get_error : function (ssl:PSSL; ret:Integer):Integer; cdecl;
	SSL_shutdown : function (ssl:PSSL):Integer; cdecl;
	SSL_read : function (ssl:PSSL;var data;num:Integer):Integer; cdecl;
	SSL_write : function (ssl:PSSL;var data;num:Integer):Integer; cdecl;
	SSL_pending : function (ssl:PSSL):Integer; cdecl;
	SSL_load_error_strings : procedure (); cdecl;
	SSL_library_init : function ():Integer; cdecl;

implementation

var
	hOpenSSL : HMODULE;

initialization
	hOpenSSL := 0;
	haveSSL := false;
	hOpenSSL := LoadLibrary(PChar('ssleay32.dll'));
	if hOpenSSL <> 0 then
	begin
		SSL_new := GetProcAddress(hOpenSSL,'SSL_new');
		SSL_free := GetProcAddress(hOpenSSL,'SSL_free');
		SSL_CTX_new := GetProcAddress(hOpenSSL,'SSL_CTX_new');
		SSL_CTX_free := GetProcAddress(hOpenSSL,'SSL_CTX_free');
		SSLv23_method := GetProcAddress(hOpenSSL,'SSLv23_method');
		SSLv2_client_method := GetProcAddress(hOpenSSL,'SSLv2_client_method');
		SSLv3_client_method := GetProcAddress(hOpenSSL,'SSLv3_client_method');
		SSLv23_client_method := GetProcAddress(hOpenSSL,'SSLv23_client_method');
		SSL_set_fd := GetProcAddress(hOpenSSL,'SSL_set_fd');
		SSL_connect := GetProcAddress(hOpenSSL,'SSL_connect');
		SSL_get_error := GetProcAddress(hOpenSSL,'SSL_get_error');
		SSL_shutdown := GetProcAddress(hOpenSSL,'SSL_shutdown');
		SSL_read := GetProcAddress(hOpenSSL,'SSL_read');
		SSL_write := GetProcAddress(hOpenSSL,'SSL_write');
		SSL_pending := GetProcAddress(hOpenSSL,'SSL_pending');
		SSL_load_error_strings := GetProcAddress(hOpenSSL,'SSL_load_error_strings');
		SSL_library_init := GetProcAddress(hOpenSSL,'SSL_library_init');
		if  (@SSL_new=nil) or (@SSL_free=nil) or (@SSL_CTX_new=nil)
		     or (@SSL_CTX_free=nil) or (@SSLv23_method=nil) or (@SSL_set_fd=nil)
		     or (@SSL_connect=nil) or (@SSL_get_error=nil) or (@SSL_shutdown=nil)
		     or (@SSL_read=nil) or (@SSL_write=nil) or (@SSL_pending=nil)
		     or (@SSL_load_error_strings=nil) or (@SSL_library_init=nil) then
		begin
		end else begin
			haveSSL := true;
		end;
		if haveSSL then
		begin
			SSL_load_error_strings();
			SSL_library_init();
		end;
	end;
	if not haveSSL then
	begin
		if hOpenSSL<>0 then
		begin
			FreeLibrary(hOpenSSL);
			hOpenSSL:=0;
		end;
	end;

finalization
	if hOpenSSL <> 0 then
	begin
		FreeLibrary(hOpenSSL);
		hOpenSSL := 0;
		haveSSL := false;
	end;
end.
