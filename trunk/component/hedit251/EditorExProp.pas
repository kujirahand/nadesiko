(***************************************************************

  TEditorExProp (2003/11/30)

  Copyright (c) 2001-2003 Km <CQE03114@nifty.ne.jp>
  http://homepage2.nifty.com/Km/

***************************************************************)
unit EditorExProp;

interface

uses
  Classes, HEditor, HEdtProp, EditorEx;

type

// -------------------------------------------------------------
// TEditorExProp
// -------------------------------------------------------------

  TEditorExProp = class(TEditorProp)
  private
    FExMarks: TEditorExMarks;
    FFindString: string;
    FOnFindStringChange: TNotifyEvent;
    FExSearchOptions: TExSearchOptions;
    FOnExSearchOptionsChange: TNotifyEvent;
    FVerticalLines: TVerticalLines;
    FOnVerticalLinesChange: TNotifyEvent;
    procedure SetExMarks(Value: TEditorExMarks);
    procedure SetFindString(const S: string);
    procedure SetExSearchOptions(Value: TExSearchOptions);
    procedure SetVerticalLines(Value: TVerticalLines);
  protected
    function CreateEditorExMarks: TEditorExMarks; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    property OnFindStringChange: TNotifyEvent read FOnFindStringChange write FOnFindStringChange;
    property OnExSearchOptionsChange: TNotifyEvent read FOnExSearchOptionsChange write FOnExSearchOptionsChange;
    property OnVerticalLinesChange: TNotifyEvent read FOnVerticalLinesChange write FOnVerticalLinesChange;
  published
    property ExMarks: TEditorExMarks read FExMarks write SetExMarks;
    property FindString: string read FFindString write SetFindString;
    property ExSearchOptions: TExSearchOptions read FExSearchOptions write SetExSearchOptions;
    property VerticalLines: TVerticalLines read FVerticalLines write SetVerticalLines;
  end;


implementation


// -------------------------------------------------------------
// TEditorExProp
// -------------------------------------------------------------

procedure TEditorExProp.SetExMarks(Value: TEditorExMarks);
begin
  FExMarks.Assign(Value);
end;


procedure TEditorExProp.SetFindString(const S: string);
begin
  if FFindString <> S then
  begin
    FFindString := S;
    if Assigned(FOnFindStringChange) then FOnFindStringChange(Self);
  end;
end;


procedure TEditorExProp.SetExSearchOptions(Value: TExSearchOptions);
begin
  if FExSearchOptions <> Value then
  begin
    FExSearchOptions := Value;
    if Assigned(FOnExSearchOptionsChange) then FOnExSearchOptionsChange(Self);
  end;
end;


procedure TEditorExProp.SetVerticalLines(Value: TVerticalLines);
begin
  if FVerticalLines <> Value then
  begin
    FVerticalLines := Value;
    if Assigned(FOnVerticalLinesChange) then FOnVerticalLinesChange(Self);
  end;
end;
                                        

function TEditorExProp.CreateEditorExMarks: TEditorExMarks;
begin
  Result := TEditorExMarks.Create;
end;


constructor TEditorExProp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExMarks         := CreateEditorExMarks;
  FFindString      := '';
  FExSearchOptions := [];
  FVerticalLines   := TVerticalLines.Create(self);
end;


destructor TEditorExProp.Destroy;
begin
  FExMarks.Free;
  FVerticalLines.Free;
  inherited Destroy;
end;


procedure TEditorExProp.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if Source is TEditorEx then
  begin
    try
      FExMarks.Assign(TEditorEx(Source).ExMarks);
      FFindString      := TEditorEx(Source).FindString;
      FExSearchOptions := TEditorEx(Source).ExSearchOptions;
      FVerticalLines.Assign(TEditorEx(Source).VerticalLines);
    except
    end;
  end;

  if Source is TEditorExProp then
  begin
    try
      FExMarks.Assign(TEditorExProp(Source).ExMarks);
      FFindString      := TEditorExProp(Source).FindString;
      FExSearchOptions := TEditorExProp(Source).ExSearchOptions;
      FVerticalLines.Assign(TEditorExProp(Source).VerticalLines);
    except
    end;
  end;
end;


procedure TEditorExProp.AssignTo(Dest: TPersistent);
begin
  inherited AssignTo(Dest);

  if Dest is TEditorEx then
  begin
    try
      TEditorEx(Dest).ExMarks.Assign(FExMarks);
      TEditorEx(Dest).FindString      := FFindString;
      TEditorEx(Dest).ExSearchOptions := FExSearchOptions;
      TEditorEx(Dest).VerticalLines.Assign(FVerticalLines);
    except
    end;
  end;

  if Dest is TEditorExProp then
  begin
    try
      TEditorExProp(Dest).ExMarks.Assign(FExMarks);
      TEditorExProp(Dest).FindString      := FFindString;
      TEditorExProp(Dest).ExSearchOptions := FExSearchOptions;
      TEditorExProp(Dest).VerticalLines.Assign(FVerticalLines);
    except
    end;
  end;
end;


end.
