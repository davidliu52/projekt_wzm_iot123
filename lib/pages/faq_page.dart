// Importieren benötigter Packages
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accordion/accordion.dart';



class FAQPage extends Page{

  static final pageName = 'FAQPage'; // Definition des Pagename

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>FAQWidget());
  }

}

class FAQWidget extends StatefulWidget {
  const FAQWidget({Key? key}) : super(key: key);

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();

  void ipsetting(String ip_adresse) async{
    var Body = {"email": ip_adresse};
    try{

      Response response = await post(
        //TODO: entsprechende url eingeben
          Uri.parse('http://172.30.240.1:8080/api/noauth/resetPasswordByEmail'),
          headers: {
            "Content-Type": "application/json"
          },

          body: json.encode(Body)

      );
      var jsonData = null;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      print(response.body);
      print(response.statusCode);
      if(response.statusCode == 200){
        //jsonData = json.decode(response.body);
        print('Email wurde erfolgreich gesendet!');
        Provider.of<PageNotifier>(context, listen: false).goToAuth();


      }else{
        print(response.body);
        print(ip_adresse);
        //Provider.of<PageNotifier>(context, listen: false).goToMain();

      }
    }catch(e){
      print(e.toString());
    }

  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('FAQ'),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(23, 156, 125, 1),
              elevation: 0.0,
              actions: <Widget>[


              ],



            ),


            body: Accordion(
              maxOpenSections: 1,
              children: [
                AccordionSection(
                    headerBackgroundColor: Color.fromRGBO(23, 156, 125, 0.5),
                    contentBorderColor: Color.fromRGBO(23, 156, 125, 1),
                    header: Text('Was ist Fraunhofer?'),
                    content: Text('Die Fraunhofer-Gesellschaft mit Sitz in Deutschland ist die weltweit führende Organisation für anwendungsorientierte Forschung.')
                ),
                AccordionSection(
                    headerBackgroundColor: Color.fromRGBO(23, 156, 125, 0.5),
                    contentBorderColor: Color.fromRGBO(23, 156, 125, 1),
                    header: Text('Was ist diese App?'),
                    content: Text('Diese App ist mobile Applikation zur Unterstützung eines IoT-Systems.')
                ),
                AccordionSection(
                    headerBackgroundColor: Color.fromRGBO(23, 156, 125, 0.5),
                    contentBorderColor: Color.fromRGBO(23, 156, 125, 1),
                    header: Text('Was ist IoT?'),
                    content: Text('IoT ist Abkürzung von den englischen Wörtern: Internet of Things.')
                ),
                AccordionSection(
                    headerBackgroundColor: Color.fromRGBO(23, 156, 125, 0.5),
                    contentBorderColor: Color.fromRGBO(23, 156, 125, 1),
                    header: Text('Ich kann nicht einloggen. Was soll ich tun?'),
                    content: Text('1. IP-Adresse prüfen. In \'Einstellung\' kann die in dieser App eingestellte IP-Adresse geprüft werden. Falls die IP-Adresse nicht richtig ist, kann die richtige IP-Adresse dort eingegeben und gespeichert werden. 2. Es soll sichergestellt werden, dass Host mit Thingsboard Server verbunden ist, ansonsten kann man nicht einloggen.')
                ),
            ],


          ),
        ),
        ),
      ),
    );
  }

}


