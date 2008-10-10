(*********************************************************************

  heStrConsts.pas

  start  2001/10/19
  update 2001/10/20

  Copyright (c) 2001 本田勝彦 <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor システムで使用される文字列定数が記述されている。

**********************************************************************)

unit heStrConsts;

interface

const

  // HEditor.pas TEditorPopupMenu Captions
  PopupMenu_MarkSet          = 'マーク設定';
  PopupMenu_MarkJump         = 'マークジャンプ';
  PopupMenu_Undo             = '元に戻す(&U)';
  PopupMenu_Redo             = 'やり直し(&R)';
  PopupMenu_Cut              = '切り取り(&T)';
  PopupMenu_Copy             = 'コピー(&C)';
  PopupMenu_Paste            = '貼り付け(&P)';
  PopupMenu_BoxPaste         = 'Box貼り付け(&B)';
  PopupMenu_Delete           = '削除(&D)';
  PopupMenu_SelectAll        = 'すべて選択(&A)';
  PopupMenu_BoxSelectionMode = 'Box選択モード(&K)';

  // HEditor.pas, HViewEdt.pas TEditorWrapOption
  WrapOption_Default_FollowStr      = '、。，．・？！゛゜ヽヾゝゞ々ー）］｝」』!),.:;?]}｡｣､･ｰﾞﾟ';
  WrapOption_Default_LeadStr        = '（［｛「『([{｢';
  WrapOption_Default_PunctuationStr = '、。，．,.｡､';


  // heStringList.pas
  heStringList_ListIndexError = 'リストのインデックスが範囲を超えています';

  // HStrProp.pas
  StrProp_Line         = '  行';
  StrProp_Modified     = '変更';
  StrProp_Overwrite    = '上書き';
  StrProp_Insert       = '挿入';
  StrProp_Box          = '矩形';
  StrProp_SearchString = '検索文字列　'' ';
  StrProp_Isnotfound   = 'は見つかりませんでした。';
  StrProp_To           = '  を';
  StrProp_Doreplace    = '   に 置き換えますか？';

  // HPropert.pas
  EditorComponentEditor_Verbstr = ' の編集(&H)';

  // HViewEdt
  ViewEdit_SelectedArea = '選択領域';     //  8 byte hard coded
  ViewEdit_HitString    = '検索一致文字'; // 12 byte hard coded
  ViewEdit_BracketError = '空白・同一の LeftBracket, RightBracket は指定出来ません。';
  ViewEdit_Editor_FontSample_Lines =
    'abcdefghijklmnopqrstuvwxyz' + #13#10 +
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + #13#10 +
    'いろはにほへとちりぬるをよ' + #13#10 +
    'イロハニホヘトチルヌルヲヨ';
  ViewEdit_Editor_SelMove_Lines =
    '  選択領域のマウス' + #13#10 +
    'ドラッグ' + #13#10 +
    'Drag&Drop';
  ViewEdit_Editor_Colors_Lines =
    '選択領域  String  #13#10' + #13#10 +
    '0123456789  AF' + #13#10 +
    'Editor1.View.Brackets[0]   Commentline' + #13#10 +
    'http://member.nifty.ne.jp/~katsuhiko' + #13#10 +
    'katsuhiko.honda@nifty.ne.jp' + #13#10 +
    '全角文字 Reserve 予約語 検索一致文字';

implementation
end.
