======================================================================
【名    称】  hedit251.lzh TEditor コンポーネント ver 2.51
【登 録 名】  hedit251.lzh
【バイト数】  244,002 byte
【制作者名】  本田勝彦 (VYR01647)
【掲載者名】  本田勝彦 (VYR01647)
【動作環境】  Windows95, 98 + D2, D3, D4, D5 (*1), D6, D7(*2)
【掲載月日】  2004/11/05
【作成方法】  ロングファイル名対応の LHA にて解凍
【検索キー】  1.%VYR01647 2.#SHARE 3.#VCL 4.TEDITOR
【動作確認】  Windows95 + D2, Windows98 + D2, D3, D4, D5 (*1), D6, D7(*2)
【ソフト種】  シェアウェア  ３，０００円 (*3)
【転載条件】  ま～るで自由
======================================================================
【内容紹介】

 TEditor は ver 1.00 よりソースコード公開型シェアウェアとなりました。

----------------------------------------------------------------------
 １．概要
----------------------------------------------------------------------
以下の機能を実現するエディタコンポーネントです。

■ 予約語・記号・文字列・数値・コメント領域・半角文字・
   全角文字及び半角カタカナ・url・メールアドレスを識別し、
   それぞれに、背景色、文字色、フォントスタイルを指定
■ { }, (* *), <!-- -->, つまり である, など、特定の文字列で囲まれた
   領域を複数行に渡って別色表示
■ 上記設定を様々な TFountain コンポーネントを接続することでカスタ
   マイズすることが可能です。

■ 選択領域の背景色・文字色を指定
■ 検索一致文字列の背景色・文字色を指定
■ [EOF] マーク、改行マーク、折り返しマーク、アンダーラインを表示
■ レフトマージン、トップマージン、行間マージン、文字間隔を指定
■ １行文字列のオーナードロー
■ 行番号・ルーラーの表示

■ Undo, Redo
■ 選択された行のインデント・アンインデント
■ ワードラップ時の、行頭禁則文字／行末禁則文字による追い出し、
   改行文字のぶら下げ、句読点のぶら下げ、英文ワードラップ
■ ３２Ｋの制限がありません。Windows.pas も開いて編集出来ます。

■ フリーキャレットモード、オートインデント、
   バックスペースアンインデント機能
■ 矩形選択・貼り付け機能
■ 画面分割・別窓での編集のサポート
■ マウスドラッグによる選択文字列の移動・複写
■ EM_ 系の一部のメッセージに対応
■ ジャンプマークの設定と、そこへの移動

□ プロポーショナルフォントには対応していません。
   一応表示出来ますが、美しくありません。(^^;)

(*1) 動作確認項目の Delphi 5 については、TEditor ユーザーの皆さん
     から寄せられた情報を元に上記項目へ追加しています。作者自身に
     よる動作確認は出来ていません。

(*2) 動作確認項目の Delphi 7 については、Delphi Studio Field Test
     ENTERPRISE 版による動作確認が行われています。

(*3) ライセンスについて
     ver 1.60 より利用形態（個人・商用）にかかわらず、
     ３，０００円でライセンスフリーと致しました。

     シェアウェア登録方法
     ・ベクターシェアレジ
       作品名：HEditor.pas (TEditor コンポ) 作品番号：ＳＲ０１３７０７
       http://www.vector.co.jp/soft/win95/prog/se114384.html 
     ・銀行振込
       空知信用金庫（ソラチシンヨウキンコ）
       本店
       普通預金　４６０６２８
       本田　勝彦（ホンダ　カツヒコ）
       ※お振り込み頂いた場合は、出来ましたらその旨のメールを私宛に
         お送りください。以下のメールアドレスの先頭の atama を除いた
         部分をコピー＆ペーストしてご利用下さい。 
         < atamakatsuhiko.honda@nifty.ne.jp >

----------------------------------------------------------------------
 ２．ファイル構成
----------------------------------------------------------------------
hedit251.lzh には以下のファイルが梱包されています。

■ 解凍先フォルダ
heditreg.pas         コンポーネントを登録するためのユニット
heditreg.dcr         コンポーネントアイコンファイル

heverdef.inc         Delphi, C++Builder 条件シンボル定義ファイル

hproputils.pas       ユーティリティユニット
hstreamutils.pas     〃

