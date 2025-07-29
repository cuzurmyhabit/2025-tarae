import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'PaymentPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> _loginWithKakao(BuildContext context) async {
    try {
      OAuthToken token;

      // 카카오톡이 설치되어 있는지 확인 후 로그인
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공: ${token.accessToken}');
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오 계정으로 로그인 성공: ${token.accessToken}');
      }

      // 사용자 정보 요청
      User user = await UserApi.instance.me();
      print('사용자 전체 정보: ${jsonEncode(user)}');

      if (user.kakaoAccount?.profileNicknameNeedsAgreement == true ||
          user.kakaoAccount?.profileImageNeedsAgreement == true) {
        await UserApi.instance.loginWithNewScopes(['profile_nickname', 'profile_image']);
        user = await UserApi.instance.me();
        print('추가 동의 후 사용자 정보: ${jsonEncode(user)}');
      }

      final nickname = user.kakaoAccount?.profile?.nickname;
      final profileImage = user.kakaoAccount?.profile?.profileImageUrl;

      if (nickname != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              nickname: nickname,
              profileImage: profileImage ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임 정보를 가져올 수 없습니다.')),
        );
      }
    } catch (e) {
      print('카카오 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 로그인 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/loginIcon.svg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              '음성으로 한번에 택시 호출',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            const Text(
              '보다 쉽고 단순한 택시 호출 서비스',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 115, left: 20, right: 20),
        child: SizedBox(
          height: 56,
          child: Material(
            color: const Color(0xFFFAE100),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _loginWithKakao(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/kakaoIcon.svg',
                    width: 24,
                    height: 24,
                  ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
