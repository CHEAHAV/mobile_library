import 'package:frontend/devices/device.dart';
export 'package:frontend/apis/book_api.dart';      
export 'package:frontend/apis/category_api.dart';

class ApiService {

  // toggle: true = use ngrok, false = use local
  static const bool useNgrok = true;
  // update this every time after restart ngrok
  static const String ngrokUrl = 'https://ellsworth-laughterless-mora.ngrok-free.dev';

   // baseUrl auto-picks ngrok or local device URL
  static String _baseUrl = ngrokUrl;
  static String get baseUrl => _baseUrl;

  // headers — ngrok warning skip only applied when using ngrok
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (useNgrok) 'ngrok-skip-browser-warning': 'true',
      };

  static Future<void> init() async {
    _baseUrl = useNgrok ? ngrokUrl : await Device.localUrl;
  }
}