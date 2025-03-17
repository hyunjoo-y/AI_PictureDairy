import 'dart:io';

import 'package:picturediary/widget/home.dart';
import 'package:picturediary/widget/voicerecord.dart';
import 'package:picturediary/widget/diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:picturediary/SDK/database_helper.dart'; // 실제 경로에 맞게 수정하세요

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<ImageData>> _events = {};
  List<ImageData> _selectedDayData = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final allData = await _dbHelper.fetchAllImageData();
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

    setState(() {
      _events = tempEvents;
      _loadDataForSelectedDay(_selectedDay); // 초기 로드 시 선택된 날짜 데이터 로드
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFd8eff8),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.black), // 원하는 아이콘과 색상
          onPressed: () async {
            // 뒤로 가기 동작
            var userData = await DatabaseHelper().fetchUserData();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userData: userData!,
                ),
              ),
            );
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          await _loadAllData();
          return true;
        },
        child: Column(
          children: [
            Container(
              height: size.height * 0.7, // 캘린더 높이 조정
              width: size.width,
              padding: EdgeInsets.all(0),
              child: TableCalendar(
                shouldFillViewport: true,
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadDataForSelectedDay(selectedDay);
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  DateTime dateWithoutTime =
                      DateTime(day.year, day.month, day.day);
                  return _events[dateWithoutTime] ?? [];
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFd8eff8),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF2989a6),
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                      color: Colors.red, fontFamily: 'daehan', fontSize: 19),
                  defaultTextStyle: TextStyle(
                      color: Colors.black, fontFamily: 'daehan', fontSize: 19),
                  holidayTextStyle: TextStyle(
                      color: Colors.blue, fontFamily: 'daehan', fontSize: 19),
                  cellMargin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date),
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                      fontSize: 20.0,
                      color: Color(0xFF2989a6),
                      fontFamily: 'daehan'),
                  headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
                  leftChevronIcon: const Icon(
                    color: Color(0xFF2989a6),
                    Icons.arrow_left,
                    size: 40.0,
                  ),
                  rightChevronIcon: const Icon(
                    color: Color(0xFF2989a6),
                    Icons.arrow_right,
                    size: 40.0,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      ImageData firstEvent = events.first as ImageData;
                      return Positioned(
                        child: GestureDetector(
                          onDoubleTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DairyPage(diaryEntry: firstEvent),
                              ),
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: FileImage(File(firstEvent.image)),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              width: 30,
                              height: 28),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedDayData.length,
                itemBuilder: (context, index) {
                  final item = _selectedDayData[index];
                  return ListTile(
                    title: Text(
                      item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading:
                        Image.file(File(item.image), width: 50, height: 50),
                    subtitle: Text('날짜: ${item.date}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.deleteImageData(item.id!);
                        setState(() {
                          _selectedDayData.removeAt(index);
                        });

                        await _loadDataForSelectedDay(_selectedDay);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('데이터가 삭제되었습니다.')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DairyPage(diaryEntry: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VoiceRecorder(selectedDate: _selectedDay),
                    ),
                  );

                  if (result == true) {
                    await _loadAllData(); // 전체 데이터 새로 고침
                    await _loadDataForSelectedDay(
                        _selectedDay); // 선택된 날짜 데이터 새로 고침
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2989a6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80.0, vertical: 12.0),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('새로운 일기 쓰기'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDataForSelectedDay(DateTime day) async {
    DateTime dateWithoutTime = DateTime(day.year, day.month, day.day);
    final data = _events[dateWithoutTime] ?? [];
    setState(() {
      _selectedDayData = data;
    });
  }
}
