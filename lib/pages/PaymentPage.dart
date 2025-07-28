import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String nickname;
  final String profileImage;

  const PaymentPage({super.key, required this.nickname, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제 페이지')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('환영합니다, $nickname 님!', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            profileImage.isNotEmpty
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profileImage),
                  )
                : const Icon(Icons.account_circle, size: 80),
          ],
        ),
      ),
    );
  }
}