heutils.pas          TEditor システムの手続き・関数群
hestrconsts.pas      〃文字列定数定義ファイル
heclasses.pas        基底クラス群
hestringlist.pas     TheStringList クラス
herastrings.pas      TRowAttributeStringList クラス
heditor.pas          TEditor コンポーネント
heditor.res          リソースファイル（マウスカーソル）
hedtprop.pas         TEditorProp コンポーネント
hefountain.pas       TFountain 抽象基底クラス
editorfountain.pas   TEditorFountain コンポーネント
delphifountain.pas   TDelphiFountain コンポーネント
htmlfountain.pas     THTMLFountain コンポーネント

hpropert.pas         TEditor, TEditorProp, TFountain コンポーネント＆
                     プロパティエディタクラス群
fountaineditor.pas   TFountain コンポーネントエディタ
fountaineditor.dfm   ↑の .dfm ファイル
hviewedt.pas         TEditor, TEditorProp コンポーネント＆
                     プロパティエディタ
hviewedt.dfm         ↑の .dfm ファイル
hecolormanager.pas   プロパティエディタフォームが使用するファイル
hstrprop.pas         TStrings プロパティエディタフォーム（TEditor 専用）
hstrprop.dfm         ↑の .dfm ファイル
hschfm.pas           hstrprop.pas が使用するファイル
hschfm.dfm           〃
hreplfm.pas          〃
hreplfm.dfm          〃
htsearch.pas         〃

■ sample フォルダ
project1.dpr         サンプルプロジェクト
project1.res         〃
unit1.pas            〃
unit1.dfm            〃
unit2.pas            〃
unit2.dfm            〃
unit3.pas            〃
unit3.dfm            〃

■ doc フォルダ
readme.txt           このファイル
history.txt          バージョンアップ履歴


★ ヘルプファイルは、hehelp250.lzh を別途ダウンロードして下さい。


----------------------------------------------------------------------
 ３．実行方法
----------------------------------------------------------------------
ロングファイル名に対応した解凍ツールで解凍してください

heditreg.pas,       heditreg.dcr,        hproputils.pas,
hstreamutils.pas,   heverdef.inc,        heutils.pas,
heclasses.pas,      hestringlist.pas,    herastrings.pas,
heditor.pas,        heditor.res,         hedtprop.pas,
hefountain.pas,     editorfountain.pas,  delphifountain.pas,
htmlfountain.pas,   hpropert.pas,        fountaineditor.pas,
fountaineditor.dfm, hviewedt.pas,        hviewedt.dfm,
hecolormanager.pas, hstrprop.pas,        hstrprop.dfm,
hschfm.pas,         hschfm.dfm,          hreplfm.pas,
hreplfm.dfm,        htsearch.pas,        hestrconsts.pas

の３０個のファイルをライブラリパスの通ったフォルダにコピーした後
HEditReg.pas をコンポーネントインストールして下さい。
^^^^^^^^
----------------------------------------------------------------------
 ４．今回のバージョンアップの内容
----------------------------------------------------------------------

■ バグ
・HViewEdt.pas, HViewEdt.dfm を ver 2.48 のモノに戻した。
  ver 2.50 では、HViewEdt.dfm に Caret.TokenEndStop に対応する
  CheckBox を増やしたが D4, D6 がお亡くなりになる不具合が発生した。
  あまりにもたくさんのコントロールが張り付いたフォームをプロパティ
  エディタとするのには限界を超えたのかもしれないが、詳細は不明。

history.txt も合わせてご覧下さい。

----------------------------------------------------------------------
 ５．今後の課題
----------------------------------------------------------------------
・CLX への対応
・キー入力とコマンドを対応させるシステム

----------------------------------------------------------------------
 ６．謝辞
----------------------------------------------------------------------
nifty:FDELPHI/MES/10 において、多数のご意見をいただき、大変感謝致して
おります。今後も皆様のご意見、ご感想、ご要望などお聞かせ頂ければ大変
ありがたいです。よろしくお願い致します。m(_ _)m

----------------------------------------------------------------------
 ７．その他
----------------------------------------------------------------------
私のホームページには、TEditor Q&A、及びサポート掲示板とその過去ログ、
また TFountain コンポーネントのリンク集や、開発日誌などがあります。
合わせてご利用下さい。

http://homepage3.nifty.com/~katsuhiko/

======================================================================
File Name【hedit251.lzh】
======================================================================
