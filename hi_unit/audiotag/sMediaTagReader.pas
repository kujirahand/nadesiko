unit sMediaTagReader;
interface

uses
	Classes, SysUtils, sMediaTag;

type
	TsMediaTagReader = class(TObject)
	private
	protected
		fTagObject: TsMediaTag;
	public
		constructor Create(); virtual;
		destructor Destroy(); OverRide;
		function LoadFromFile(const FileName: string): Boolean; virtual;
    function RemoveFromFile(const FileName: string): Boolean; virtual;
    function SaveToFile(const FileName: String): Boolean; virtual;
		function EnumProperties(): TStringList; virtual;
		function GetProperty(Index: String): String; virtual;
		procedure SetProperty(Index: String; Value: String); virtual;
		property Properties[Index: String]: String read GetProperty write SetProperty; default;
	published
	end;


implementation
uses
	TypInfo, StrUtils, Contnrs, fnmatch,
	AACfile, APEtag, CDAtrack, FLACfile, ID3v1, ID3v2, Monkey, MPEGaudio, MPEGplus,
  OggVorbis, TwinVQ, WAVfile, WMAfile, MP4file;

type
	TsMediaTagClass = class of TsMediaTag;

var
	sMediaTagClasses: array [0..11] of TsMediaTagClass =
		(Nil, TWMAfile, TMPEGaudio, TMPEGplus, TMP4file, TOggVorbis,
		TMonkey, TAACfile, TFLACfile, TTwinVQ, TWAVfile, TCDAtrack);

const
	InnerTags: array [0..2] of String = ('ID3v2', 'ID3v1', 'APEtag');


////////////////////////////////////////
// Access to RTTI
//
function GetIntProp(obj: TObject; PropName: String): String;
var
	IntToIdent: TIntToIdent;
begin
	Result := GetPropValue(obj, PropName);
	if PropType(obj, PropName) = tkInteger then begin
		IntToIdent := FindIntToIdent(GetPropInfo(obj, PropName).PropType^);
		if Assigned(IntToIdent) then
			IntToIdent(GetPropValue(obj, PropName), Result);
	end;
end;

function RTTI_GetProperty(Obj: TObject; PropName: String): String;
var
	PropValue: String;
begin
	if not TypInfo.IsPublishedProp(Obj, PropName) then Exit;
	case TypInfo.PropType(Obj, PropName) of
	tkInteger, tkInt64: PropValue := GetIntProp(Obj, PropName);
	tkFloat: PropValue := FloatToStr(GetFloatProp(Obj, PropName));
	tkString, tkLString, tkChar: PropValue := GetStrProp(Obj, PropName);
	tkWString, tkWChar: PropValue := GetWideStrProp(Obj, PropName);
	tkEnumeration: PropValue := GetEnumProp(Obj, PropName);
	tkSet: PropValue := GetSetProp(Obj, PropName);
	//tkClass: TypInfo.SetObjectProp(Obj, Propname, PropValue);
	//tkMethod: TypInfo.SetMethodProp(Obj, Propname, PropValue);
	tkVariant: PropValue := GetVariantProp(Obj, PropName);
	//tkArray: TypInfo.Set(Obj, Propname, PropValue);
	//tkRecord: TypInfo.Set(Obj, Propname, PropValue);
	//tkInterface: TypInfo.SetInterfaceProp(Obj, Propname, PropValue);
	//tkDynArray: TypInfo.Set(Obj, Propname, PropValue);
	end;
	Result := PropValue;
end;
procedure RTTI_SetProperty(Obj: TObject; PropName: String; PropValue: String);
begin
	if not TypInfo.IsPublishedProp(Obj, PropName) then Exit;
	case TypInfo.PropType(Obj, PropName) of
	tkInteger: TypInfo.SetPropValue(Obj, PropName, StrToIntDef(PropValue, 0));
	tkInt64: TypInfo.SetInt64Prop(Obj, PropName, StrToInt64Def(PropValue, 0));
	tkFloat: TypInfo.SetFloatProp(Obj, PropName, StrToFloatDef(PropValue, 0));
	tkString, tkLString, tkChar: TypInfo.SetStrProp(Obj, PropName, PropValue);
	tkWString, tkWChar: TypInfo.SetWideStrProp(Obj, PropName, PropValue);
	tkEnumeration: TypInfo.SetEnumProp(Obj, PropName, PropValue);
	tkSet: TypInfo.SetSetProp(Obj, Propname, PropValue);
	//tkClass: SetClassProp(Obj, Propname, PropValue);
	//tkMethod: TypInfo.SetMethodProp(Obj, Propname, Method(Obj.MethodAddress(PropValue), Obj.FieldAddress(PropValue)));
	tkVariant: TypInfo.SetVariantProp(Obj, Propname, PropValue);
	//tkArray: TypInfo.Set(Obj, Propname, PropValue);
	//tkRecord: TypInfo.Set(Obj, Propname, PropValue);
	//tkInterface: TypInfo.SetInterfaceProp(Obj, Propname, PropValue);
	//tkDynArray: TypInfo.Set(Obj, Propname, PropValue);
	end;
end;


////////////////////////////////////////
// TsMediaTagReader
//
constructor TsMediaTagReader.Create();
begin
	inherited Create();
	fTagObject := Nil;
end;

destructor TsMediaTagReader.Destroy();
begin
	if Assigned(fTagObject) then FreeAndNil(fTagObject);
	inherited Destroy();
end;

function TsMediaTagReader.LoadFromFile(const FileName: String): Boolean;
var
	i: Integer;
