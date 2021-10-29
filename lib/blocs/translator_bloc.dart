import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorBloc {
  String _fromLang;
  String _toLang;
  dynamic _google;
  TranslatorBloc() {
    _fromLang = "es";
    _toLang = "en";
    _google = null;
  }
  final _controllerText = StreamController<String>();
  Stream<String> get streamTranslator => _controllerText.stream;

  final _controllerFromLang = StreamController<String>();
  Stream<String> get streamFromLang => _controllerFromLang.stream;

  final _controllerToLang = StreamController<String>();
  Stream<String> get streamToLang => _controllerToLang.stream;


final Map<String, dynamic> activityData = {
      "translated_from": "1",
      'text': "mujer", 
      'single_word': "false"
    };
  void translator(String text) async {
    print(text);
    if (text == "Escribiendo...") {
      _controllerText.add(text);
    } else if (text == "" || text.isEmpty || text.length == 0) {
      _controllerText.add("");
    } else {
      try {
        var url = Uri.parse('https://translator-umg.herokuapp.com/webservice/translate/');
      var response = await http.post(url, 
      headers: {
      "content-type": "application/json",
      },
      body: jsonEncode({
        "translated_from": "1",
        'text': text, 
        'single_word': "false"
      }),
      );
      print(response);
      } catch (e) {
        print('$e error');
      }
      
      
                // _controllerText.add(_google);


      // final translator = GoogleTranslator();
      // if (text != null) {
      //   _google = await translator.translate(text,
      //       from: '$_fromLang', to: '$_toLang');
      //   if (_google != null) {
      //     print("$_google");
      //     _controllerText.add(_google);
      //   }
      // }
    }
  }

  void fromLang(String fromLang) {
    _fromLang = fromLang;
    _controllerFromLang.add(fromLang);
  }

  void toLang(String toLang) {
    _toLang = toLang;
    _controllerToLang.add(toLang);
  }
}
