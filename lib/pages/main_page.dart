// Importieren benötigter Packages
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/auth_page.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


// TODO: entsprechende url eingeben
String IP = '172.26.96.1';
//String thingsBoardApiEndpoint = 'http://'+ IP +':8080';
String thingsBoardApiEndpoint = 'iot320.ipk.faunhofer.de';
bool isAuthenticated = false;
String ID = '';
String PW = '';
String authUser = '';
String UserName = '';
String UserEmail = '';

//getStringValuesSF() async {
//  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//  String? token = sharedPreferences.getString('token');
//  return token;
//}

class MainPage extends Page{

  static final pageName = 'MainPage'; // Definition des Pagename


  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>MainWidget());
  }

}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();

}

class _MainWidgetState extends State<MainWidget> {
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  //var initialUrl = "https://platform.govie.de/share/revision/4Nje4JLeLouXBLD7Z?Fraunhofer-IPK-Smart-Maintenance-Testbed-English";
  var initialUrl = "https://platform.govie.de/share/revision/L7xANyEnnE6Yjr3sv?Fraunhofer-IPK-Smart-Maintenance-Testbed";
  double progress = 0;
  var urlController = TextEditingController();


  //bool isAuthenticated = false;
  //String authUser = '';

  void usercheck() async {
    var tbClient = ThingsboardClient(thingsBoardApiEndpoint);
    //isAuthenticated = tbClient.isAuthenticated();
    //authUser = tbClient.getAuthUser().toString();
    print('isAuthenticated: $isAuthenticated');
    setState(() {
      //isAuthenticated;
      //authUser;
    });
  }





  void logout() async {
    var tbClient = ThingsboardClient(thingsBoardApiEndpoint);

    await tbClient.logout();
    print('Erfolgreich ausgeloggt!!!');
    print(tbClient.isAuthenticated());

    isAuthenticated = tbClient.isAuthenticated();
    ID = '';
    PW = '';
    authUser = '';


    setState(() {
      isAuthenticated;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Fraunhofer IoT System'),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(23, 156, 125, 1),
              elevation: 0.0,
              actions: <Widget>[

                isAuthenticated?IconButton(icon: Icon(Icons.logout), onPressed: (){
                  print('logout button wurde gedrückt');
                  logout();
                  // setState(() {
                  //   logout();
                  // });


                }
                ):IconButton(icon: Icon(Icons.login), onPressed: (){
                  print('login button wurde gedrückt');

                  // setState(() {
                  //   logout();
                  // });
                  Provider.of<PageNotifier>(context, listen: false).goToAuth();

                }
                ),
              ],



            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      //currentAccountPicture:
                      //CircleAvatar(
                        //backgroundImage: isAuthenticated?AssetImage('assets/person_icon.png'):null,
                        //backgroundColor: Colors.white,
                      //),
                      accountName: isAuthenticated?Text(UserName):Text(''),
                      accountEmail: isAuthenticated?Text(UserEmail):Text(''),
                      onDetailsPressed: (){
                        print('arrow wurde gedrückt');
                        usercheck();
                        Text(IP);
                      },
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(23, 156, 125, 1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        )
                      ),
                    ),


                    isAuthenticated?ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                      onTap: (){
                        print('Dashboard wurde gedrückt');
                        Provider.of<PageNotifier>(context, listen: false).goToDashboard();

                      },
                    ) : Center(),

                    //isAuthenticated?ListTile(
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Einstellung'),
                      onTap: (){
                        print('Einstellung wurde gedrückt');
                        Provider.of<PageNotifier>(context, listen: false).goToSetting();
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.question_answer),
                      title: Text('FAQ'),
                      onTap: (){
                        print('FAQ wurde gedrückt');
                        Provider.of<PageNotifier>(context, listen: false).goToFAQ();


                      },
                    ),
                  ],
              ),
            ),

            body: SafeArea(
                child: Form(
                  child:   Column(
                    children: [
                      Expanded(child: InAppWebView(

                        initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                      ))
                    ,


                  // child: ListView( // Listview erstellen
                  //   reverse: false,
                  //   // Alle Komponenten von unten anzeigen
                  //   // ListView Ende einstellen. fromLRTB (von links, rechts, oben und unten) MediaQuery.of(context).size.width: Displaygröße
                  //   padding: EdgeInsets.fromLTRB((MediaQuery.of(context).size.width - 320)/2, 30, (MediaQuery.of(context).size.width - 320)/2, 30),
                  //   children: [
                  //     SizedBox(height: 16,),
                  //     //   Leere Kiste hinzufügen (für die Positionierung)
                  //     CircleAvatar(
                  //         backgroundColor: Colors.transparent,
                  //         radius: 36,
                  //         child: Image.asset('assets/fraunhofer_logo.png')
                  //     ),
                  //     SizedBox(height: 16,),
                  //     //Text('Hier ist Main Screen'),




                      // Column(
                      //   children: [
                      //     Expanded(child: InAppWebView(
                      //
                      //       initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                      //     ))
                      //   ],
                      // ),




                    ],
                  ),
                )
            ),

          ),

        ),
    );

  }

}