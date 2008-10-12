unit unit_kabin;

// ���ƘA�g���邽�߂̉ԕr�T�[�r�X

interface
uses
  SysUtils, Classes, IdTcpServer,
  unit_string, jconvert, md5, json,
  dnako_import, dll_plugin_helper,
  dnako_import_types;

type
  TKabin = class
  public
    server: TIdTcpServer;
    password: string;
    port: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure OnConnect(AThread: TIdPeerThread);
    procedure OnExecute(AThread: TIdPeerThread);
    function getConnectionMD5: string;
  end;

function PHiValue2Json(p: PHiValue): string;
function Json2PHiValue(json: string): PHiValue;
function JsonObject2PHiValue(obj: TJsonObject): PHiValue;

implementation

uses jconvertex;


function PHiValue2Json(p: PHiValue): string;
var
  s, key: string;
  i: Integer;
  p2: PHiValue;
begin
  if (p = nil) or (p.VType = varNil) then
  begin
    Result := 'null';
    Exit;
  end;
  if (p.VType = varInt)or(p.VType = varFloat) then
  begin
    Result := hi_str(p);
    Exit;
  end;
  if (p.VType = varStr) then
  begin
    s := hi_str(p);
    s := JReplace(s, '\', '\\');
    s := JReplace(s, #9,  '\t');
    s := JReplace(s, #13, '\r');
    s := JReplace(s, #10, '\n');
    s := JReplace(s, #0,  '\0');
    Result := '"' + hi_str(p) + '"';
    Exit;
  end;
  if (p.VType = varArray) then
  begin
    Result := '';
    for i := 0 to nako_ary_count(p) - 1 do
    begin
      p2 := nako_ary_get(p, i);
      Result := Result + PHiValue2Json(p2) + ',';
    end;
    if Result <> '' then Result := Copy(Result, 1, Length(Result) - 1);
    Result := '[' + Result + ']';
    Exit;
  end;
  if (p.VType = varHash) then
  begin
    Result := '';
    SetLength(s, 1024 * 16);
    nako_hash_keys(p, PChar(s), 1024 * 16);
    while s <> '' do
    begin
      key := getToken_s(s, #13#10);
      SetLength(key, StrLen(PChar(key)));
      p2  := nako_hash_get(p, PChar(key));
      Result := Result + '"' + key + '":' + PHiValue2Json(p2) + ',';
    end;
    if Result <> '' then Result := Copy(Result, 1, Length(Result) - 1);
    Result := '{' + Result + '}';
  end;
end;

function Json2PHiValue(json: string): PHiValue;
var
  obj: TJsonObject;
begin
  try
    obj := TJsonObject.Parse(PChar(json));
    Result := JsonObject2PHiValue(obj);
  except
    Result := nil; Exit;
  end;
end;

function JsonObject2PHiValue(obj: TJsonObject): PHiValue;
var
  ite: TJsonObjectIter;
  i: Integer;
  s: string;
begin
  if obj = nil then
  begin
    Result := nil;
    Exit;
  end;
  case obj.JsonType of
    json_type_null:     Result := nil;
    json_type_boolean:  Result := hi_newBool(obj.AsBoolean);
    json_type_string:
      begin
        s := obj.AsString;
        s := Utf8ToAnsi(s);
        Result := hi_newStr(s);
      end;
    json_type_int:      Result := hi_newInt(obj.AsInteger);
    json_type_double:   Result := hi_newFloat(obj.AsDouble);
    json_type_object:
      begin
        Result := hi_var_new;
        nako_hash_create(Result);
        //
        if JsonFindFirst(obj, ite) then
        begin
          repeat
            nako_hash_set(Result, ite.key, JsonObject2PHiValue(ite.val));
          until not JsonFindNext(ite);
        end;
        JsonFindClose(ite);
      end;
    json_type_array:
      begin
        Result := hi_var_new;
        nako_ary_create(Result);
        //
        with obj.AsArray do
        begin
          for i := 0 to Length - 1 do
          begin
            nako_ary_add(Result, JsonObject2PHiValue(Items[i]));
          end;
        end;
      end;
  end;
end;

{ TKabin }

procedure TKabin.Close;
begin
  server.Active := False;
end;

constructor TKabin.Create;
begin
  server := TIdTCPServer.Create(nil);
  server.OnConnect := OnConnect;
  server.OnExecute := OnExecute;
end;

destructor TKabin.Destroy;
begin
  Close;
  FreeAndNil(server);
  inherited;
end;

const
  crossdomain = '' +
    '<cross-domain-policy>'#13#10+
    '<allow-access-from domain="*" to-ports="*" />'#13#10+
    '</cross-domain-policy>'#0;

function TKabin.getConnectionMD5: string;
var
  str: string;
begin
  str := IntToStr(server.DefaultPort) + ':' + password + ':com.nadesi.kabin';
  Result := MD5StringS( str );
end;

procedure TKabin.OnConnect(AThread: TIdPeerThread);
var
  cmd, line, pw, md5: string;
  json: TJsonObject;
  obj: TJsonTableString;

  procedure err(msg: string);
  begin
    AThread.Connection.Write('{"status":"error","message":"'+msg+'"}'#0);
    AThread.Connection.Disconnect;
  end;
begin
  // Connect Check
  line := AThread.Connection.ReadLn(#0);

  // Check Policy File
  if Copy(Trim(LowerCase(line)),1,20) = '<policy-file-request' then
  begin
    try
      AThread.Connection.Write(crossdomain);
      AThread.Connection.Disconnect;
      Exit;
    except
    end;
  end;

  // Connect ?
  // {command:"password", password:"xxx"}
  try
    json := TJsonObject.Parse(PChar(line));
    obj := json.AsObject;
    if obj = nil then begin err('No Object'); Exit; end;
    cmd := obj.Get('command').AsString;
    pw  := obj.Get('password').AsString;
  except
    err('Only JSON'); Exit;
  end;

  if cmd = 'password' then
  begin
    md5 := getConnectionMd5;
    if pw <> md5 then
    begin
      err('Wrong password'); Exit;
    end;
  end
  else begin
    try
      err('Wrong command'); Exit;
    except
    end;
  end;
  
end;

procedure TKabin.OnExecute(AThread: TIdPeerThread);
var
  line: string;
  funcid: LongWord;
  args: PHiValue;
  cmd, src: string;
  res: PHiValue;
  json: TJsonObject;
  
  procedure err(msg: string);
  begin
    AThread.Connection.Write('{"status":false,"message":"'+msg+'"}'#0);
  end;
  procedure ok_json;
  var
    r: string;
  begin
    r := PHiValue2Json(res);
    r := sjisToUtf8(r);
    AThread.Connection.Write('{"status":true,"result":'+r+'}'#0);
  end;
begin
  //
  json := nil;
  funcid := 0;
  while AThread.Connection.Connected do
  begin
    line := AThread.Connection.ReadLn(#0);
    if line = '' then Continue;

    try
      json := TJsonObject.Parse(PChar(line));
      cmd := json.AsObject.Get('command').AsString;
    except
      err('Wrong Format.');
      Continue;
    end;

    if cmd = 'callbyeval' then
    begin
      try
        src := json.AsObject.Get('source').AsString;
        src := Utf8NTosjis(src);
      except
        err('Wrong Format.');
        Continue;
      end;
      res := nako_eval(PChar(src));
      ok_json;
      Continue;
    end;

    if cmd = 'callbyid' then
    begin
      // get id
      try
        funcid := json.AsObject.Get('id').AsInteger;
        args   := JsonObject2PHiValue(json.AsObject.Get('args'));
      except
        err('Wrong Format.');
        Continue;
      end;
      res := nako_callSysFunction(funcid, args);
      ok_json;
      Continue;
    end;

    err('Unknown command');
  end;
end;

procedure TKabin.Open;
begin
  server.DefaultPort := Port;
  server.Active := True;
end;

end.