・オリジナルの配布元――
	http://j-faul.virtualave.net/atl/
	Copyright ｩ 2001,2002 by Jurgen Faul 
	All rights reserved by the author. This library is freeware for all purposes (unlimited distribution). 
	既にメンテナンスモードに入っているようです。

・改変者――
	sayray (kaon@gmx.net)

・追加されたファイル――
	sMediaTag.pas
	sMediaTagReader.pas

・変更点――
	RTTIでアクセス可能に――
		タグコンテナクラスをアクセスクラス TsMediaTag(TPersistentから継承)から継承。いくつかのメソッドをオーバーライド。
		諸々のクラスのプロパティを Publishedに移動。
	アプリケーションから違うインターフェイスのクラスを統一的に扱うためのアクセスクラス TsMediaTagReaderを追加。
	v1.10――
		書き込みと列挙に対応した。
		なんか変な所とかを直した。
		継承できるように virtualにしまくった。
		きちんとしたサンプルプロジェクトを追加した。

・使い方――
{
	AACfile.pas
	APEtag.pas
	CDAtrack.pas
	FLACfile.pas
	ID3v1.pas
	ID3v2.pas
	Monkey.pas
	MPEGaudio.pas
	MPEGplus.pas
	OggVorbis.pas
	sMediaTag.pas
	sMediaTagReader.pas
	TwinVQ.pas
	WAVfile.pas
	WMAfile.pas
	以上のファイルがパスの通った場所にある状態で
}
uses
	sMediaTagReader;
var
	tag: TsMediaTagReader;
begin
	tag := TsMediaTagReader.Create();
	tag.ReadFromFile('test.mp3');
	ShowMessgageFmt('%s - %s - %s', [tag.Properties['Title'], tag.Properties['Artist'], tag.Properties['Album']]);
	tag.Free();
end;

{ サンプルのプロジェクト(Projct1.dpr)があるのでそれが参考になると思います。 }

・クラス情報――
	TsMediaTagReader
		constructor Create(); virtual;
			コンストラクタ
		destructor Destroy(); OverRide;
			デストラクタ
		function LoadFromFile(const FileName: string): Boolean; virtual;
			ファイルから読み込み。成功でTrue。
		function RemoveFromFile(const FileName: string): Boolean; virtual;
			ファイルからタグを除去。成功でTrue。
		function SaveToFile(const FileName: String): Boolean; virtual;
			ファイルにタグを保存。
		function EnumProperties(): TStringList; virtual;
			読み込み可能なタグ名の列挙。
			内部では単にPublishedなプロパティの列挙をしているだけなので余計なものも返ってくる。
			最後にFree()すること。
		function GetProperty(Index: String): String; virtual;
			ReadFromFileでファイルフォーマットに応じたATLのタグコンテナクラスを内部に生成し、Indexに応じた項目を文字列で返す。
			Indexは'Title', 'Album', 'Artist', 'SampleRate', 'Year', 'Comment'などが考えられる。
			フォーマットによって内蔵している情報が違うので注意。.wavファイルからAlbumを読み込むことはできない。
			失敗は判別できない。
		procedure SetProperty(Index: String; Value: String); virtual;
			タグ情報を書き込む。SaveToFileしないと反映されない。
			失敗しても判らない。
		property Properties[Index: String]: String read GetProperty write SetProperty; default;
			GetPropertyのプロパティ版。

・最後に――
	デザインパターンの用語よく知らないの。
	改良された方がいたら適当に配布してください。
	fnmatchはMasksでやった方がいいのかも。

