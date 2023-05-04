// Importieren benötigter Packages
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';



class PWresetPage extends Page{

  static final pageName = 'PWresetPage'; // Definition des Pagename

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>PWresetWidget());
  }

}

class PWresetWidget extends StatefulWidget {
  const PWresetWidget({Key? key}) : super(key: key);

  @override
  State<PWresetWidget> createState() => _PWresetWidgetState();
}

class _PWresetWidgetState extends State<PWresetWidget> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();

  void pwreset(String email) async{
    var Body = {"email": email};
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
        print(email);
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
                title: Text('Password reset'),
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

                      SizedBox(height: 16,),

                      _buildTextFormField("Emailadresse", "example@example.com", _emailController, Icons.email),   // Erstellung des TextFormField 'Emailadresse'

                      SizedBox(height: 16,),


                      ElevatedButton(   // Erstellung eines Buttons
                        onPressed: (){

                          if(_formKey.currentState!.validate()) {
                            print('Alle Eingaben sind richtig.');
                            pwreset(_emailController.text.toString());
                          }

                          //Provider.of<PageNotifier>(context, listen: false).goToMain();


                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color.fromRGBO(23, 156, 125, 1)),

                        ),

                        child: Text("Email senden", style: TextStyle(color: Colors.black),), ),




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

