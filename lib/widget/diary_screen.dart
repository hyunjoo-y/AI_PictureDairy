import 'dart:io';

import 'package:picturediary/SDK/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DairyPage extends StatelessWidget {
  final ImageData diaryEntry;

  DairyPage({required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    List<String> contents = diaryEntry.text.split('');
    DateTime parsedDate = DateTime.parse(diaryEntry.date);

// 날짜를 '년 월 일' 형식으로 포맷팅
    String formattedDate = DateFormat('yyyy년 MM월 dd일').format(parsedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
              'assets/background.png'), // Specify your image path here
          fit: BoxFit.fill, // This will fill the background of Container
        )),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range), // 날짜 아이콘
                        SizedBox(width: 8),
                        Text(
                          '날짜: $formattedDate',
                          style: const TextStyle(
                              fontFamily: 'daehan',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny), // 날씨 아이콘 (맑음)
                        SizedBox(width: 8),
                        Text(
                          'Sunny',
                          style: TextStyle(fontFamily: 'daehan'),
                        ), // 날씨 설명
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Image.file(
                  // Image.network에서 Image.file로 변경
                  File(diaryEntry.image), // File 객체를 생성하여 경로를 전달
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: contents.length, // 총 칸의 수
                  itemBuilder: (context, index) {
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        index < contents.length
                            ? contents[index]
                            : '', // 존재하는 글자면 표시, 그렇지 않으면 빈 칸
                        style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
