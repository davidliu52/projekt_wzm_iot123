import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:webviewx/webviewx.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';



String IP = '172.26.96.1';
//String thingsBoardApiEndpoint = 'http://'+ IP +':8080';
String thingsBoardApiEndpoint = 'http://iot320.ipk.fraunhofer.de/';
bool isAuthenticated = false;
bool isWebapplication = true;
//bool isAuthenticated = false;
String ID = '';
String PW = '';
String authUser = '';
String UserName = '';
String UserEmail = '';
Color _FraunhoferColor = const Color.fromRGBO(23, 156, 125, 1);

getStringValuesSF() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? token = sharedPreferences.getString('token');
  return token;
}

class MainPage extends Page{
  static const pageName = 'MainPage'; // Definition des Pagename
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>const MainWidget());
  }

}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();

}

class _MainWidgetState extends State<MainWidget> {
  late WebViewXController webviewController;

  late var url;
  var initialUrl = "https://platform.govie.de/share/revision/L7xANyEnnE6Yjr3sv?Fraunhofer-IPK-Smart-Maintenance-Testbed";
  double progress = 0;
  var urlController = TextEditingController();

/*
  @override
  void initState() {
    print('Running on ${getPlatform()}');
    super.initState();
  }
*/

 // bool isAuthenticated = false;
  //String authUser = '';

  void usercheck() async {
    var tbClient = ThingsboardClient(thingsBoardApiEndpoint);
   // isAuthenticated = tbClient.isAuthenticated();
  //  authUser = tbClient.getAuthUser().toString();
    print('isAuthenticated: $isAuthenticated');
    setState(() {
    //  isAuthenticated;
    //  authUser;
    });
  }

  void logout() async {
    var tbClient = ThingsboardClient(thingsBoardApiEndpoint);
    await tbClient.logout();
    print('Erfolgreich ausgeloggt!!!');
    print(tbClient.isAuthenticated());

    isAuthenticated = getStringValuesSF()/*tbClient.isAuthenticated()*/;
    ID = '';
    PW = '';
    authUser = '';

    setState(() {
      isAuthenticated;

    });
  }

  String getPlatform() {
    if (kIsWeb) {
      setState(() {
        isWebapplication = false;
      });

      return 'web';
    } else if (Platform.isAndroid) {
      setState(() {
        isWebapplication = true;
      });

      return 'android';
    } else if (Platform.isIOS) {
      setState(() {
        isWebapplication = true;
      });
      return 'ios';
    } else {
      return 'unsupported';
    }
  }