begin
	//Result := False;
	if Assigned(fTagObject) then FreeAndNil(fTagObject);
	if					fnmatch.Glob(FileName, '*.aac') then begin
		sMediaTagClasses[0] := TAACfile;
	end else if fnmatch.Glob(FileName, '*.ape') then begin
		sMediaTagClasses[0] := TMonkey;
	end else if fnmatch.Glob(FileName, '*.cda') then begin
		sMediaTagClasses[0] := TCDAtrack;
	end else if fnmatch.Glob(FileName, '*.flac;*.fla') then begin
		sMediaTagClasses[0] := TFLACfile;
	end else if fnmatch.Glob(FileName, '*.ogg') then begin
		sMediaTagClasses[0] := TOggVorbis;
	end else if fnmatch.Glob(FileName, '*.vqf;*.svf') then begin
		sMediaTagClasses[0] := TTwinVQ;
	end else if fnmatch.Glob(FileName, '*.wav') then begin
		sMediaTagClasses[0] := TWAVfile;
	end else if fnmatch.Glob(FileName, '*.asf;*.wma') then begin
		sMediaTagClasses[0] := TWMAfile;
	end else if fnmatch.Glob(FileName, '*.mp?;*.rmp') then begin
		sMediaTagClasses[0] := TMPEGaudio;
	end else if fnmatch.Glob(FileName, '*.m4a') then begin
		sMediaTagClasses[0] := TMP4file;
	end;
	for i := 0 to High(sMediaTagClasses) do
  begin
    if Assigned(sMediaTagClasses[i]) then
    begin
      try
        fTagObject := sMediaTagClasses[i].Create;
        if fTagObject.ReadFromFile(FileName) then
        begin
          break;
        end else
        begin
          FreeAndNil(fTagObject);
        end;
	    except
	    end;
    end;
  end;
	Result := Assigned(fTagObject);
end;

function TsMediaTagReader.RemoveFromFile(const FileName: String): Boolean;
var
	i: Integer;
begin
	Result := False;
	if not Assigned(fTagObject) or (FileName = '') then Exit;

  Result := fTagObject.RemoveFromFile(FileName);
	for i := 0 to High(InnerTags) do if TypInfo.IsPublishedProp(fTagObject, InnerTags[i]) then begin
  	Result := TsMediaTag(TypInfo.GetObjectProp(fTagObject, InnerTags[i])).RemoveFromFile(FileName);
  end;
end;

function TsMediaTagReader.SaveToFile(const FileName: String): Boolean;
var
	i: Integer;
begin
	Result := False;
	if not Assigned(fTagObject) or (FileName = '') then Exit;

  Result := fTagObject.SaveToFile(FileName);
	for i := Low(InnerTags) to High(InnerTags) do
  begin
    if TypInfo.IsPublishedProp(fTagObject, InnerTags[i]) then
    begin
  	  Result := TsMediaTag(TypInfo.GetObjectProp(fTagObject, InnerTags[i])).SaveToFile(FileName);
    end;
  end;
end;

function TsMediaTagReader.EnumProperties(): TStringList;

	procedure sub(Obj: TPersistent; list: TStrings);
  var
    i, TotalCount: Integer;
    TypeInfo: PTypeInfo;
    PropList: PPropList;
    PropInfo: PPropInfo;
  begin
		if not Assigned(Obj) or not Assigned(list) then Exit;

		TypeInfo := Obj.ClassInfo;
		TotalCount := GetTypeData(TypeInfo)^.PropCount;
		GetMem(PropList, TotalCount * SizeOf(Pointer));
		if (TotalCount > 0) then try
			GetPropInfos(TypeInfo, PropList);
			for i := Low(InnerTags) to TotalCount - 1 do begin
				PropInfo := PropList^[i];
        if (list.IndexOf(PropInfo.Name) = -1) then list.Append(PropInfo.Name);
			end;
		finally
			FreeMem(PropList, TotalCount * SizeOf(Pointer));
		end;
  end;

var
	i: Integer;
begin
	Result := Nil;
	if not Assigned(fTagObject) then Exit;

	Result := TStringList.Create();
	try
  	sub(fTagObject, Result);
    for i := Low(InnerTags) to High(InnerTags) do
    begin
      if TypInfo.IsPublishedProp(fTagObject, InnerTags[i]) then
    	  sub(TPersistent(TypInfo.GetObjectProp(fTagObject, InnerTags[i])), Result);
    end;
	except
		FreeAndNil(Result);
	end;
end;

function TsMediaTagReader.GetProperty(Index: String): String;
var
	i: Integer;
begin
	Result := '';
	if not Assigned(fTagObject) or (Index = '') then Exit;

	Result := RTTI_GetProperty(fTagObject, Index);
	if (Result = '') then for i := Low(InnerTags) to High(InnerTags) do if TypInfo.IsPublishedProp(fTagObject, InnerTags[i]) then begin
    Result := RTTI_GetProperty(TypInfo.GetObjectProp(fTagObject, InnerTags[i]), Index);
    if (Result <> '') then break;
  end;
end;

procedure TsMediaTagReader.SetProperty(Index: String; Value: String);
var
	i: Integer;
begin
	if not Assigned(fTagObject) or (Index = '') then Exit;

  try
    if TypInfo.IsPublishedProp(fTagObject, Index) then
    begin
      RTTI_SetProperty(fTagObject, Index, Value);
    end;
    for i := Low(InnerTags) to High(InnerTags) do
    begin
      if TypInfo.IsPublishedProp(fTagObject, InnerTags[i]) then
      begin
        RTTI_SetProperty(TypInfo.GetObjectProp(fTagObject, InnerTags[i]), Index, Value);
      end;
    end;
  except
  end;
end;


end.
