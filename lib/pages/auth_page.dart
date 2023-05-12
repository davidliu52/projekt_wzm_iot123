import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';


class AuthPage extends Page{

  static final pageName = 'AuthPage';

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>AuthWidget());
  }
}

class AuthWidget extends StatefulWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //bool isLoading = false;

  Future<void> _onLoading() async {
    var dialogFuture = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await Future.delayed(Duration(seconds: 1));
    await dialogFuture;
    Navigator.pop(context);
  }


  // Login Funktion mit thingsboardclient (Eingabe: email und Password)
  void login(String email, String password) async {
    try {
      var tbClient = ThingsboardClient(thingsBoardApiEndpoint);

      await
      tbClient.login(LoginRequest(email, password));
      final accessToken = tbClient.login(LoginRequest(email, password));

      //globals.token = true; (In Startseite muss gelöscht werden)

      print('isAuthenticated=${tbClient.isAuthenticated()}');
      ID = email;
      PW = password;
      isAuthenticated = tbClient.isAuthenticated();
      //isAuthenticated = true;
      authUser = tbClient.getAuthUser().toString();
      String firstName = tbClient.getAuthUser()!.firstName.toString();
      String lastName = tbClient.getAuthUser()!.lastName.toString();
      UserName = firstName + ' ' + lastName;
      UserEmail = tbClient.getAuthUser()!.sub.toString();
      print(tbClient.getAuthUser());
      if(tbClient.isAuthenticated()==true){
        setState(() {
          isAuthenticated;
          ID;
          PW;
          authUser;
          UserName;
          UserEmail;
        });
        //_onLoading();
        Provider.of<PageNotifier>(context, listen: false).goToMain();

      } else {
      }

      //print('authUser: ${tbClient.getAuthUser()}');

      var currentUserDetails = await tbClient.getUserService().getUser();
      print('currentUserDetails: $currentUserDetails');

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isAuthenticated', tbClient.isAuthenticated().toString());
      sharedPreferences.setString('access_token', accessToken.toString());



    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }


  // void login(String email, String password) async{
  //   final storage = new FlutterSecureStorage();
  //   var Body = {"username": email,
  //     "password": password};
  //   try{
  //
  //     Response response = await post(
  //       //TODO: entsprechende url eingeben
  //       Uri.parse('http://172.19.48.1:8080/api/auth/login'),
  //       body: json.encode(Body)
  //         );
  //         var jsonData = null;
  //           SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //
  //         if(response.statusCode == 200){
  //           jsonData = json.decode(response.body);
  //           String token = jsonData['token'];
  //           var val = jsonEncode('$token');
  //
  //           final userData = json.encode({
  //             'token': token,
  //             'user': email
  //           });
  //           // sharedPreferences.setString('userData', userData);
  //             setState(() {
  //               sharedPreferences.setString("token", jsonData['token']);
  //             });
  //           await storage.write(key: "token", value: jsonData['token']);
  //
  //           print(jsonData['token']);
  //           print('Erfolgreich eingeloggt!');
  //           Provider.of<PageNotifier>(context, listen: false).goToMain();
  //
  //
  //         }else{
  //           print(response.body);
  //
  //           //Provider.of<PageNotifier>(context, listen: false).goToMain();
  //
  //         }
  //       }catch(e){
  //         print(e.toString());
  //       }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
          child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
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
                    SizedBox(height: 120,),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 36,
                      child: Image.asset('assets/fraunhofer_logo.png'),
                    ),
                    SizedBox(height: 16,),


                    _buildTextFormField("Emailadresse", "example@example.com", _emailController, Icons.email, "false"),   // Erstellung des TextFormField 'Emailadresse'
                    SizedBox(height: 16,),
                    _buildTextFormField("Passwort", "", _passwordController, Icons.lock, "true"),
                    SizedBox(height: 16,),
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap

                        ) ,
                        // ButtonStyle(
                        //   backgroundColor: MaterialStateProperty.all(Colors.white70),
                        //
                        // ),
                        child: Text('Passwort vergessen?',
                          style: TextStyle(
                              fontSize: 18,
                              //fontWeight: FontWeight.w600,
                              color: Colors.black
                          ),),
                        onPressed: (){
                          Provider.of<PageNotifier>(context, listen: false).goToPWreset();

                        },
                      ),
                    ),
                    SizedBox(height: 10,),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(   // Erstellung eines Buttons
                        onPressed: (){
                          // login(_emailController.text.toString(), _passwordController.text.toString());
                          //login('tenant@thingsboard.org', 'tenant');

                          if(_formKey.currentState!.validate()) {

                            login(_emailController.text.toString(), _passwordController.text.toString());
                          }

                          //Provider.of<PageNotifier>(context, listen: false).goToMain();


                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color.fromRGBO(23, 156, 125, 1)),

                        ),

                        child: Text("Einloggen", style: TextStyle(
                            fontSize: 18,
                            color: Colors.black),

                        ), ),
                    ),




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



TextFormField _buildTextFormField(String labelText, String hintText, TextEditingController controller, IconData icon, String obscure) {
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
    obscureText: obscure=="true"?true:false,

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


