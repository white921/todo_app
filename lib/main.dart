import 'package:flutter/material.dart'; //基本的なウィジェットを使えるようにするためのimport
import 'package:device_preview/device_preview.dart'; //device_previewのためのimport
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'login_page.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(DevicePreview(
    enabled: !kReleaseMode, // リリースモードでは無効化
    builder: (context) => const MyApp(),
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
      home: LoginPage(), //最初に起動させたいページの指定
    );
  }
}