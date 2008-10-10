unit unit_content_type;

interface

uses
  SysUtils;

function getContentType(fname: string): string;

implementation

function getContentType(fname: string): string;
var
  e, s:string;
begin
  e := ExtractFileExt(fname);
  e := LowerCase(e);
  s := 'application/octet-stream';
  // image
  if (e = '.jpeg') or (e = '.jpg') or (e = '.jpe') then s := 'image/jpeg'
  else if (e = '.bmp') then s := 'image/x-bmp'
  else if (e = '.gif') then s := 'image/gif'
  else if (e = '.png') then s := 'image/x-png'
  // text
  else if (e = '.css')                                  then s := 'text/css'
  else if (e = '.tex') then s := 'application/x-latex'
  else if (e = '.pdf') then s := 'application/pdf'
  else if (e = '.ps')or(e = '.eps') then s := 'application/postscript'
  else if (e = '.rtf') then s := 'application/rtf'
  else if (e = '.txt') then s := 'text/plain'
  else if (e = '.doc') then s := 'application/msword'
  else if (e = '.xls') then s := 'application/msexcel'
  else if (e = '.xml') then s := 'text/xml'
  else if (e = '.htm') or (e = '.html')                 then s := 'text/html'
  // movie
  else if (e = '.mpeg') or (e = '.mpg') or (e = '.mpe') then s := 'video/mpeg'
  else if (e = '.qt')   or (e = '.mov')                 then s := 'video/quicktime'
  else if (e = '.mng')                                  then s := 'video/x-mng'
  else if (e = '.asf')  or (e = '.asx')                 then s := 'video/x-ms-asf'
  else if (e = '.avi')                                  then s := 'video/x-msvideo'
  else if (e = '.sgm')or(e = '.sgml') then s := 'text/sgml'
  else if (e = '.tsv') then s := 'text/tab-separated-values'
  else if (e = '.jar') then s := 'application/java-archiver'
  else if (e = '.gz') then s := 'application/gzip'
  else if (e = '.hqx') then s := 'application/mac-binhex40'
  else if (e = '.sit') then s := 'application/x-stuffit'
  else if (e = '.tar') then s := 'application/x-tar'
  else if (e = '.zip') then s := 'application/zip'
  else if (e = '.tif')or(e = '.tiff') then s := 'image/tiff'
  else if (e = '.aiff') then s := 'audio/aiff'
  else if (e = '.mid') then s := 'audio/midi'
  else if (e = '.mp3') then s := 'audio/mpeg'
  else if (e = '.wav') then s := 'audio/wav'
  else if (e = '.swf') then s := 'application/x-shockwave-flash'
  else if (e = '.3gp')or(e = '.3g2') then s := 'video/x-3gp'
  ;;
  Result := s;
end;

end.
