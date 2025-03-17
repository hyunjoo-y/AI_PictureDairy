import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:picturediary/SDK/database_helper.dart';
import 'package:picturediary/widget/voicerecord.dart';
import 'package:picturediary/widget/calendar_screen.dart';
import 'package:picturediary/widget/diary_screen.dart';

class HomeScreen extends StatefulWidget {
  UserData userData;
  HomeScreen({required this.userData});
  @override
  _HomeScreenstate createState() => _HomeScreenstate();
}

class _HomeScreenstate extends State<HomeScreen> {
  late List<ImageData> allData = [];
  ImageData viewDayImage = ImageData(image: '', text: '', date: '');

  final DatabaseHelper _dbHelper = DatabaseHelper();

  DateTime selectedDate = DateTime.now(); // 현재 날짜로 초기화

  @override
  void initState() {

    _loadAllData();

    super.initState();
  }

  Future<void> _loadAllData() async {
    allData = await _dbHelper.fetchAllImageData();
    print("Loaded ${allData.length} images."); // 로드된 데이터 수 확인

    Map<DateTime, List<ImageData>> tempEvents = {};
    for (var data in allData) {
      DateTime parsedDate = DateTime.parse(data.date);
      DateTime date = DateTime(
          parsedDate.year, parsedDate.month, parsedDate.day); // 시간 정보 제거

      if (!tempEvents.containsKey(date)) {
        tempEvents[date] = [];
      }
      tempEvents[date]?.add(data);
      print(
          "Date: $date, Events: ${tempEvents[date]?.length}"); // 파싱된 날짜 및 이벤트 수 로그
    }

    _loadDayImage();
  }

  void _loadDayImage() {
    DateTime now = selectedDate;
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    for (int i = 0; i < allData.length; i++) {
      if (allData[i].date.contains(formattedDate)) {
        viewDayImage = allData[i];
        print('VIEW IMAGE: $formattedDate ${viewDayImage.image}');
        setState(() {});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFd8eff8),
          centerTitle: true,
          title: const Text(
            '그림일기',
            style: TextStyle(
                fontSize: 24,
                fontFamily: 'daehan',
                color: Color.fromARGB(255, 3, 99, 122),
                fontWeight: FontWeight.w100,
                letterSpacing: 0.53),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          )),
          leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            },
            child: const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF2989a6)),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VoiceRecorder(
                            selectedDate: DateTime.now(),
                          )),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.draw_rounded,
                  color: Color(0xFF2989a6),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: Container(
              padding: const EdgeInsets.only(left: 30, bottom: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_outline_rounded),
                      ),
                      Container(
                        height: 22,
                        width: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2989a6),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 14),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.userData.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cake,
                                color: Color.fromARGB(255, 180, 180, 180),
                                size: 16), // 케이크 이모티콘 아이콘 추가
                            SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격
                            Text(
                              widget.userData.birthdate,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 114, 114, 114),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              getAppBarUI(),
              const SizedBox(
                height: 20,
              ),
              viewDayImage.image != ''
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DairyPage(
                              diaryEntry: viewDayImage,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1, 1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.file(
                            File(viewDayImage.image),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoiceRecorder(
                              selectedDate: selectedDate,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width - (40),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              image: viewDayImage.image == ''
                                  ? AssetImage('assets/blur.png')
                                  : Image.file(File(viewDayImage.image))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(1, 1),
                                  blurRadius: 5)
                            ]),
                      ),
                    ),
            ],
          ),
        ));
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  double topBarOpacity = 0.8; // topBarOpacity 초기값 설정

  // 날짜 포맷터
  final DateFormat dateFormat = DateFormat('dd MMM');

  // 날짜를 하루 전으로 변경하는 함수
  void _decrementDate() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
      viewDayImage = ImageData(image: '', text: '', date: '');
      _loadDayImage();
    });
  }

  // 날짜를 하루 후로 변경하는 함수
  void _incrementDate() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
      viewDayImage = ImageData(image: '', text: '', date: '');
      _loadDayImage();
    });
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(topBarOpacity),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32.0),
            ),
            // boxShadow: [] 제거함
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16 - 8.0 * topBarOpacity,
                    bottom: 12 - 8.0 * topBarOpacity),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'My Diary',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22 + 6 - 6 * topBarOpacity,
                            letterSpacing: 1.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      width: 38,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32.0)),
                        onTap: _decrementDate, // 날짜를 하루 전으로 변경
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                          Text(
                            dateFormat.format(selectedDate), // 포맷된 날짜 출력
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              letterSpacing: -0.2,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      width: 38,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32.0)),
                        onTap: _incrementDate, // 날짜를 하루 후로 변경
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
