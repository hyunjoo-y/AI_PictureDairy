import 'dart:convert';
import 'package:http/http.dart' as http;

class StableManager {
  final _apiKey = "api_KEY";
  Stopwatch _stopwatch = Stopwatch();
  var _elapsedTime;

  Future<List<String>> convertTextToImage(String prompt, Uri image_url) async {
    final url = 'https://translation.googleapis.com/language/translate/v2?key=$_apiKey';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'q': prompt,
        'target': 'en',
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
        prompt = responseData['data']['translations'][0]['translatedText'];
    } else {
        prompt = '번역 중 오류가 발생했습니다.';
    }

    // 요청 본문 데이터 설정
    Map<String, dynamic> requestData = {
      "prompt": prompt,
      "negative_prompt": "No humans, no animals, no buildings, no text, no vehicles, no modern technology.",
      "seed": 10101022333,
      "height": 1024,
      "width": 1024,
      "scheduler": "Euler a",
      "num_inference_steps": 30,
      "guidance_scale": 8,
      "num_images": 1
    };

    print(requestData);


    _stopwatch.start();
    try {
      var response = await http.post(
        image_url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 307) {
      // Location 헤더에서 리디렉션 URL 가져오기
      var newUrl = response.headers['location'];
      if (newUrl != null) {
        // 새 URL로 다시 요청 보내기
        response = await http.post(
          Uri.parse(newUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: requestData,
        );
      }
    }

    _stopwatch.stop();
    print('Experiment Image Generation avg Time: ${_stopwatch.elapsedMilliseconds} ms');

      if (response.statusCode != 200) {
        print("200 실패");
        print(response.body);
        return ["null"];
      } else {
        try {
          final responseData = jsonDecode(response.body);
          final resultImages = responseData['images'] as List<dynamic>;

          return resultImages.map((image) => image.toString()).toList();
        } catch (e) {
          print("응답 데이터 파싱 오류: $e");
          return ["null"];
        }
      }
    } catch (e) {
      print("HTTP 요청 실패: $e");
      return ["null"];
    }
  }

  // 주어진 URL로부터 이미지를 다운로드하고 크기를 KB 단위로 반환
  Future<double> getImageSizeFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // 바이트 크기를 KB로 변환
        return response.bodyBytes.length / 1024;
      } else {
        print("이미지 다운로드 실패: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("이미지 다운로드 오류: $e");
      return 0;
    }
  }

}
