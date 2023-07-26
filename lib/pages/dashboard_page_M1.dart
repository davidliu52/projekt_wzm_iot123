// Importieren benötigter Packages
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:projekt_wzm_iot/widgets/dashboard_grid_M1.dart';
import 'package:provider/provider.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';



class DashboardM1Page extends Page{
  static const pageName = 'DashboardM1Page'; // Definition des Pagename
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>const DashboardM1Widget());
  }

}

class DashboardM1Widget extends StatefulWidget {
  const DashboardM1Widget({Key? key}) : super(key: key);

  @override
  State<DashboardM1Widget> createState() => _DashboardM1WidgetState();
}

class _DashboardM1WidgetState extends State<DashboardM1Widget> {


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Fraunhofer IoT System'),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(23, 156, 125, 1),
              elevation: 0.0,
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.home), onPressed: (){
                  print('home button wurde gedrückt');
                  Provider.of<PageNotifier>(context, listen: false).goToMain();
                }
                ),
              ],
            ),


            body: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                _buildHeader(),

               const SliverPadding(
                padding: EdgeInsets.all(20.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Motor 1 Daten',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),
                ),
              ),

                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: DashboardM1Grid(),// It will turn to the dashboard_grid_M1.dart. this file is responsible for the show of the all chart of Motor1
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }

}

SliverPadding _buildHeader() {
  return const SliverPadding(

    padding: EdgeInsets.all(20.0),
    sliver: SliverToBoxAdapter(
      child: Text(
        'Dashboard Motor 1',
        style: TextStyle(
          color: Color.fromRGBO(23, 156, 125, 1),
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}


