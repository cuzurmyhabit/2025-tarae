import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late NaverMapController _mapController;

  @override
  void initState() {
    super.initState();
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;

    // 지도 초기 중심 설정
    _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(37.5665, 126.9780), // 서울 중심 좌표 예시
          zoom: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 1. 네이버 지도 (화면 1/3 높이)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 3,
            child: NaverMap(
              options: const NaverMapViewOptions(
                locationButtonEnable: true,
                consumeSymbolTapEvents: true,
              ),
              onMapReady: _onMapReady,
            ),
          ),

          /// 2. 햄버거 아이콘  
          Positioned(
            top: 100,
            left: 16,
            child: GestureDetector(
              onTap: () {
                // 메뉴 열기 기능
              },
              child: const Icon(Icons.menu, size: 28),
            ),
          ),

          /// 3. 중앙 인삿말  
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: const Text(
                '안녕하세요, 수민 님!\n어디에서 출발할까요?',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// 4. 하단 마이크 버튼
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/micbntIcon.svg',
                width: 64,
                height: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