  @override
  Widget build(BuildContext context) {

    return Center(
      child:Scaffold(
      backgroundColor: Colors.transparent,
        appBar: AppBar(
         title: const Text('Fraunhofer IoT System'),
         centerTitle: true,
         backgroundColor: _FraunhoferColor,
         elevation: 0.0,
         actions: <Widget>[


           isWebapplication? TextButton(
            onPressed: (){
              Provider.of<PageNotifier>(context, listen: false).goToAR();
            },
            child: const Row(
              children: [
                Text('AR-Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0, // Adjust this value as needed
                  ),
                ),
                SizedBox(width: 10.0), // Optional: provides some space between the icon and the text
                Icon(
                    Icons.camera,
                   color: Colors.white,
                  size: 20.0, // Adjust this value as needed
                ),
                SizedBox(width: 8.0), // Optional: provides some space between the icon and the text
              ],
            ),
          ) :Container(),
           isAuthenticated?IconButton(icon: const Icon(Icons.logout), onPressed: (){
          //  openDialog();

            print('logout button wurde gedrückt');
            showDialog(context: context, builder: (context) =>
                AlertDialog(
                  title: const Text('Question'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')
                    ),
                    //logout button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        logout(); // Call the logout function
                      },
                      child: Text('Logout'),
                    )
                  ],
                )
            );

            // setState(() {
            //   logout();
            // });
          }
          ):IconButton(icon: const Icon(Icons.login), onPressed: (){
            print('login button wurde gedrückt');

            // setState(() {
            //   logout();
            // });
            Provider.of<PageNotifier>(context, listen: false).goToAuth();
          }
          ),
        ],
      ),

        drawer: WebViewAware(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: isAuthenticated?Text(UserName):const Text(''),
                    accountEmail: isAuthenticated?Text(UserEmail):const Text(''),
                    onDetailsPressed: null,
                    currentAccountPicture: Image.asset('assets/fraunhofer_image.png'),
                    currentAccountPictureSize: isAuthenticated?const Size.square(70.0):const Size.square(100.0),
                    decoration: BoxDecoration(
                      color: _FraunhoferColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      )
                    ),
                  ),
                  isAuthenticated? ExpansionTile(
                    leading: Icon(Icons.dashboard, color: _FraunhoferColor),
                    title: const Text('Dashboard'),
                    backgroundColor: Colors.white54,
                    children: <Widget>[
                      ListTile(
                        title: const Text('Motor 1'),
                        onTap: () {
                          print('Dashboard-Motor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM1();
                        },
                      ),
                      ListTile(
                        title: const Text('Motor 2'),
                        onTap: () {
                          print('Dashboard-Motor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM2();
                        },
                      ),

                      ListTile(
                        title: const Text('Sensor 1'),
                        onTap: () {
                          print('Dashboard-Sensor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS1();
                        },
                      ),
                      ListTile(
                        title: const Text('Sensor 2'),
                        onTap: () {
                          print('Dashboard-Sensor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS2();
                        },
                      ),
                    ],
                  ): const Center(),

                  ListTile(
                    leading: Icon(Icons.settings, color: _FraunhoferColor),
                    title: const Text('Einstellung'),
                    onTap: (){
                      print('Einstellung wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToSetting();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.question_answer, color: _FraunhoferColor),
                    title: const Text('FAQ'),
                    onTap: (){
                      print('FAQ wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToFAQ();
                    },
                  ),
                ],
            ),
          ),
        ),


        body: SafeArea(
        child: Column(
          children: [

            Expanded(
                child: Container(

                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return WebViewX(
                      width: constraints.maxWidth,
                      height:  constraints.maxHeight,
                      initialContent: initialUrl,
                      initialSourceType: SourceType.url,
                      onWebViewCreated: (controller) => webviewController = controller,
                      );
                    }
                  ),
                )
                  ),
            ],
         )
       ),
    ),

/*
      menu: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [




            Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: isAuthenticated?Text(UserName):const Text(''),
                  accountEmail: isAuthenticated?Text(UserEmail):const Text(''),
                  onDetailsPressed: null,
                  currentAccountPicture: Image.asset('assets/fraunhofer_image.png'),
                  currentAccountPictureSize: isAuthenticated?const Size.square(70.0):const Size.square(100.0),
                  decoration: BoxDecoration(

                      color: _FraunhoferColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      )
                  ),
                ),
                isAuthenticated?Container(
                  color: Colors.white,

                  child: ExpansionTile(
                    leading: Icon(Icons.dashboard, color: _FraunhoferColor),
                    title: const Text('Dashboard'),
                    backgroundColor: Colors.white54,
                    children: <Widget>[
                      ListTile(
                        title: const Text('Motor 1'),
                        onTap: () {
                          print('Dashboard-Motor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM1();
                        },
                      ),
                      ListTile(
                        title: const Text('Motor 2'),
                        onTap: () {
                          print('Dashboard-Motor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM2();
                        },
                      ),
                      ListTile(
                        title: const Text('Sensor 1'),
                        onTap: () {
                          print('Dashboard-Sensor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS1();
                        },
                      ),
                      ListTile(
                        title: const Text('Sensor 2'),
                        onTap: () {
                          print('Dashboard-Sensor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS2();
                        },
                      ),
                    ],
                  ),
                ) : const Center(),

                Container(
                  height: 1000,
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  child: Column(
                    children: [

                      ListTile(
                        leading: Icon(Icons.settings, color: _FraunhoferColor),
                        title: const Text('Einstellung'),
                        onTap: (){
                          print('Einstellung wurde gedrückt');
                          Provider.of<PageNotifier>(context, listen: false).goToSetting();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.question_answer, color: _FraunhoferColor),
                        title: const Text('FAQ'),
                        onTap: (){
                          print('FAQ wurde gedrückt');
                          Provider.of<PageNotifier>(context, listen: false).goToFAQ();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: _FraunhoferColor),
                        title: const Text('Logout'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Question'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      logout();
                                    },
                                    child: Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    // Call the logout function here.
                                  },
                                  child: Text('Logout'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              ],
            )
          ],
        ),
      ),

*/




