unit dll_audiotag_function;

interface
uses
  Windows, SysUtils, dll_plugin_helper,
  dnako_import, dnako_import_types, Classes;

procedure RegistFunction;

implementation

uses sMediaTagReader, unit_string, jconvert;

function cmd_getMediaTag(h: DWORD): PHiValue; stdcall;
var
  mt: TsMediaTagReader;
  p: PHiValue;
  wv: WideString;
  fname,ret,prop: string;
  i: Integer;
  props: TStringList;
begin
  Result := nil;
  //
  p := nako_getFuncArg(h, 0);
  if p = nil then p := nako_getSore;
  fname := hi_str(p);
  if CheckFileExists(fname) = False then
  begin
    raise Exception.Create('�t�@�C���u'+fname+'�v��������܂���B');
  end;
  //
  ret := '';
  mt := TsMediaTagReader.Create;
  try
    try
      if not mt.LoadFromFile(fname) then Exit;
    except
      //�G���[�Ȃ��nil��Ԃ�
      Exit;
    end;
    props := mt.EnumProperties;
    try
      for i := 0 to props.Count - 1 do
      begin
        try
          prop := props.Strings[i];
          wv := mt.GetProperty(prop);
          if wv <> '' then begin
            ret := ret + prop + '=' + ConvertJCode(wv, SJIS_OUT) + #13#10;
          end;
        except
        end;
      end;
    finally
      props.Free;
    end;
    Result := hi_newStr(ret);
  finally
    mt.Free;
  end;
end;

function cmd_setMediaTag(h: DWORD): PHiValue; stdcall;
var
  mt: TsMediaTagReader;
  pf, ps: PHiValue;
  fname,v,prop: string;
  i: Integer;
  props: TStringList;
begin
  ps := nako_getFuncArg(h, 0);
  pf := nako_getFuncArg(h, 1);
  if ps = nil then ps := nako_getSore;
  fname := hi_str(pf);
  if CheckFileExists(fname) = False then
  begin
    raise Exception.Create('�t�@�C���u'+fname+'�v��������܂���B');
  end;
  //
  mt := TsMediaTagReader.Create;
  try
    mt.LoadFromFile(fname);

    props := TStringList.Create;
    try
      props.Text := Trim(hi_str(ps));
      for i := 0 to props.Count - 1 do
      begin
        v := props.Strings[i];
        prop := getToken_s(v, '=');
        mt.SetProperty(prop, v);
      end;
    finally
      props.Free;
    end;

    mt.SaveToFile(fname);
  finally
    mt.Free;
  end;
  Result := nil;
end;

procedure RegistFunction;
begin
  //todo: ���ߒǉ�
  // tag = 4500-4519
  //<����>
  //+���f�B�A�^�O(audiotag.dll)
  //-���f�B�A�^�O
  AddFunc('���f�B�A�^�O�擾','{=?}F��|F����',4500,cmd_getMediaTag,'MP3/WMA/Ogg/AAC/CDA/WAV/TwinVQ�t�@�C���̃^�O����ǂݎ���ăn�b�V���`���ŕԂ��B','�߂ł�����������Ƃ�');
  AddFunc('���f�B�A�^�O�ݒ�','{=?}S��F��|F��',4501,cmd_setMediaTag,'MP3�t�@�C��F�փ^�O���S(�n�b�V���`��)����������','�߂ł������������Ă�');
  //</����>

end;


end.
