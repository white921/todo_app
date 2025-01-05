import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase 初期化用
import 'login_page.dart';
import 'HomeScreen.dart';
import 'auth_service.dart';
import 'package:device_preview/device_preview.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Flutter エンジンの初期化
  await Firebase.initializeApp(); // Firebase の初期化
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp()),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  build(BuildContext context){
    return const MaterialApp(
      home: HomeScreen(),
    );
  }

 
}