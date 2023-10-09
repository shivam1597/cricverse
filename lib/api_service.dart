import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiService {
  final String apiUrl;
  int durationInterval;
  late StreamController<dynamic> _controller;

  ApiService(this.apiUrl, this.durationInterval) {
    _controller = StreamController<dynamic>.broadcast();
    fetchData();
  }

  Stream<dynamic> get stream => _controller.stream;

  Future<void> fetchData() async {
    while (true) {
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if(!_controller.isClosed){
            _controller.sink.add(data);
          }
        } else {
          // Handle errors here
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network or other exceptions
        print('Error: $e');
      }
      await Future.delayed(Duration(seconds: durationInterval)); // Fetch data every 10 seconds
    }
  }

  void dispose() {
    _controller.close();
  }
}