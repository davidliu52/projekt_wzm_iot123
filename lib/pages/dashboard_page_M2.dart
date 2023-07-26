// Importieren benötigter Packages
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:projekt_wzm_iot/widgets/dashboard_grid_M2.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';


class DashboardM2Page extends Page{

  static final pageName = 'DashboardM2Page'; // Definition des Pagename

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>DashboardM2Widget());
  }

}

class DashboardM2Widget extends StatefulWidget {
  const DashboardM2Widget({Key? key}) : super(key: key);

  @override
  State<DashboardM2Widget> createState() => _DashboardM2WidgetState();
}

class _DashboardM2WidgetState extends State<DashboardM2Widget> {


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Fraunhofer IoT System'),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(23, 156, 125, 1),
              elevation: 0.0,
              actions: <Widget>[
                Row(
                  children: [
          //           IconButton(icon: Icon(Icons.logout), onPressed: (){
          //   print('logout button is clicked');
          //   Provider.of<PageNotifier>(context, listen: false).goToAuth();
          //
          // }
          // ),
                    IconButton(icon: Icon(Icons.home), onPressed: (){
                      print('home button wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToMain();

                    }
                    ),
                  ],
                ),

              ],



            ),
            // drawer: Drawer(
            //   child: ListView(
            //     padding: EdgeInsets.zero,
            //     children: <Widget>[
            //       UserAccountsDrawerHeader(
            //         // currentAccountPicture: CircleAvatar(
            //         //   backgroundImage: AssetImage('assets/person_icon.png'),
            //         //   backgroundColor: Colors.white,
            //         //
            //         // ),
            //         accountName: Text(UserName),
            //         accountEmail: Text(UserEmail),
            //         // onDetailsPressed: (){
            //         //   print('arrow wurde gedrückt');
            //         // },
            //         decoration: BoxDecoration(
            //             color: Color.fromRGBO(23, 156, 125, 1),
            //             borderRadius: BorderRadius.only(
            //               bottomLeft: Radius.circular(8.0),
            //               bottomRight: Radius.circular(8.0),
            //             )
            //         ),
            //       ),

                  //
                  // ListTile(
                  //   leading: Icon(Icons.home),
                  //   title: Text('Main'),
                  //   onTap: (){
                  //     print('Main wurde gedrückt');
                  //     Provider.of<PageNotifier>(context, listen: false).goToMain();
                  //
                  //   },
                  // ),
                  //
                  // ListTile(
                  //   leading: Icon(Icons.settings),
                  //   title: Text('Einstellung'),
                  //   onTap: (){
                  //     print('setting wurde gedrückt');
                  //     Provider.of<PageNotifier>(context, listen: false).goToSetting();
                  //   },
                  // ),
                  // ListTile(
                  //   leading: Icon(Icons.question_answer),
                  //   title: Text('Q&A'),
                  //   onTap: (){
                  //     print('Q&A wurde gedrückt');
                  //     Provider.of<PageNotifier>(context, listen: false).goToFAQ();
                  //   },
                  // ),
            //     ],
            //   ),
            // ),

            body: CustomScrollView(
              physics: ClampingScrollPhysics(),
              slivers: <Widget>[
                _buildHeader(),
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Motor 2 Daten',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: DashboardM2Grid(),
                  ),
                ),



              ],
            )


            // SafeArea(
            //     child: Form(
            //       child: ListView( // Listview erstellen
            //         reverse: false,
            //         // Alle Komponenten von unten anzeigen
            //         // ListView Ende einstellen. fromLRTB (von links, rechts, oben und unten) MediaQuery.of(context).size.width: Displaygröße
            //         padding: EdgeInsets.fromLTRB((MediaQuery.of(context).size.width - 320)/2, 30, (MediaQuery.of(context).size.width - 320)/2, 30),
            //         children: [
            //           SizedBox(height: 16,),
            //           //   Leere Kiste hinzufügen (für die Positionierung)
            //
            //           Text('Hier ist Dashboard Page'),
            //
            //
            //
            //
            //         ],
            //       ),
            //     ),
            //
            // ),

          ),
        ),
      ),
    );
  }

}

SliverPadding _buildHeader() {
  return SliverPadding(

    padding: const EdgeInsets.all(20.0),
    sliver: SliverToBoxAdapter(
      child: Text(
        'Dashboard Motor 2',
        style: const TextStyle(
          color: Color.fromRGBO(23, 156, 125, 1),
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}