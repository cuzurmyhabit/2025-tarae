import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class StartPage extends StatefulWidget {
  final String? userName;
  
  const StartPage({
    super.key,
    this.userName,
  });

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late NaverMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildNaverMap(),
          _buildMenuButton(),
          _buildWelcomeMessage(),
          _buildMicrophoneButton(),
        ],
      ),
    );
  }

  Widget _buildNaverMap() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _getMapHeight(),
      child: NaverMap(
        options: _getMapOptions(),
        onMapReady: _onMapReady,
      ),
    );
  }

  double _getMapHeight() {
    return MediaQuery.of(context).size.height / 3;
  }

  NaverMapViewOptions _getMapOptions() {
    return const NaverMapViewOptions(
      locationButtonEnable: true,
      consumeSymbolTapEvents: true,
    );
  }

  Widget _buildMenuButton() {
    return Positioned(
      top: 100,
      left: 16,
      child: GestureDetector(
        onTap: _onMenuTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu, 
            size: 28,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getWelcomeText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWelcomeText() {
    final name = widget.userName ?? '사용자';
    return '안녕하세요, $name 님!\n어디에서 출발할까요?';
  }

  Widget _buildMicrophoneButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _onMicrophoneTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/micbntIcon.svg',
              width: 64,
              height: 64,
            ),
          ),
        ),
      ),
    );
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _initializeMapCamera();
  }

  void _initializeMapCamera() {
    _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        _getInitialCameraPosition(),
      ),
    );
  }

  NCameraPosition _getInitialCameraPosition() {
    return const NCameraPosition(
      target: NLatLng(37.5665, 126.9780),
      zoom: 14,
    );
  }

  void _onMenuTap() {
    // TODO: 메뉴 열기 기능 구현
    print('메뉴 버튼 클릭됨');
  }

  void _onMicrophoneTap() {
    // TODO: 음성 입력 기능 구현
    print('마이크 버튼 클릭됨');
  }
}