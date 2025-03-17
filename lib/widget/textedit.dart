import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:picturediary/SDK/stablediffusion_controller.dart';
import 'package:picturediary/widget/calendar_screen.dart';
import 'package:picturediary/widget/result_screen.dart';

class TextEditPage extends StatefulWidget {
  String text;
  final DateTime selectedDate;
  TextEditPage({required this.text, required this.selectedDate});

  _EditTextPageState createState() => _EditTextPageState();
}

class _EditTextPageState extends State<TextEditPage> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {

    var imageList;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.format_paint_outlined),
            onPressed: () async {
              setState(() {
                _isLoading = true; // 로딩 시작
              });

              final image_url = Uri.parse(
        'http://playground.aieev.cloud:7004/stable_diffusion_2/text_to_image');


                List<String> imageList =
                    await StableManager().convertTextToImage(_controller.text, image_url);


              setState(() {
                _isLoading = false; // 로딩 종료
              });

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    selectedDate: widget.selectedDate,
                    images: imageList,
                    text: widget.text,
                  ),
                ),
              );

              if (result == true) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(),
                  ),
                );
              }

              print(widget.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints.expand(),
                    ),
                    // 중앙에 스피너와 텍스트 배치
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            itemBuilder: (BuildContext context, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Color.fromARGB(255, 240, 255, 103)
                                      : Color.fromARGB(221, 106, 255, 101),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20), // 간격 조절
                          Text(
                            '그림 일기가 생성중이에요!',
                            style: TextStyle(
                              color: Color.fromARGB(221, 125, 219, 122),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      '일기를 다 작성했어요!',
                      style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
                    ),
                    Text(
                      '내용을 보충해도 좋아요.',
                      style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
                    ),
                    SizedBox(height: 50),
                    TextField(
                      controller: _controller,
                      onChanged: (newText) {
                        setState(() {
                          widget.text = newText;
                        });
                      },
                      minLines: 10,
                      maxLines: null,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '작성된 일기',
                        hintText: 'Start editing...',
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
