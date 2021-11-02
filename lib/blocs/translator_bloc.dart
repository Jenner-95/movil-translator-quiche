import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorBloc {
  int _fromLang;
  int _toLang;
  bool _checkedValue = false;
  String _imageURL; 
  dynamic _google;
  TranslatorBloc() {
    _fromLang = 1;
    _toLang = 2;
    _google = null;
  }
  final _controllerText = StreamController<String>();
  Stream<String> get streamTranslator => _controllerText.stream;

  final _controllerFromLang = StreamController<int>();
  Stream<int> get streamFromLang => _controllerFromLang.stream;

  final _controllerToLang = StreamController<int>();
  Stream<int> get streamToLang => _controllerToLang.stream;

  // final _controllercheckedValue = StreamController<bool>();
  // Stream<bool> get streamcheckedValue => _controllercheckedValue.stream;

  set checkedValue(bool newValue) => _checkedValue = newValue;
  get imageURL => _imageURL;

  Future<void> translator(String text) async {
    print(text);
    if (text == "Escribiendo...") {
      _controllerText.add(text);
    } else if (text == "" || text.isEmpty || text.length == 0) {
      _controllerText.add("");
    } else {
        String json = jsonEncode({
          "translated_from": _fromLang,
          'text': text, 
          'single_word': _checkedValue
        });
        var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2MDU5NjM1LCJqdGkiOiJjZDQxMDVjMjdkOWM0OGJjODRmZWM4MjY1ZmNjYTRjNCIsInVzZXJfaWQiOjYsInVzZXIiOnsiaWQiOjYsImxhc3RfbG9naW4iOm51bGwsInVzZXJuYW1lIjoid2ViIiwiZmlyc3RfbmFtZSI6IldlYiIsImxhc3RfbmFtZSI6IkRlc2Fycm9sbG8iLCJpc19hY3RpdmUiOnRydWUsImRhdGVfam9pbmVkIjoiMjAyMS0xMC0zMFQxNTowMDoxNS40Nzc0MzgtMDY6MDAiLCJwcm9maWxlIjp7ImlkIjo2LCJiaXJ0aF9kYXRlIjoiMjAwOS0wNS0wNyIsInVzZXIiOjZ9fX0.fh52ldzX8dQ4dCB83Mn6DS_UlMJxZaXOVWMR8itRJR4";
        var response = await http.post(Uri.parse("https://translator-umg.herokuapp.com/webservice/translate/"), 
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json,
        )
        .then((http.Response serverResponse) {
          if (serverResponse.statusCode == 200) {           
            print(serverResponse.body);
            return jsonDecode(serverResponse.body);
          } else {
            print(serverResponse.statusCode);
            return serverResponse.statusCode;
          }
        })
        .catchError((onError){
          print(onError);
        });
        _controllerText.add(response[0]['translation']);
        _imageURL = response[0]['image_url'];

      
    }
  }

  void fromLang(int fromLang) {
    _fromLang = fromLang;
    _controllerFromLang.add(fromLang);
  }

  void toLang(int toLang) {
    _toLang = toLang;
    _controllerToLang.add(toLang);
  }

}
