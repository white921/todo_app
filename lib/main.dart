import 'package:flutter/material.dart'; //基本的なウィジェットを使えるようにするためのimport
import 'HomeScreen.dart';
import 'package:device_preview/device_preview.dart'; //device_previewのためのimport

void main() {
  runApp(DevicePreview(
    enabled: true, //ここがtrueだとDevicePreviewが有効
    tools: const [
      ...DevicePreview.defaultTools, //プレビューに必要なツール
    ],
    builder: (context) => const MyApp(), //プレビュー対象のアプリ指定
  ));
}

class MyApp extends StatelessWidget {
  //MyAppクラスはFlutterアプリのルートウィジェット(ウィジェットツリーの最上位)
  const MyApp({super.key}); //ウィジェットの一意識別に必要らしいがなくても動く(調べても難しかった)

  @override //メソッド前にいつもつけてる。buildメソッドはStatelessウィジェットだよって感じ
  Widget build(BuildContext context) {
    //buildメソッドはFlutterがこのウィジェットを画面に描画する際に呼び出すメソッド。
    //BuildContextはbuildメソッドの引数によくいるやつ
    return MaterialApp(
      //インポートしてきた便利なやつ。これをreturnすることで中にあるものを描写される
      home: HomeScreen(), //最初に起動させたいページの指定
    );
  }
}
