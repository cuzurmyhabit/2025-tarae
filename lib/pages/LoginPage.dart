import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'PaymentPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
      bottomNavigationBar: _buildKakaoLoginButton(context),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          _buildTitleText(),
          const SizedBox(height: 5),
          _buildSubtitleText(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SvgPicture.asset(
      'assets/icons/loginIcon.svg',
      width: 200,
      height: 200,
    );
  }

  Widget _buildTitleText() {
    return const Text(
      '음성으로 한번에 택시 호출',
      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSubtitleText() {
    return const Text(
      '보다 쉽고 단순한 택시 호출 서비스',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildKakaoLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 115, left: 20, right: 20),
      child: SizedBox(
        height: 56,
        child: Material(
          color: const Color(0xFFFAE100),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _handleKakaoLogin(context),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/kakaoIcon.svg', width: 24, height: 24),
        const SizedBox(width: 8),
        const Text(
          '카카오톡으로 계속하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      final token = await _performKakaoLogin();
      final user = await _getUserInfo();
      await _navigateToPaymentPage(context, user);
    } catch (e) {
      _handleLoginError(context, e);
    }
  }

  Future<OAuthToken> _performKakaoLogin() async {
    if (await isKakaoTalkInstalled()) {
      return await UserApi.instance.loginWithKakaoTalk();
    } else {
      return await UserApi.instance.loginWithKakaoAccount();
    }
  }

  Future<User> _getUserInfo() async {
    User user = await UserApi.instance.me();

    if (_needsAdditionalPermissions(user)) {
      await _requestAdditionalPermissions();
      user = await UserApi.instance.me();
    }

    return user;
  }

  bool _needsAdditionalPermissions(User user) {
    return user.kakaoAccount?.profileNicknameNeedsAgreement == true ||
        user.kakaoAccount?.profileImageNeedsAgreement == true;
  }

  Future<void> _requestAdditionalPermissions() async {
    await UserApi.instance.loginWithNewScopes([
      'profile_nickname',
      'profile_image',
    ]);
  }

  Future<void> _navigateToPaymentPage(BuildContext context, User user) async {
    final userProfile = _extractUserProfile(user);

    if (userProfile.nickname != null) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentPage(
                nickname: userProfile.nickname,
                profileImage: userProfile.profileImage,
              ),
        ),
      );
    } else {
      _showErrorMessage(context, '닉네임 정보를 가져올 수 없습니다.');
    }
  }

  UserProfile _extractUserProfile(User user) {
    final profile = user.kakaoAccount?.profile;
    return UserProfile(
      nickname: profile?.nickname,
      profileImage: profile?.profileImageUrl ?? '',
    );
  }

  void _handleLoginError(BuildContext context, dynamic error) {
    _showErrorMessage(context, '카카오 로그인 실패');
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class UserProfile {
  final String? nickname;
  final String profileImage;

  UserProfile({required this.nickname, required this.profileImage});
}
