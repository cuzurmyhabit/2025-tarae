import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/route_manager.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // 카카오 SDK import 추가
import 'package:tarae/pages/InnerMap.dart';
import 'package:tarae/pages/LocationSearchPage.dart';
import 'package:tarae/pages/PaymentPage.dart';
import 'package:tarae/pages/StartPage.dart';
import 'pages/LoginPage.dart'; // LoginPage 경로가 맞는지 확인해주세요.

void main() async {
  // Flutter 엔진과 위젯 트리를 바인딩합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey:
        '09550ab4b7a42d7443ee26df59f79a8c', // 여기에 카카오 네이티브 앱 키를 입력하세요.
  );

  await FlutterNaverMap().init(
    clientId: 'c720p1zfj9',
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          print("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          print("인증 실패: $ex");
          break;
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '타래',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Pretendard'),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LoginPage()),
        GetPage(name: '/start', page: () => const StartPage()),
        GetPage(name: '/innerMap', page: () => const InnerMap()),
        GetPage(
          name: '/locationSearch',
          page: () => const LocationSearchPage(),
        ),
        GetPage(name: '/payment', page: () => const PaymentPage()),
      ],
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
