■なでしこプラグインをC/C++言語で作るために必要なSDKファイル

プラグインの作り方

（１）sample01.c に雛型があるので、これをコピーする
（２）以下の関数は必ず DLL の関数としてエクスポートしなければならないもの
　　　定型的なものなので、すべて sample01.c からコピーすれば OK

NAKO_API(void) ImportNakoFunction(void)
NAKO_API(int) PluginInfo(char* str, int len)
NAKO_API(DWORD) PluginVersion(void)
NAKO_API(DWORD) PluginRequire()
NAKO_API(void) PluginInit(DWORD hDll)
NAKO_API(void) PluginFin(void)

（３）自作関数を定義する

最低限、以下のような形式の自作関数を定義する

NAKO_API(PHiValue) sample01(DWORD h) {
    return NULL;
}

（４）なでしこのシステムに登録する

手順２で、sample01.c からコピーした「ImportNakoFunction()」関数で、引数の定義などをシステムに登録する。
=====
NAKO_API(void) ImportNakoFunction(void) {
    // ユーザー命令の追加
    nako_addFunction("サンプル1実行","STRで", sample01, 0);
}
=====
上記の関数は、なでしこで以下のように定義したのと同じになる
=====
●サンプル１実行（STRで）
=====

（５）コンパイルしてDLLをなでしこのプラグインフォルダ(plug-ins)にコピー

（６）なでしこでテストしてみる

====
「あ」でサンプル1実行して表示。
====

エラーが出なければ無事完成！！


