// The TUIFavorites was made and was do was imitate the TFavorites.
//I express the respect to Mr.Per Linds¯ Larsen .

//TUIFavoritesÇÕÅATFavoritesÇéQçlÇ…ÇµÇƒçÏÇËÇ‹ÇµÇΩÅB
// Per Linds¯ Larsen Ç…åhà”Çï\ÇµÇ‹Ç∑ÅB



{*******************************************************}
{                                                       }
{  IE Favorites Component v 0.97  by Per Linds¯ Larsen  }
{                     FREEWARE                          }
{                                                       }
{                       Enjoy!                          }
{                                                       }
{                  September 12, 1999                    }
{       UPDATES: http://www.euromind.com/iedelphi       }
{                 lindsoe@post.tele.dk                  }
{                                                       }
{*******************************************************}

/// How to use:

/// ***   Drop component on form.
/// ***   Set property for Mainmenu and webbrowser.
/// ***   Add  "Favorites1.CreateMenu"
/// ***           to form1.OnCreate;

{
  Caption: MenuCaption
  MenuPos: Position in Mainmenu
  Options:
           AddFavorites: Add "Add Favorites Dialog" to Favorites-menu.
           OrganizeFavorites: Add "Organize Favoerites Dialog" to favorites-menu.

  Works only with IE5:
           ImporTUIFavorites: Add "Import Favorites dialog" to menu.
           ExporTUIFavorites: Add "Export Favorites dialog to menu.

  Component ignore Import/export Favorites if IE5 is not installed.
}


// This component includes two different ways to resolve internet shortcut.
// MS recommend the use of IUniformResourceLocator since the internal structure
// of URL-files may change in the future. Define USE_INTSHCUT to use this method.

{$DEFINE USE_INTSHCUT}

// Delete USE_INTSHCUT if you want to use inifile to resolve internet shortcut.


// Menu-icons are not available in Delphi 3.

{$IFDEF VER120} // Delphi 4
{$DEFINE SHOWICON}
{$ENDIF}
{$IFDEF VER130} // Delphi 5
{$DEFINE SHOWICON}
{$ENDIF}



unit UIFavorites;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Inifiles, registry, StdCtrls, Menus,{$IFDEF VER120}ShDocVw_tlb{$ELSE}SHDocVw{$ENDIF}
  ,Shlobj, ActiveX,{$IFDEF USE_INTSHCUT}IntShCut,{$ENDIF} ShellApi , activex_helper;

    const UnitVersion = 1.0;
type

  TFavOptions = (AddFavorites, OrganizeFavorites, ImporTUIFavorites, ExporTUIFavorites);
  TOptions = set of TFavOptions;


  TUIFavorites = class(TComponent)
  private
{$IFDEF USE_INTSHCUT}
    IUrl: IUniformResourceLocator;
    PersistFile: IPersistfile;
{$ENDIF}
    FCaption: string;
    FOptions: TOptions;
    FMenuPos: Integer;
    FMainMenu: TMainmenu;
    FavFolder: string;
    FavMenu: TMenuItem;
    FavMenuExt: Byte;
    ForgFavCaption: TCaption;
    FexpFavCaption: TCaption;
    FimpFavCaption: TCaption;
    FAddFavCaption: TCaption;


    procedure Retrieve(Menu: TmenuItem; Folder: string);
    procedure FavMenuClick(sender: TObject);
    procedure OrganizeFavorite(Sender: TObject);
    procedure AddFavorite(Sender: TObject);
    procedure FavoritesImport(Sender: TObject);
    procedure FavoritesExport(Sender: TObject);
    function ResolveInternetShortcut(Filename: string): string;
    { Private declarations }
  protected
    { Protected declarations }
    FIWebbrowser : IwebBrowser2 ;

  public
    { Public declarations }
    property WebbrowserControl : IwebBrowser2  read FIWebBrowser   write FIWebBrowser;
    procedure CreateMenu; overload;
    procedure CreateMenu( WebBrowser : IWebBrowser2); overload;

    procedure UpdateMenu;
    constructor Create(AOwner: TComponent); override;
  published
    property MainMenu: TMainMenu read FMainMenu write FMainMenu;
    property Menupos: Integer read FMenuPos write FMenuPos;
    property Options: TOptions read FOptions write FOptions;
    property Caption: string read FCaption write FCaption;

    property addFavCaption : TCaption  read FAddFavCaption  write FAddFavCaption;
    property orgFavCaption : TCaption  read ForgFavCaption   write forgFavCaption ;
    property impFavCaption : TCaption  read FimpFavCaption   write FimpFavCaption ;
    property expFavCaption : TCaption  read FexpFavCaption   Write FexpFavCaption ;




    { Published declarations }
  end;


procedure Register;

implementation

uses
  ComObj;


const
  CLSID_ShellUIHelper: TGUID = '{64AB4BB7-111E-11D1-8F79-00C04FC2FBE1}';
  FMenuMaxWidth = 40;


var
  p: procedure(Handle: THandle; Path: PChar); stdcall;





function IE5_Installed: Boolean;
var
  S: string;
begin
  s := getOcxVersion( class_WebBrowser );
  Result :=  AverSmallerBver('5.0.0' , s );
end;

procedure TUIFavorites.FavoritesExport(Sender: TObject);
var
  Sh: olevariant;
begin
  if IE5_Installed  then
  begin
   Sh := CreateComObject(CLSID_SHELLUIHELPER) ;
   sh.ImportExportFavorites(FALSE, '');
   updatemenu;
 end;
end;


procedure TUIFavorites.FavoritesImport(Sender: TObject);
var
  Sh: olevariant;
begin
  if IE5_Installed  then
  begin
   Sh := CreateComObject(CLSID_SHELLUIHELPER);
   sh.ImportExportFavorites(TRUE, '');
   updatemenu;
  end;
end;





procedure TUIFavorites.OrganizeFavorite(Sender: Tobject);
var
  H: HWnd;
begin
  H := LoadLibrary(PChar('shdocvw.dll'));
  if H <> 0 then begin
    p := GetProcAddress(H, PChar('DoOrganizeFavDlg'));
    if Assigned(p) then p(Application.Handle, PChar(FavFolder));
  end;
  FreeLibrary(h);
  UpdateMenu;
end;



{$IFDEF USE_INTSHCUT}
function TUIFavorites.ResolveInternetShortcut(Filename: string): String;
Var
FName: array[0..MAX_PATH] of WideChar;
p : Pchar;
begin
  IUrl := CreateComObject(CLSID_InternetShortCut) as IUniformResourceLocator;
  Persistfile := IUrl as IPersistFile;
  StringToWideChar(FileName, FName, MAX_PATH);
  PersistFile.Load(Fname, STGM_READ);
  IUrl.geturl(@P);
  Result:=P;
end;
{$ELSE}
function TUIFavorites.ResolveInternetShortcut(Filename: string): String;
var
  ini : TiniFile;
begin
  result := '';
  ini := TIniFile.create(fileName);
  try
    result := ini.ReadString('InternetShortcut', 'URL', '');
  finally
    ini.free;
  end;
end;
{$ENDIF}



procedure TUIFavorites.UpdateMenu;
var
  Save_Cursor: TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  while Favmenu.count > Favmenuext do Favmenu.items[Favmenuext].Free;
  Retrieve(Favmenu, FavFolder);
  Screen.Cursor := Save_Cursor;
end;



procedure Register;
begin
  RegisterComponents('www', [TUIFavorites]);
end;



procedure TUIFavorites.CreateMenu;
var
  Menu: TMenuItem;
  SFolder: pItemIDList;
  SpecialPath: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderLocation(0, CSIDL_FAVORITES, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Favfolder := StrPas(SpecialPath);
  FavMenu := TMenuItem.Create(Self);
  Favmenu.Caption := FCaption;
  if AddFavorites in FOptions then begin
    Menu := NewItem(FAddFavCaption, 0, False, True, addfavorite, 0, '');
    Favmenu.Add(Menu);
  end;
  if OrganizeFavorites in FOptions then begin
    Menu := NewItem(OrgFavCaption, 0, False, True, organizefavorite, 0, '');
    Favmenu.Add(Menu);
  end;
  if FavMenu.Count > 0 then begin
    Menu := NewItem('-', 0, False, True, nil, 0, '');
    Favmenu.Add(Menu);
  end;
  if IE5_Installed then begin
    if ImporTUIFavorites in FOptions then begin
      Menu := NewItem('ImpFavCaption', 0, False, True, FavoritesImport, 0, '');
      Favmenu.Add(Menu);
    end;
    if ExporTUIFavorites in FOptions then begin
      Menu := NewItem('ExpFavCaption', 0, False, True, FavoritesExport, 0, '');
      Favmenu.Add(Menu);
    end;
    if (ImporTUIFavorites in FOptions) or (ExporTUIFavorites in FOptions) then begin
      Menu := NewItem('-', 0, False, True, nil, 0, '');
      Favmenu.Add(Menu);
    end;
  end;
  FavMenuExt := FavMenu.Count;
  Retrieve(Favmenu, FavFolder);
  if Fmenupos > 0 then Dec(FMenuPos);
  if FmenuPos > FMainmenu.Items.count then
    FMenuPos := FMainMenu.Items.Count;
  FMainmenu.Items.Insert(FMenupos, Favmenu);
end;


procedure TUIFavorites.FavMenuClick(sender: TObject);
var
  X: OleVariant;
  Url: string;
begin
  Url := (Sender as TMenuItem).hint;
  if Assigned(FIWebbrowser) then
    FIWebbrowser.Navigate(Url, x, x, x, x) else
    Showmessage('No Webbrowser connected to Favorites-menu');
end;

procedure TUIFavorites.AddFavorite(Sender: TObject);
var
  ShellUIHelper: ISHellUIHelper;
  url, title: Olevariant;
begin
  if Assigned(FIWebbrowser) then begin
    Title := FIWebbrowser.LocationName;
    Url := FIWebbrowser.LocationUrl;
    if Url <> '' then begin
      ShellUIHelper := CreateComObject(CLSID_SHELLUIHELPER) as IShellUIHelper;
      ShellUIHelper.AddFavorite(url, title);
      UpdateMenu;
    end;
  end else
    Showmessage('No Webbrowser connected to Favorites-menu');
end;

procedure TUIFavorites.Retrieve(Menu: TmenuItem; Folder: string);
var
  AdjustedName: string;
  I: Integer;
  Counter: Integer;
  SearchRec: TSearchRec;
  MenuItem: TMenuItem;
  Stringlist: TStringList;
{$IFDEF SHOWICON}
  FileInfo: SHFileInfo;
{$ENDIF}
  procedure GetIcon;
  var
    Icon: TIcon;
  begin
{$IFDEF SHOWICON}
    Icon := TIcon.Create;
    SHGetFileInfo(Pchar(Folder + Stringlist[I]), 1, FileInfo, SizeOf(FileInfo), SHGFI_ICONLOCATION or SHGFI_ICON);
    if pos('.ico', fileinfo.szDisplayname) > 0 then
      Icon.LoadFromFile(Fileinfo.szDisplayName) else
    begin
      Icon.handle := Fileinfo.HIcon;
    end;
    MenuItem.Bitmap.Height := Icon.Height;
    MenuItem.Bitmap.Width := Icon.Width;
    MenuItem.Bitmap.Canvas.Draw(0, 0, Icon);
    Icon.Free;
{$ENDIF}
  end;

begin
  Counter := 0;
  StringList := TStringlist.Create;
  StringList.Sorted := True;
  if Folder[Length(Folder)] <> '\' then Folder := Folder + '\';
  if FindFirst(Folder + '*.*', faDirectory, SearchRec) = 0
    then repeat
      if (SearchRec.Attr and faDirectory <> 0)
        and (SearchRec.Name[1] <> '.') then StringList.Add(SearchRec.Name);
    until FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
  for I := 0 to StringList.Count - 1 do begin
    MenuItem := NewItem(StringList[I], 0, False, True, nil, 0, '');
{$IFDEF SHOWICON}
    GetIcon;
{$ENDIF}
    Menu.Insert(menu.Count - Counter, MenuItem);
    Retrieve(MenuItem, Folder + StringList[I]);
  end;
  Stringlist.Clear;
  if FindFirst(Folder + '*.url', faAnyFile, SearchRec) = 0
    then repeat
      if SearchRec.Attr and (faDirectory + faVolumeID) = 0 then
        StringList.Add(SearchRec.Name);
    until FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
  for I := 0 to StringList.Count - 1 do begin
    AdjustedName := Copy(StringList[I], 1, Length(StringList[I]) - 4);
    if Length(AdjustedName) > FMenuMaxWidth then
      AdjustedName := Copy(AdjustedName, 1, FMenuMaxWidth) + '...';
    MenuItem := NewItem(AdjustedName, 0, False, True, FavMenuClick, 0, '');
{$IFDEF SHOWICON}
    GetIcon;
{$ENDIF}
    MenuItem.Hint := ResolveInternetShortCut(Folder + StringList[I]);
    menu.Insert(menu.Count - Counter, MenuItem);
  end;
  if menu.Count = 0
    then menu.Add(NewItem('( Empty )', 0, False, False, nil, 0, ''));
  StringList.Free;
end;



constructor TUIFavorites.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if IE5_Installed  then
    FOptions := [AddFavorites, OrganizeFavorites, ImporTUIFavorites, ExporTUIFavorites]
  else
    FOptions := [AddFavorites, OrganizeFavorites ];

    FMenuPos := 1;
    FCaption := 'Favorites';
    ForgFavCaption :='Organize Favorites'   ;
    FexpFavCaption :='Export Favorites';
    FimpFavCaption :='Import Favorites' ;
    FAddFavCaption := 'Add Favorites';

end;

procedure TUIFavorites.CreateMenu(WebBrowser: IWebBrowser2);
begin
   FIwebBrowser := WebBrowser;
   createMenu;
end;

end.

