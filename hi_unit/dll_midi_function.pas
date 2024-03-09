unit dll_midi_function;

interface

uses
  Windows, SysUtils, Classes, mmsystem;

type
  proc_MMLtoMIDI    = function (MMLText: PChar; FileName: PChar; ErrMsg: PChar): Boolean; stdcall;
  proc_SetErrMsgLen = procedure (mLen: Integer); stdcall;

procedure InitSakura;
procedure RegistFunction;

implementation

uses
  dll_plugin_helper, dnako_import, dnako_import_types, Variants,
  mini_file_utils;

const
  DLL_SAKURA = 'dSakura.dll';

var
  MMLtoMIDI    : proc_MMLtoMIDI = nil;
  SetErrMsgLen : proc_SetErrMsgLen = nil;

//MML��������AMIDI�t�@�C���ɕϊ�����
//function MMLtoMIDI(MMLText: PChar; FileName: PChar; ErrMsg: PChar): Boolean; stdcall; external DLL_SAKURA;
//procedure SetErrMsgLen(mLen: Integer); stdcall; external DLL_SAKURA;


function nako_mciSend(cmd: string): string;
begin
  SetLength(Result, 4096);
  if mciSendString(PChar(cmd), PChar(Result), Length(Result), 0) <> 0 then
  begin
    raise Exception.Create('MCI�R�}���h�G���[�B' + string(PChar(Result)));
  end else
  begin
    Result := string(PChar(Result));
  end;
end;

var playmml_opened: Boolean = False;

function cmd_playmml(h: DWORD): PHiValue; stdcall;
var
  mml: string;
  err, tmp: string;
begin
  InitSakura;
  if playmml_opened then
  begin
    nako_mciSend('close mmlplayer');
  end;

  // GET TEMP FILE
  tmp := TempDir + 'nadesiko_sakura' + FloatToStr(Now) + '.mid';
  // Error
  SetLength(err, 1024 * 8);
  if @SetErrMsgLen <> nil then
  begin
    SetErrMsgLen(1024 * 8);
  end;
  // Compile
  mml := getArgStr(h, 0, True);
  if (not MMLtoMIDI(PChar(mml), PChar(tmp), PChar(err))) then
  begin
    raise Exception.Create(Trim(err));
  end;
  nako_mciSend(Format('open "%S" alias mmlplayer',[tmp]));
  nako_mciSend('play mmlplayer');
  playmml_opened := True;
  Result := nil;
end;

function cmd_mml2midi(h: DWORD): PHiValue; stdcall;
var
  mml, midi: string;
  err:string;
begin
  InitSakura;
  // Error
  SetLength(err, 1024 * 8);
  SetErrMsgLen(1024 * 8);
  // Compile
  mml  := getArgStr(h, 0, True);
  midi := getArgStr(h, 1);
  if not MMLtoMIDI(PChar(mml), PChar(midi), PChar(err)) then
  begin
    raise Exception.Create(Trim(err));
  end;
  Result := nil;
end;


procedure RegistFunction;
begin
  //:::::::nakomidi.dll,4651-4700
  //todo: ���߂̒�`
  //<����>
  //+MIDI(nakomidi.dll)
  //-�T�N��MML
  AddFunc('MML���t', '{=?}MML��|MML��|MML��',  7000, cmd_playmml, '�h���~�̃e�L�X�g(MML)�����t����B','MML���񂻂�', 'nakomidi.dll,dSakura.dll');
  AddFunc('MML�ϊ�', '{=?}MML����MIDI��',  7001, cmd_mml2midi, '�h���~�̃e�L�X�g(MML)��MIDI�t�@�C���Ƃ��ĕۑ�����B','MML�ւ񂩂�', 'nakomidi.dll,dSakura.dll');
  //</����>
end;

var
 dsakura_dll_handle: THandle = 0;

procedure InitSakura;
var
  dll: string;
begin
  // find dll
  dll := FindDLLFile(DLL_SAKURA);
  // add report
  nako_reportDLL(PChar(dll));
  // load
  dsakura_dll_handle := LoadLibrary(PChar(dll));
  if dsakura_dll_handle = 0 then
  begin
    dsakura_dll_handle := LoadLibrary(DLL_SAKURA);
  end;
  if dsakura_dll_handle = 0 then
  begin
    raise Exception.Create('MML�ϊ�DLL�udSakura.dll�v����������܂���B');
  end;
  // import
  if dsakura_dll_handle <> 0 then
  begin
    MMLtoMIDI    := GetProcAddress(dsakura_dll_handle, 'MMLtoMIDI');
    SetErrMsgLen := GetProcAddress(dsakura_dll_handle, 'SetErrMsgLen');
  end;
end;


initialization
  // ���ߎ��s���Ƀ��[�h

finalization
begin
  if dsakura_dll_handle <> 0 then FreeLibrary(dsakura_dll_handle);
end;

end.
