import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picturediary/SDK/database_helper.dart';
import 'package:picturediary/widget/home.dart';
import 'package:intl/intl.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart'; // 날짜 형식을 포맷하기 위해 필요합니다.

class UserDataInputScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  UserDataInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시작 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name 입력 필드
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // 테두리 선 없음
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Birthdate 입력 필드
            TextField(
              controller: birthdateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Birthdate',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // 테두리 선 없음
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy년 MM월 dd일').format(pickedDate);
                  birthdateController.text = formattedDate;
                }
              },
            ),
            Spacer(),
            // Save 버튼
            PrettyShadowButton(
              foregroundColor: Colors.black,
              verticalPadding: 20,
              horizontalPadding: 140,
              label: "시작하기",
              shadowColor: Color(0xFFd8eff8),
              onPressed: () async {
                // 유저 정보를 데이터베이스에 저장
                final userData = UserData(
                  name: nameController.text,
                  birthdate: birthdateController.text,
                );
                await DatabaseHelper().insertUserData(userData);

                // 저장 후 HomeScreen으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userData: userData),
                  ),
                );
              },
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
