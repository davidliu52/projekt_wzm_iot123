// Importieren benötigter Packages
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SettingPage extends Page{
  static final pageName = 'SettingPage'; // Definition des Pagename

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>SettingWidget());
  }

}

class SettingWidget extends StatefulWidget {
  const SettingWidget({Key? key}) : super(key: key);

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _IPController = TextEditingController();

  void ipsetting(String ip_adresse) {
      IP = ip_adresse;
      thingsBoardApiEndpoint = IP;
      print('Neue IP-Adresse ist $ip_adresse');
      print('Neue Thingsboard API End Point ist $thingsBoardApiEndpoint');
      print('IP-Adresse wurde erfolgreich gesendet!');
      Provider.of<PageNotifier>(context, listen: false).goToMain();

      }




  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Einstellung'),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(23, 156, 125, 1),
              elevation: 0.0,
              actions: <Widget>[


              ],



            ),


            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  reverse: false,
                  padding: EdgeInsets.fromLTRB((MediaQuery.of(context).size.width-320)/2, 30, (MediaQuery.of(context).size.width-320)/2, 30),
                  children: [
                    SizedBox(height: 100,),

                    Text('Current IP-Adresse: ', style: TextStyle(color: Colors.black, fontSize: 13)),
                    SizedBox(height: 6,),
                    Text(IP, style: TextStyle(color: Colors.black, fontSize: 15)),
                    SizedBox(height: 16,),

                    _buildTextFormField("IP Adresse", "000.00.00.0", _IPController, Icons.computer),   // Erstellung des TextFormField 'Emailadresse'

                    SizedBox(height: 16,),


                    ElevatedButton(   // Erstellung eines Buttons
                      onPressed: (){

                        if(_formKey.currentState!.validate()) {
                          print('Alle Eingaben sind richtig.');
                          ipsetting(_IPController.text.toString());
                        }
                        setState(() {
                          IP;
                        });
                        Provider.of<PageNotifier>(context, listen: false).goToMain();


                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color.fromRGBO(23, 156, 125, 1)),

                      ),

                      child: Text("Bestätigen", style: TextStyle(color: Colors.black),), ),




                  ],
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }

}



TextFormField _buildTextFormField(String labelText, String hintText, TextEditingController controller, IconData icon) {
  return TextFormField(    // Eingabefeld hinzufügen
    cursorColor: Colors.black,
    controller: controller,
    // Prüfen ob die Eingaben richtig sind
    validator: (text){
      if(text == null || text.isEmpty){
        return 'Eingabe ist leer!';
      }

      return null;
    },
    style: TextStyle(color: Colors.black),
    decoration: InputDecoration(

        labelText: labelText,
        hintText: hintText,
        icon: Icon(icon),
        filled: true,   // Hintergrund von TextFormField mit Farbe
        fillColor: Colors.white38,

        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 4)),
        hintStyle: TextStyle(color: Colors.black),
        labelStyle: TextStyle(color: Colors.black)

    ),
  );
}

