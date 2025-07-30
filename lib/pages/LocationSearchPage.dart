import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../widgets/NextButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/StartPage.dart'; // InnerMap 대신 StartPage를 임포트합니다.

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});
  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _allPlaces = [];
  List<dynamic> _places = [];
  bool _isLoading = false;
  bool _noResults = false;
  bool _hasSearched = false;
  final List<dynamic> _selectedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadPlacesFromJson();
  }

  Future<void> _loadPlacesFromJson() async {
    final String response = await rootBundle.loadString('assets/places.json');
    final data = json.decode(response) as List;
    _allPlaces = data;
  }

  void _searchPlace(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _noResults = false;
      _hasSearched = true;
    });

    final results = _allPlaces.where((place) {
      final name = place['place_name'].toString();
      final address = place['address_name'].toString();
      return name.contains(query) || address.contains(query);
    }).toList();

    setState(() {
      _places = results;
      _noResults = results.isEmpty;
      _isLoading = false;
    });
  }

  void _showPlaceModal(dynamic place) {
    final TextEditingController modalController = TextEditingController();

    void showDuplicateDialog(String name) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("중복된 이름"),
            content: Text("이미 등록된 장소 이름입니다.\n‘$name’으로 등록된 장소를 현재 선택한 주소로 수정할까요?"),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    final index = _selectedPlaces.indexWhere((p) => p['custom_name'] == name);
                    if (index != -1) {
                      _selectedPlaces[index] = {
                        'custom_name': name,
                        'place_name': place['place_name'],
                        'address_name': place['address_name'],
                        'x': place['x'],
                        'y': place['y'],
                      };
                    }
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("예"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("아니오"),
              ),
            ],
          );
        },
      );
    }

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
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
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/makerIcon.svg',
                      width: 48,
                      height: 48,
                    ),
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF58606E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: modalController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '장소 이름을 입력해주세요',
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final enteredName = modalController.text.trim();
                      if (enteredName.isEmpty) return;

                      final isDuplicate = _selectedPlaces.any((p) => p['custom_name'] == enteredName);
                      if (isDuplicate) {
                        showDuplicateDialog(enteredName);
                      } else {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedPlaces.add({
                            'custom_name': enteredName,
                            'place_name': place['place_name'],
                            'address_name': place['address_name'],
                            'x': place['x'],
                            'y': place['y'],
                          });
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B7EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                ),
              ],
            ),
          ),
        );
      },
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
        onTap: () {
          _showPlaceModal(place);
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSelectedPlaces() {
    if (_selectedPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      children: _selectedPlaces.map((place) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/starIcon.svg',
              width: 24,
              height: 24,
            ),
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '내 장소 설정',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('건너뛰기', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
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
                    controller: _controller,
                    onSubmitted: _searchPlace,
                    decoration: const InputDecoration(
                      hintText: '장소 검색 (예: 강남역, 스타벅스)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _searchPlace(_controller.text),
                  child: SvgPicture.asset(
                    'assets/icons/searchIcon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),
                SvgPicture.asset(
                  'assets/icons/micIcon.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedPlaces(),
          if (_selectedPlaces.isNotEmpty) const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? (_noResults
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text("검색 결과가 없습니다", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                Text("다른 키워드로 검색해보세요", style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _places.length,
                            itemBuilder: (context, index) => _buildPlaceItem(_places[index]),
                          ))
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              '저장하고 싶은 장소를 검색해 저장해주세요!',
                              style: TextStyle(fontSize: 18, color: Color(0xFF4A4A4A), fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
          ),
          NextButton(
            isEnabled: _selectedPlaces.isNotEmpty,
            onPressed: _selectedPlaces.isNotEmpty
                ? () {
                    // StartPage로 선택된 장소 목록 전체를 전달합니다.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartPage(
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
