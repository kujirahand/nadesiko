{*******************************************************}
{     for Borland Delphi 3.x                            }
{      TStrSortGrid Ver0.1                              }
{      FreeWay                                          }
{ Copyright(c) 1998.5.18 H.Kishi                        }
{ Email: hikishi@fsinet.or.jp                           }
{*******************************************************}


unit StrSortGrid;

interface

{$R-}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;
type
  TSortops=(soBoth,soUponly,soDownOnly,soNon);
  TSortState = (bsUp,bsDown,bbNon);
  TSortUpKind = (bkUp,bkUpCustom);
  TSortDownKind =(bkDown,bkDownCustom);//種類

  TStrSortGrid = class(TStringGrid)
  private
   FSetCol:Longint;
   FGetFixS:String;
   FSortFlg:Boolean;
   FSortops:TSortops;
   FSortUp:Boolean;
   FSpacing:Integer;
   procedure BubbleSortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
   function  GetSortUpGlyps(Kind:TSortUpKind) : TBitmap;
   function  GetSortDownGlyps(Kind:TSortDownKind): TBitmap;
   procedure QsortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
   procedure QuickSortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
   procedure SetSpacing(Value: Integer);
  protected
   procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
             X, Y: Integer); override;
   procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  public
   constructor Create(AOwner: TComponent); override;
  published
   property  SortOps:TSortops read FSortops write FSortops;      { Published 宣言 }
   property Spacing: Integer read FSpacing write SetSpacing default 10;
  end;

procedure Register;

implementation
{$R StrSortGrid.RES}
var
 SortResNamesUp  : array[TSortUpKind] of PChar = ( 'BBUP',nil);
 SortResNamesDown: array[TSortDownKind] of PChar = ( 'BBDOWN',nil);
 SortUPGlyphs: array[TSortUpKind] of TBitmap;
 SortDownGlyphs: array[TSortDownKind] of TBitmap;

constructor TStrSortGrid.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FSetCol:=0;
   FGetFixS:='';
   FSortFlg:=false;
   FSortUp:=True;
   FSpacing:=10;
 end;

procedure TstrSortGrid.SetSpacing(Value: Integer);
begin
  if FSpacing <> Value then    FSpacing := Value;
end;


function TStrSortGrid.GetSortUpGlyps(Kind:TSortUpKind) : TBitmap;
begin
  if SortUPGlyphs[Kind] = nil then
  begin
    SortUPGlyphs[Kind]:=TBitmap.Create;
    SortUPGlyphs[Kind].LoadFromResourceName(HInstance ,'BBUP');
  end;
   Result := SortUpGlyphs[Kind];
end;

function TStrSortGrid.GetSortDownGlyps(Kind:TSortDownKind) : TBitmap;
begin
  if SortDownGlyphs [Kind] = nil then
  begin
    SortDownGlyphs[Kind] := TBitmap.Create;
    SortDownGlyphs[Kind].LoadFromResourceName(HInstance,'BBDOWN');
  end;
   Result := SortDownGlyphs[Kind];
end;

procedure TStrSortGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
        AState: TGridDrawState);
var
TextSize:TPoint;
Drawbmp:TBitmap;
begin
inherited DrawCell(ACol, ARow, ARect, AState);
if (ACol=FSetCol) and (ARow=0) and FSortFlg then
begin
 if Length(FGetFixS)>0 then
 begin
 Canvas.FillRect(ARect);
 Canvas.Brush.Color:=FixedColor;
 DrawText(Canvas.Handle,PChar(fgetFixS),length(FGetFixS),ARect,DT_CALCRECT);
 TextSize:=Point(ARect.Right-ARect.Left,ARect.Bottom-ARect.Top);
   if FSortUp then
     Drawbmp:=GetSortUpGlyps(bkUp)
   else
     Drawbmp:=GetSortDownGlyps(bkDown);
 Canvas.Draw(ARect.Left+1+ TextSize.x+Spacing,ARect.Top + 2,Drawbmp);
 Canvas.Brush.Color:=FixedColor;
 Canvas.TextOut(ARect.Left+1,ARect.Top + 2 , FGetFixS);
 end;
end;

end;

procedure TStrSortGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  FCol, FRow: Longint;
begin
    { クリックされた座標からセルの位置を取得する }
 if SortOps in [soNon] then
 begin
  inherited MouseDown(Button,Shift,X,Y); // 修正 by クジラ飛行机(2002/12/1)
  Exit;
 end;

    MouseToCell(X,Y,FCol,FRow);
    if FRow=0 then
     begin
      FSetCol:=FCol;
      FSortFlg:=true;
      FGetFixS:=Cells[Fcol,0];
   case SortOps of
    soUponly  : FSortUp:=True;
    soDownOnly: FSortUp:=False;
    else        FSortUp:=Not(FSortUp) ;
   end;
     QuickSortGrid(Self,1,RowCount-{1}2{修正 by クジラ飛行机},FCol); //１列から最後まで　ソートする列
    end;

    inherited MouseDown(Button,Shift,X, Y);
