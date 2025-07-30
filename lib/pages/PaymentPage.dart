import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/NextButton.dart';
import '../pages/LocationSearchPage.dart';

class PaymentPage extends StatefulWidget {
  final String? nickname;
  final String? profileImage;

  const PaymentPage({super.key, this.nickname, this.profileImage});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = '신용/체크카드';

  late final TextEditingController cardNumberController;
  late final TextEditingController cvcController;
  late final TextEditingController expiryController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _addListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    cardNumberController = TextEditingController();
    cvcController = TextEditingController();
    expiryController = TextEditingController();
    passwordController = TextEditingController();
  }

  void _addListeners() {
    cardNumberController.addListener(_updateState);
    cvcController.addListener(_updateState);
    expiryController.addListener(_updateState);
    passwordController.addListener(_updateState);
  }

  void _disposeControllers() {
    cardNumberController.dispose();
    cvcController.dispose();
    expiryController.dispose();
    passwordController.dispose();
  }

  void _updateState() => setState(() {});

  bool get _isFormValid {
    if (selectedPaymentMethod == '만나서 결제') return true;

    return _isCardNumberValid &&
        _isCvcValid &&
        _isExpiryValid &&
        _isPasswordValid;
  }

  bool get _isCardNumberValid =>
      cardNumberController.text.replaceAll('-', '').length == 16;
  bool get _isCvcValid => cvcController.text.length == 3;
  bool get _isExpiryValid => expiryController.text.length == 5;
  bool get _isPasswordValid => passwordController.text.length == 2;
  bool get _isCardPayment => selectedPaymentMethod == '신용/체크카드';

  String _formatCardNumber(String value) {
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

  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  void _onCardNumberChanged(String value) {
    if (value.length <= 16) {
      final formatted = _formatCardNumber(value);
      cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onExpiryChanged(String value) {
    if (value.length <= 4) {
      final formatted = _formatExpiry(value);
      expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          ),
          NextButton(isEnabled: _isFormValid, onPressed: _handleNextButton),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pushNamed(context, '/'),
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
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentMethodSelector(),
        if (_isCardPayment) _buildCardForm() else _buildCashPaymentInfo(),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Row(
      children: [
        Expanded(child: _buildPaymentMethodButton('신용/체크카드')),
        const SizedBox(width: 12),
        Expanded(child: _buildPaymentMethodButton('만나서 결제')),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String title) {
    final isSelected = selectedPaymentMethod == title;

    return GestureDetector(
      onTap: () => _onPaymentMethodSelected(title),
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

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildCardNumberField(),
        const SizedBox(height: 24),
        _buildCvcAndExpiryRow(),
        const SizedBox(height: 24),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            onChanged: _onCardNumberChanged,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 18, letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildCvcAndExpiryRow() {
    return Row(
      children: [
        Expanded(child: _buildCvcField()),
        const SizedBox(width: 16),
        Expanded(child: _buildExpiryField()),
      ],
    );
  }

  Widget _buildCvcField() {
    return Column(
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
            decoration: _buildInputDecoration('123'),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryField() {
    return Column(
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
            onChanged: _onExpiryChanged,
            decoration: _buildInputDecoration('MM/YY'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            decoration: _buildInputDecoration('비밀번호 앞 2자리'),
          ),
        ),
      ],
    );
  }

  Widget _buildCashPaymentInfo() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            '택시에서 내릴 때 카드나 현금으로 결제해주세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
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
}
