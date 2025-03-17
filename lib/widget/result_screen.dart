import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:picturediary/SDK/database_helper.dart';

class ResultScreen extends StatefulWidget {
  final List<String> images;
  final String text;
  final DateTime selectedDate;

  ResultScreen(
      {required this.images, required this.text, required this.selectedDate});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int selectedIndex = 0;
  PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ImageData> savedData = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final allData = await _dbHelper.fetchAllImageData();
    setState(() {
      // Filter data for the selected date only
      savedData = allData.where((item) {
        return item.date ==
            "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";
      }).toList();
    });
  }

  Future<String> _downloadImage(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: widget.images.length,
              controller: _pageController,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => _showImageDialog(widget.images[index]),
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = isSelected ? 1.0 : 0.9;
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF2989a6)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.network(
                          widget.images[index],
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                );
              },
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
                ),
              ),
            ),
          ),
          if (selectedIndex >= 0)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: Container(
                  width: 300,
                  height: 50,
                  child: SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        DateTime now = widget.selectedDate;
                        String formattedDate =
                            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                        // Save the selected image locally
                        String imageUrl = widget.images[selectedIndex];
                        String imagePath = await _downloadImage(imageUrl,
                            'image_${DateTime.now().millisecondsSinceEpoch}.jpg');

                        await _dbHelper.insertImageData(ImageData(
                          image: imagePath,
                          text: widget.text,
                          date: formattedDate,
                        ));

                        _loadSavedData(); 
                        // 캘린더 페이지로 돌아가기
                        // Navigator.popUntil(
                        //     context, (route) => route.settings.name == '/calendar');
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        '일기 저장',
                        style: TextStyle(fontFamily: 'daehan', fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