end;

procedure TStrSortGrid.QuickSortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
var
   j : Word;
   sortGrid, tempGrid : TStringGrid;

Function UpString(Instring : String) : String;
var
   tel : byte;
   outstring : string;
begin
   OutString := InString;
   FOR tel := 1 TO length(Instring) DO
      OutString[tel] := upcase(OutString[tel]);
   UpString := OutString;
end;

begin
   sortGrid := TStringGrid.Create(Nil);
   sortGrid.RowCount := MotoGrid.RowCount;
   sortGrid.ColCount := 2;
   for j := StartIdx to EndIdx do
   begin
      sortGrid.Cells[0, j] := IntToStr(j);
      sortGrid.Cells[1, j] := MotoGrid.Cells[SortIdx, j]
   end;

     For j := StartIdx to EndIdx do
     SortGrid.Cells[1, j] := UpString(SortGrid.Cells[1, j]);
     qsortGrid(sortGrid, StartIdx, EndIdx, 1);

   tempGrid := TStringGrid.Create(Nil);
   tempGrid.RowCount := MotoGrid.RowCount;
   tempGrid.ColCount := MotoGrid.ColCount;
   for j := StartIdx to EndIdx do
     tempGrid.rows[j] :=MotoGrid.rows[StrToInt(sortGrid.Cells[0,j])];
   for j := StartIdx to EndIdx do
     MotoGrid.rows[j] := tempGrid.rows[j];
   sortGrid.Free;
   If Not(FSortUp) THEN  //降順
      FOR j := EndIdx DOWNTO StartIdx DO
            MotoGrid.rows[EndIdx-j+StartIdx] := tempGrid.rows[j];
   tempGrid.Free
end;

procedure TStrSortGrid.BubbleSortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
Var
   Idx : Word;
   Changed : Boolean;
   tempRow : TStringList;
   fields, i : Word;

begin
   tempRow :=TStringList.Create;
   fields := MotoGrid.ColCount;
   repeat
      Changed := False;
      for Idx := StartIdx to EndIdx-1 do
      begin
         if MotoGrid.Cells[SortIdx, Idx] > MotoGrid.Cells[SortIdx, Idx+1] then
         begin
            tempRow.Clear;
            for i := 0 to fields - 1 do
               tempRow.Add(MotoGrid.cells[i, Idx+1]);
            MotoGrid.rows[Idx+1] := MotoGrid.rows[Idx];
            for i := 0 to fields - 1 do
               MotoGrid.cells[i, Idx] := tempRow.Strings[i];
            Changed := True;
         end;
      end;
   until Changed = False;
   tempRow.Free;
end;


procedure TStrSortGrid.qsortGrid(MotoGrid : TStringGrid; StartIdx, EndIdx, SortIdx : Integer);
Var
   x, y : Word;
   temp: String;
   tempRow : TStringList;
   ind : Word;
   fields, i : Word;

begin
   if (EndIdx-StartIdx) < 5 then
      BubbleSortGrid(MotoGrid, StartIdx, EndIdx, SortIdx)
   else
   begin
      tempRow :=TStringList.Create;
      fields := MotoGrid.ColCount;
      if StartIdx < EndIdx then
      begin
         x:= StartIdx;
         y:= EndIdx;
         ind := (StartIdx+EndIdx) div 2;
         temp := MotoGrid.cells[SortIdx, ind];
         while x <= y do
         begin
            while MotoGrid.cells[SortIdx, x] < temp do
               Inc(x);
            while MotoGrid.cells[SortIdx, y] > temp do
               Dec(y);
            if x <= y then
            begin
               tempRow.Clear;
               for i := 0 to fields - 1 do
                  tempRow.Add(MotoGrid.cells[i, x]);
               MotoGrid.rows[x] := MotoGrid.rows[y];
               for i := 0 to fields - 1 do
                  MotoGrid.cells[i, y] := tempRow.Strings[i];
               Inc(x);
               Dec(y);
            end;
         end;
         tempRow.Free;
         qsortGrid(MotoGrid, StartIdx, y, SortIdx);
         qsortGrid(MotoGrid, x, EndIdx, SortIdx);
      end;
   end;
end;


procedure Register;
begin
  RegisterComponents('KSI', [TStrSortGrid]);
end;

end.
