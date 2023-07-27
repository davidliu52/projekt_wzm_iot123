// Importieren benötigter Packages
import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:provider/provider.dart';
import 'package:projekt_wzm_iot/widgets/dashboard_grid_M2.dart';


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

                    IconButton(icon: Icon(Icons.home), onPressed: (){
                      print('home button wurde gedrückt');
                      Provider.of<PageNotifier>(context, listen: false).goToMain();

                    }
                    ),
                  ],
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
                  child: Text(
                    'Motor 2 Daten',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: DashboardM2Grid(),
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
        'Dashboard Motor 2',
        style: TextStyle(
          color: Color.fromRGBO(23, 156, 125, 1),
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}