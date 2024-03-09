(*********************************************************************

  heStrConsts.pas

  start  2001/10/19
  update 2001/10/20

  Copyright (c) 2001 �{�c���F <katsuhiko.honda@nifty.ne.jp>

  --------------------------------------------------------------------
  TEditor �V�X�e���Ŏg�p����镶����萔���L�q����Ă���B

**********************************************************************)

unit heStrConsts;

interface

const

  // HEditor.pas TEditorPopupMenu Captions
  PopupMenu_MarkSet          = '�}�[�N�ݒ�';
  PopupMenu_MarkJump         = '�}�[�N�W�����v';
  PopupMenu_Undo             = '���ɖ߂�(&U)';
  PopupMenu_Redo             = '��蒼��(&R)';
  PopupMenu_Cut              = '�؂���(&T)';
  PopupMenu_Copy             = '�R�s�[(&C)';
  PopupMenu_Paste            = '�\��t��(&P)';
  PopupMenu_BoxPaste         = 'Box�\��t��(&B)';
  PopupMenu_Delete           = '�폜(&D)';
  PopupMenu_SelectAll        = '���ׂđI��(&A)';
  PopupMenu_BoxSelectionMode = 'Box�I�����[�h(&K)';

  // HEditor.pas, HViewEdt.pas TEditorWrapOption
  WrapOption_Default_FollowStr      = '�A�B�C�D�E�H�I�J�K�R�S�T�U�X�[�j�n�p�v�x!),.:;?]}�������';
  WrapOption_Default_LeadStr        = '�i�m�o�u�w([{�';
  WrapOption_Default_PunctuationStr = '�A�B�C�D,.��';


  // heStringList.pas
  heStringList_ListIndexError = '���X�g�̃C���f�b�N�X���͈͂𒴂��Ă��܂�';

  // HStrProp.pas
  StrProp_Line         = '  �s';
  StrProp_Modified     = '�ύX';
  StrProp_Overwrite    = '�㏑��';
  StrProp_Insert       = '�}��';
  StrProp_Box          = '��`';
  StrProp_SearchString = '����������@'' ';
  StrProp_Isnotfound   = '�͌�����܂���ł����B';
  StrProp_To           = '  ��';
  StrProp_Doreplace    = '   �� �u�������܂����H';

  // HPropert.pas
  EditorComponentEditor_Verbstr = ' �̕ҏW(&H)';

  // HViewEdt
  ViewEdit_SelectedArea = '�I��̈�';     //  8 byte hard coded
  ViewEdit_HitString    = '������v����'; // 12 byte hard coded
  ViewEdit_BracketError = '�󔒁E����� LeftBracket, RightBracket �͎w��o���܂���B';
  ViewEdit_Editor_FontSample_Lines =
    'abcdefghijklmnopqrstuvwxyz' + #13#10 +
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + #13#10 +
    '����͂ɂقւƂ���ʂ����' + #13#10 +
    '�C���n�j�z�w�g�`���k������';
  ViewEdit_Editor_SelMove_Lines =
    '  �I��̈�̃}�E�X' + #13#10 +
    '�h���b�O' + #13#10 +
    'Drag&Drop';
  ViewEdit_Editor_Colors_Lines =
    '�I��̈�  String  #13#10' + #13#10 +
    '0123456789  AF' + #13#10 +
    'Editor1.View.Brackets[0]   Commentline' + #13#10 +
    'http://member.nifty.ne.jp/~katsuhiko' + #13#10 +
    'katsuhiko.honda@nifty.ne.jp' + #13#10 +
    '�S�p���� Reserve �\��� ������v����';

implementation
end.