/*

      child:Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text('Fraunhofer IoT System'),
          centerTitle: true,
          backgroundColor: _FraunhoferColor,
          elevation: 0.0,
          leading: IconButton(
             icon: Icon(Icons.menu),
            onPressed: () {
               final _state = stateMenu.currentState;
               _state?.openSideMenu();

            },
          ),
          actions: <Widget>[
            isAuthenticated?IconButton(icon: const Icon(Icons.logout), onPressed: (){

              print('logout button wurde gedrückt');

              showDialog(context: context, builder: (context) =>
                  AlertDialog(
                    title: Text('Question'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel')
                      ),
                      //logout button
                      TextButton(
                      onPressed: () {
                           Navigator.of(context).pop(); // Close the dialog
                           logout(); // Call the logout function
                             },
                           child: Text('Logout'),
                      )
                    ],
                  )
              );

              // setState(() {
              //   logout();
              // });
            }
            ):IconButton(icon: const Icon(Icons.login), onPressed: (){



              print('login button wurde gedrückt');

              // setState(() {
              //   logout();
              // });
              Provider.of<PageNotifier>(context, listen: false).goToAuth();

            }
            ),
          ],
        ),


        body: SafeArea(
            child: Form(
              child:   Column(
                children: [
                  Expanded(
                    // height: 200, // specify height
                    // width: double.infinity,
                      child:  WebView( controller: webViewController,)
                    //Image.network('https://images.unsplash.com/photo-1483232539664-d89822fb5d3e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=764&q=80'),
                    //InAppWebView(initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)))
                    //  initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                  ),

                ],
              ),
            )
        ),






/*
        drawer: SafeArea(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
                children: <Widget>[

                  UserAccountsDrawerHeader(
                    accountName: isAuthenticated?Text(UserName):const Text(''),
                    accountEmail: isAuthenticated?Text(UserEmail):const Text(''),
                    onDetailsPressed: null,
                    currentAccountPicture: Image.asset('assets/fraunhofer_image.png'),
                    currentAccountPictureSize: isAuthenticated?const Size.square(70.0):const Size.square(100.0),
                    decoration: BoxDecoration(
                      color: _FraunhoferColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      )
                    ),
                  ),
                  isAuthenticated?ExpansionTile(
                    leading: Icon(Icons.dashboard, color: _FraunhoferColor),
                    title: const Text('Dashboard'),
                    backgroundColor: Colors.white54,
                    children: <Widget>[
                      ListTile(
                        title: const Text('Motor 1'),
                        onTap: () {
                          print('Dashboard-Motor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM1();
                        },
                      ),
                      ListTile(
                        title: const Text('Motor 2'),
                        onTap: () {
                          print('Dashboard-Motor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardM2();
                        },
                      ),
                      ListTile(
                        title: const Text('Sensor 1'),
                        onTap: () {
                          print('Dashboard-Sensor 1 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS1();
                        },
                      ),
                      ListTile(
                        title: const Text('Sensor 2'),
                        onTap: () {
                          print('Dashboard-Sensor 2 wurde gedrückt.');
                          Provider.of<PageNotifier>(context, listen: false).goToDashboardS2();
                        },
                      ),
                    ],
                  ) : const Center(),
                  ListTile(
                    leading: Icon(Icons.settings, color: _FraunhoferColor),
                    title: const Text('Einstellung'),
                    onTap: (){
                      print('Einstellung wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToSetting();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.question_answer, color: _FraunhoferColor),
                    title: const Text('FAQ'),
                    onTap: (){
                      print('FAQ wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToFAQ();
                    },
                  ),
                ],
            ),
          ),
        ),

*/

      ),
      */
      );
  }



}

