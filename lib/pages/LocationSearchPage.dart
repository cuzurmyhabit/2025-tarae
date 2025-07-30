import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../widgets/NextButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/StartPage.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allPlaces = [];
  List<dynamic> _searchResults = [];
  final List<dynamic> _selectedPlaces = [];

  bool _isLoading = false;
  bool _noResults = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadPlacesData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlacesData() async {
    try {
      final String response = await rootBundle.loadString('assets/places.json');
      final data = json.decode(response) as List;
      setState(() {
        _allPlaces = data;
      });
    } catch (e) {
      print('장소 데이터 로드 실패: $e');
    }
  }

  void _searchPlace(String query) {
    if (query.trim().isEmpty) return;

    _setLoadingState(true);

    final results = _filterPlaces(query);

    setState(() {
      _searchResults = results;
      _noResults = results.isEmpty;
      _isLoading = false;
      _hasSearched = true;
    });
  }

  List<dynamic> _filterPlaces(String query) {
    return _allPlaces.where((place) {
      final name = place['place_name']?.toString().toLowerCase() ?? '';
      final address = place['address_name']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();
  }

  void _setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
      _noResults = false;
      if (isLoading) _hasSearched = true;
    });
  }

  void _showPlaceModal(dynamic place) {
    final modalController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _buildPlaceModal(place, modalController),
    );
  }

  Widget _buildPlaceModal(dynamic place, TextEditingController controller) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 358,
        height: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlaceInfo(place),
            const SizedBox(height: 24),
            _buildNameInput(controller),
            const Spacer(),
            _buildModalButton(place, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo(dynamic place) {
    return Row(
      children: [
        SvgPicture.asset('assets/icons/makerIcon.svg', width: 48, height: 48),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['place_name'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF434A54),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                place['address_name'] ?? '',
                style: const TextStyle(fontSize: 16, color: Color(0xFF58606E)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        hintText: '장소 이름을 입력해주세요',
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildModalButton(dynamic place, TextEditingController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/innerMap'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B7EFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          '다음',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handlePlaceSelection(dynamic place, TextEditingController controller) {
    final enteredName = controller.text.trim();
    if (enteredName.isEmpty) return;

    final isDuplicate = _checkDuplicateName(enteredName);

    if (isDuplicate) {
      _showDuplicateDialog(enteredName, place);
    } else {
      _addSelectedPlace(enteredName, place);
      Navigator.of(context).pop();
    }
  }

  bool _checkDuplicateName(String name) {
    return _selectedPlaces.any((place) => place['custom_name'] == name);
  }

  void _showDuplicateDialog(String name, dynamic place) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("중복된 이름"),
            content: Text(
              "이미 등록된 장소 이름입니다.\n'$name'으로 등록된 장소를 현재 선택한 주소로 수정할까요?",
            ),
            actions: [
              TextButton(
                onPressed: () => _updateExistingPlace(name, place),
                child: const Text("예"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("아니오"),
              ),
            ],
          ),
    );
  }

  void _updateExistingPlace(String name, dynamic place) {
    setState(() {
      final index = _selectedPlaces.indexWhere((p) => p['custom_name'] == name);
      if (index != -1) {
        _selectedPlaces[index] = _createPlaceData(name, place);
      }
    });
    Navigator.of(context).pop(); // 중복 다이얼로그 닫기
    Navigator.of(context).pop(); // 장소 모달 닫기
  }

  void _addSelectedPlace(String name, dynamic place) {
    setState(() {
      _selectedPlaces.add(_createPlaceData(name, place));
    });
  }

  Map<String, dynamic> _createPlaceData(String customName, dynamic place) {
    return {
      'custom_name': customName,
      'place_name': place['place_name'],
      'address_name': place['address_name'],
      'x': place['x'],
      'y': place['y'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildSelectedPlaces(),
          if (_selectedPlaces.isNotEmpty) const SizedBox(height: 24),
          Expanded(child: _buildContent()),
          _buildNextButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text(
        '내 장소 설정',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // 건너뛰기 페이지 바꾸기
          child: const Text(
            '건너뛰기',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: _searchPlace,
              decoration: const InputDecoration(
                hintText: '장소 검색 (예: 강남역, 스타벅스)',
                border: InputBorder.none,
              ),
            ),
          ),
          _buildSearchIcon(),
          const SizedBox(width: 12),
          _buildMicIcon(),
        ],
      ),
    );
  }

  Widget _buildSearchIcon() {
    return GestureDetector(
      onTap: () => _searchPlace(_searchController.text),
      child: SvgPicture.asset(
        'assets/icons/searchIcon.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildMicIcon() {
    return SvgPicture.asset(
      'assets/icons/micIcon.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
    );
  }

  Widget _buildSelectedPlaces() {
    if (_selectedPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _selectedPlaces.map(_buildSelectedPlaceItem).toList(),
    );
  }

  Widget _buildSelectedPlaceItem(dynamic place) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/starIcon.svg', width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['custom_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  place['address_name'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (!_hasSearched) return _buildInitialState();
    if (_noResults) return _buildNoResultsState();

    return _buildSearchResults();
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            '저장하고 싶은 장소를 검색해 저장해주세요!',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "검색 결과가 없습니다",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            "다른 키워드로 검색해보세요",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => _buildPlaceItem(_searchResults[index]),
    );
  }

  Widget _buildPlaceItem(dynamic place) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: SvgPicture.asset(
          'assets/icons/makerIcon.svg',
          width: 24,
          height: 24,
        ),
        title: Text(
          place['place_name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          place['address_name'] ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _showPlaceModal(place),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNextButton() {
    return NextButton(
      isEnabled: _selectedPlaces.isNotEmpty,
      onPressed: _selectedPlaces.isNotEmpty ? _handleNextButton : null,
    );
  }

  void _handleNextButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StartPage()),
    );
  }
}
