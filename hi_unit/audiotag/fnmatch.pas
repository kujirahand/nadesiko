unit fnmatch;

interface
	uses Classes, Windows;
	function Glob(Const _path, _patterns: String; Const _delimiter: String = ';'): Boolean;

implementation
	uses
		SysUtils, StrUtils;

function AnsiRPos(s, t: PChar): PChar;
var
	i: Integer;
	tmp: PChar;
begin
	tmp := s;
	i := 0;
	Result := Nil;
	repeat
		tmp := SearchBuf(s, StrLen(s), 0, i, t);
		if (tmp <> Nil) then begin
			Result := tmp;
			if (Windows.IsDBCSLeadByte(Byte(t[0]))) then
				i := Cardinal(tmp)-Cardinal(s) + 2
			else
				i := Cardinal(tmp)-Cardinal(s) + 1;
		end;
	until (tmp = Nil);
end;

function GlobInner(Const _path: PChar; Const _pattern: PChar): Boolean;
var
	path, pattern: PChar;
	len, tmp : Integer;
begin
	Result := False;
	path := _path;
	pattern := _pattern;
	if (path <> Nil) and (pattern <> Nil) then try
		while (path[0] <> #0) do begin
			if (pattern[0] = #0) then Exit;
			if			(pattern[0] = '?') then
			else if (pattern[0] = '*') then begin
				pattern := Windows.CharNext(pattern);
				if (AnsiCompareText(pattern, '') = 0) then begin Result := True; Exit; end;	// ワイルドカードの直後が終端なら検索の必要無し
				len := StrLen(pattern);
				tmp := AnsiPos('*', pattern);
				if (tmp <> 0) then len := tmp-1;
				tmp := AnsiPos('?', pattern);
				if (tmp <> 0) then len := tmp-1;
				path := AnsiRPos(path, PChar(Copy(pattern, 1, len)));
				if (path = Nil) then Exit;
				path := path+len;
				path := Windows.CharPrev(_path, path);
				pattern := pattern+len;
				pattern := Windows.CharPrev(_pattern, pattern);
			end else begin
				if (AnsiUpperCase(LeftStr(path, 1)) <> AnsiUpperCase(LeftStr(pattern, 1))) then Exit;
			end;
			pattern := Windows.CharNext(pattern);
			path := Windows.CharNext(path);
		end;
		Result := (AnsiCompareText(pattern, '') = 0) or (AnsiCompareText(pattern, '*') = 0);	// パターンも終端していればヒット
	finally
	end;
end;

function Glob(Const _path, _patterns: String; Const _delimiter: String = ';'): Boolean;
var
	i: Integer;
	pattern, patterns: String;
begin
	Result := False;
	SetLength(patterns, Length(_patterns)+1);
	StrCopy(PChar(patterns), PChar(_patterns));
	repeat
		i := AnsiPos(_delimiter, patterns);
		if (i <> 0) then begin
			pattern := Copy(patterns, 0, i-1);
			patterns := Copy(patterns, i+1, StrLen(PChar(patterns))-(i-1));
		end else begin
			pattern := patterns;
		end;
		if (GlobInner(PChar(_path), PChar(pattern))) then begin
			Result := True;
			Break;
		end;
	until (i = 0);
end;

end.
