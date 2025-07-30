import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/NextButton.dart';
import '../pages/LocationSearchPage.dart';

class PaymentPage extends StatefulWidget {
  final String? nickname;
  final String? profileImage;
  
  const PaymentPage({
    Key? key,
    this.nickname,
    this.profileImage,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = '신용/체크카드';
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isFormValid {
    if (selectedPaymentMethod == '만나서 결제') {
      return true; 
    }
    
    return cardNumberController.text.replaceAll('-', '').length == 16 &&
           cvcController.text.length == 3 &&
           expiryController.text.length == 5 &&
           passwordController.text.length == 2;
  }

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(() => setState(() {}));
    cvcController.addListener(() => setState(() {}));
    expiryController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    cvcController.dispose();
    expiryController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String formatCardNumber(String value) {
    value = value.replaceAll('-', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += value[i];
    }
    return formatted;
  }

  String formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  void _handleNextButton() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const LocationSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '결제 수단 등록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 결제 수단 선택 버튼
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodButton(
                          '신용/체크카드', 
                          selectedPaymentMethod == '신용/체크카드'
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodButton(
                          '만나서 결제', 
                          selectedPaymentMethod == '만나서 결제'
                        ),
                      ),
                    ],
                  ),
                  
                  if (selectedPaymentMethod == '신용/체크카드') ...[
                    const SizedBox(height: 32),
                    
                    const Text('카드번호', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 54,
                      child: TextField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        onChanged: (value) {
                          if (value.length <= 16) {
                            final formatted = formatCardNumber(value);
                            cardNumberController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: '- - - -',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4E71FF)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(fontSize: 18, letterSpacing: 2),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CVC', style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 54,
                                child: TextField(
                                  controller: cvcController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  obscureText: true,
                                  decoration: _inputDecoration('123'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('유효기간', style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 54,
                                child: TextField(
                                  controller: expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  onChanged: (value) {
                                    if (value.length <= 4) {
                                      final formatted = formatExpiry(value);
                                      expiryController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(offset: formatted.length),
                                      );
                                    }
                                  },
                                  decoration: _inputDecoration('MM/YY'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text('카드 비밀번호', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 171,
                      height: 54,
                      child: TextField(
                        controller: passwordController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        obscureText: true,
                        decoration: _inputDecoration('비밀번호 앞 2자리'),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '택시에서 내릴 때 카드나 현금으로 결제해주세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          NextButton(
            isEnabled: isFormValid,
            onPressed: _handleNextButton,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4E71FF)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPaymentMethodButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },
      child: Container(
        height: 81,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4E71FF) : Colors.grey[300]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isSelected ? const Color(0xFF4E71FF) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
