import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../blocs/translator_bloc.dart';
import '../../widgets/home/result_card.dart';
import '../../../util/responsive.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamController<String> _streamWritingController = StreamController();
  TextEditingController _text = TextEditingController();
  bool checkedValue;
  bool change;
  bool translating;
  int fromLang;
  int toLang;
  bool obtenerTraduccion = false;
  final translatorBLoC = TranslatorBloc();
  Responsive _size;
  Stream<String> a;

  @override
  void initState() {
    translating = false;
    final debounce = StreamTransformer<String, String>.fromBind(
        (s) => s.debounce(const Duration(milliseconds: 350)));

    debounce.bind(_streamWritingController.stream).listen((s) {
      print("entro!! $s");
      translating = true;
      _translator(s);
    });

    _size = new Responsive(context);
    change = false;
    fromLang = 1;
    toLang = 2;
    checkedValue = false;

    super.initState();
  }

  _translator(text) {
    if (translating) {
      translatorBLoC.translator(text);
    } else {
      translatorBLoC.translator("");
    }
  }

  @override
  Widget build(BuildContext context) {
    FlatButton _changeLang = FlatButton(
      splashColor: Colors.grey[200],
      color: Colors.indigo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1000.0),
      ),
      child: Icon(
        Icons.autorenew,
        color: Colors.white,
      ),
      onPressed: () {
        int aux = fromLang;
        fromLang = toLang;
        toLang = aux;
        translatorBLoC.fromLang(fromLang);
        translatorBLoC.toLang(toLang);
      },
    );
    Container inputText = Container(
      height: _size.height() * 0.16,
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          TextField(
            textAlign: TextAlign.justify,
            minLines: 1,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (string) async {
              setState(() {
                obtenerTraduccion = true;
              });
              await translatorBLoC.translator(string);
              setState(() {
                obtenerTraduccion = false;
              });
            },
            // autocorrect: false,
            style: TextStyle(fontSize: 16.0),
            maxLength: 300,
            decoration: InputDecoration.collapsed(hintText: "Ingresa una palabra"),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: CupertinoButton(
                    child: StreamBuilder<int>(
                      stream: translatorBLoC.streamFromLang,
                      initialData: 0,
                      builder: (context, snapshot) {
                        return Text(
                          (snapshot.data == 2) ? "Kiche" : "Español",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                    onPressed: () => print(change ? "Kiche" : "Español"),
                  ),
                ),
                Container(
                  width: _size.width() * 0.15,
                  height: _size.height() * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(1000.0),
                  ),
                  child: _changeLang,
                ),
                Expanded(
                  child: CupertinoButton(
                    child: StreamBuilder<int>(
                      stream: translatorBLoC.streamToLang,
                      initialData: 0,
                      builder: (context, snapshot) {
                        return Text(
                          (snapshot.data == 1) ? "Español" : "Kiche",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                    onPressed: () => print(change ? "Kiche" : "Español"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _size.height() * 0.03,
          ),
          CheckboxListTile(
            title: Text("Palabra compuesta"),
            value: checkedValue,
            onChanged: (newValue) {
              print(newValue);
              setState(() {
                checkedValue = newValue;
                translatorBLoC.checkedValue = newValue;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Stack(
              children: <Widget>[
                inputText,
              ],
            ),
          ),
          SizedBox(
            height: _size.height() * 0.01,
          ),
          Builder(
            builder: (context) {
              while (obtenerTraduccion) {
                return CircularProgressIndicator();
              }
              if (translatorBLoC.imageURL != null) {
              return Image.network(translatorBLoC.imageURL,fit: BoxFit.fill, height: 150,
                loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null ? 
                          loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              );
                
              }
              return Container();
            }
          ),
           SizedBox(
            height: _size.height() * 0.01,
          ),
          ResultStream(stream: translatorBLoC.streamTranslator),          
        ],
      ),
    );
  }
}
