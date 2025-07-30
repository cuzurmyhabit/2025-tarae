import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 SDK import 추가
import 'pages/LoginPage.dart'; // LoginPage 경로가 맞는지 확인해주세요.

void main() async {
  // Flutter 엔진과 위젯 트리를 바인딩합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '09550ab4b7a42d7443ee26df59f79a8c', // 여기에 카카오 네이티브 앱 키를 입력하세요.
  );

  // 네이버 맵 SDK 초기화
  await NaverMapSdk.instance.initialize(
    clientId: 'c720p1zfj9', // 기존 네이버 클라이언트 ID
    onAuthFailed: (ex) {
      print('네이버 맵 인증 실패: $ex');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '타래',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}