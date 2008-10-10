unit dll_msagent_function;

interface

uses
  Windows,
  SysUtils,
  ms_agent,
  shellapi,
  dll_plugin_helper, dnako_import, dnako_import_types;


procedure RegistFunction;

implementation


function cmd_call_marlin(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentLoad('Merlin', 'Merlin.acs');
  ms_agent.AgentShow;
end;

function cmd_fin(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentFin;
end;

function cmd_call(HandleArg: DWORD): PHiValue; stdcall;
var
  pFile, pName: PHiValue;
begin
  Result := nil;
  pFile := nako_getFuncArg(HandleArg, 0);
  pName := nako_getFuncArg(HandleArg, 1);

  ms_agent.AgentLoad(hi_str(pName), hi_str(pFile));
  ms_agent.AgentShow;
end;

function cmd_show(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentShow;
end;

function cmd_hide(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentHide;
end;

function cmd_action(h: DWORD): PHiValue; stdcall;
var s: string;
begin
  Result := nil;

  s := getArgStr(h, 0, True);
  s := DeleteGobi(s);

  if s = '混乱'     then s := 'Confused' else
  if s = '祝福'     then s := 'Congratulate' else
  if s = '説明'     then s := 'Explain' else
  if s = '挨拶'     then s := 'Greet' else
  if s = '発表'     then s := 'Announce' else
  if s = '読'       then s := 'Read' else
  if s = '書'       then s := 'Write' else
  if s = '休'       then s := 'RestPose' else
  if s = '驚'       then s := 'Surprised' else
  ;
  
  ms_agent.AgentPlay(s);
end;

function cmd_say(HandleArg: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeak(getArgStr(HandleArg, 0, True));
end;

function cmd_move(HandleArg: DWORD): PHiValue; stdcall;
var px,py: PHiValue;
begin
  Result := nil;
  px := nako_getFuncArg(HandleArg, 0);
  py := nako_getFuncArg(HandleArg, 1);
  ms_agent.AgentMoveTo(hi_int(px),hi_int(py));
end;

function cmd_language(h: DWORD): PHiValue; stdcall;
var
  s: string;
  id: Integer;
begin
  Result := nil;
  s := getArgStr(h, 0, True);
  if s = '日本語' then id := $0411 else
  if s = '英語'   then id := $0409 else
  if s = '中国語'   then id := $0804 else
  if s = '韓国語'   then id := $0412 else id := StrToIntDef(s, $0411);
  ms_agent.AgentChangeLanguage(id);
end;

function cmd_stop(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentStopAll;
end;

function cmd_size(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSize(getArgInt(h,0),getArgInt(h,1));
end;

function cmd_waitfor(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentWaitFor;
end;

function cmd_tone(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeakPitch(getArgInt(h,0));
end;

function cmd_speed(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ms_agent.AgentSpeakSpeed(getArgInt(h,0));
end;

function cmd_info(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newStr(ms_agent.AgentGetInfo);
end;

function cmd_checkComponent(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckInstall);
end;

function cmd_checkLang(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckInstallLanguage(getArgStr(h,0,True)));
end;

function cmd_checkSAPI(h: DWORD): PHiValue; stdcall;
begin
  Result := hi_newBool(ms_agent.AgentCheckSAPI);
end;

function cmd_showDownloadWEB(h: DWORD): PHiValue; stdcall;
begin
  Result := nil;
  ShellExecute(0, 'open', 'http://www.microsoft.com/msagent/downloads/user.asp', '', '', SW_SHOW);
end;

procedure RegistFunction;
begin
  //todo: 命令追加
  //4520-4599
  //<命令>
  //+MS Agent(msagent.dll)
  //-MS Agent
  AddFunc('エージェントマーリン召喚','',4520,cmd_call_marlin,'MSエージェントの標準キャラクター「マーリン」を表示する','えーじぇんとまーりんしょうかん');
  AddFunc('エージェント終了','',4521,cmd_fin,'MSエージェントの機能を終了する','えーじぇんとしゅうりょう');
  AddFunc('エージェント召喚','AからBを|AでBの',4522, cmd_call, '定義ファイル(*.acs)AからキャラクターBを表示する','えーじぇんとしょうかん');
  AddFunc('エージェント表示','',4523, cmd_show, 'エージェントを表示する','えーじぇんとひょうじ');
  AddFunc('エージェント非表示','',4524, cmd_hide, 'エージェントを非表示にする','えーじぇんとひひょうじ');
  AddFunc('エージェント動作','{=?}Sの',4525, cmd_action, 'エージェントにSの動作()をさせる','えーじぇんとどうさ');
  AddFunc('エージェント言う','{=?}Sを|Sと',4526, cmd_say, 'エージェントにSを発声させる','えーじぇんという');
  AddFunc('エージェント移動','X,Yへ',4527, cmd_move, 'エージェントをX,Yへ移動させる','えーじぇんといどう');
  AddFunc('エージェント言語変更','{=?}Sへ|Sに|Sで',4528, cmd_language, 'エージェントの話す言語を(日本語|英語|中国語|韓国語|その他のID)?に変更する','えーじぇんとげんごへんこう');
  AddFunc('エージェント止める','',4529, cmd_stop, 'エージェントが話すのを止める。','えーじぇんととめる');
  AddFunc('エージェント待つ','',4530, cmd_waitfor, 'エージェントの行動が終わるのを待つ。','えーじぇんとまつ');
  AddFunc('エージェントサイズ変更','W,Hに|Hへ',4531, cmd_size, 'エージェントのサイズをW,Hに変更する。','えーじぇんとさいずへんこう');
  AddFunc('エージェントトーン変更','Aへ',4532, cmd_tone, 'エージェントの声のトーンを変更する。','えーじぇんととーんへんこう');
  AddFunc('エージェント速度変更','Aへ',4533, cmd_speed, 'エージェントの話す速さを変更する。','えーじぇんとそくどへんこう');
  AddFunc('エージェント情報取得','',4534, cmd_info, 'エージェントの情報を取得してハッシュ形式で返す。','えーじぇんとじょうほうしゅとく');
  AddFunc('エージェント動作チェック','',4535, cmd_checkComponent, 'エージェントがインストールされているかチェックして返す','えーじぇんとどうさちぇっく');
  AddFunc('エージェント言語チェック','{=?}Sの|Sで|Sに|Sへ',4536, cmd_checkLang, 'エージェントの言語(日本語|英語|中国語|韓国語|その他のID)がインストールされているかチェックして返す','えーじぇんとげんごちぇっく');
  AddFunc('エージェントSAPIチェック','',4537, cmd_checkSAPI, 'エージェントが話すことができるか(SAPI.DLL)があるかチェックして返す','えーじぇんとSAPIちぇっく');
  AddFunc('エージェントダウンロードサイト開く','',4538, cmd_showDownloadWEB, 'エージェントのダウンロードサイトを開く','えーじぇんとだうんろーどさいとひらく');
  //</命令>

end;

end.
