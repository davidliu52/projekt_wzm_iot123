// Importieren benötigter Packages
import 'package:flutter/material.dart';
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


