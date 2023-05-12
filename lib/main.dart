import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_M1.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_M2.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S1.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S2.dart';
import 'package:projekt_wzm_iot/pages/faq_page.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:projekt_wzm_iot/pages/pwreset_page.dart';
import 'package:projekt_wzm_iot/pages/setting_page.dart';
import 'package:provider/provider.dart';
import 'package:projekt_wzm_iot/provider/page_notifier.dart';
import 'package:projekt_wzm_iot/pages/auth_page.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_)=>PageNotifier())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,  // debug ausblenden
        title: 'Fraunhofer IoT System',
        theme: ThemeData(

          //primarySwatch: Colors.red,
          primarySwatch: Colors.green,
        ),
        home: Consumer<PageNotifier>(
          builder: (context, pageNotifier, child){
            return Navigator(
              pages: [
                MaterialPage(
                  key: ValueKey(MainPage.pageName),
                  child: MainWidget()


                ),
                if(pageNotifier.currentPage == MainPage.pageName) MainPage(), // wenn pageName MainPage ist, wird MainPage ausgegeben.
                if(pageNotifier.currentPage == AuthPage.pageName) AuthPage(), // wenn pageName AuthPage ist, wird AuthPage ausgegeben.
                if(pageNotifier.currentPage == DashboardM1Page.pageName) DashboardM1Page(), // wenn pageName DashboardPage ist, wird DashboardPage ausgegeben.
                if(pageNotifier.currentPage == DashboardM2Page.pageName) DashboardM2Page(), // wenn pageName DashboardPage ist, wird DashboardPage ausgegeben.
                if(pageNotifier.currentPage == DashboardS1Page.pageName) DashboardS1Page(), // wenn pageName DashboardPage ist, wird DashboardPage ausgegeben.
                if(pageNotifier.currentPage == DashboardS2Page.pageName) DashboardS2Page(), // wenn pageName DashboardPage ist, wird DashboardPage ausgegeben.
                if(pageNotifier.currentPage == PWresetPage.pageName) PWresetPage(), // wenn pageName PWresetPage ist, wird PWresetPage ausgegeben.
                if(pageNotifier.currentPage == SettingPage.pageName) SettingPage(), // wenn pageName SettingPage ist, wird SettingPage ausgegeben.
                if(pageNotifier.currentPage == FAQPage.pageName) FAQPage(), // wenn pageName FAQPage ist, wird FAQPage ausgegeben.

                //if(pageNotifier.currentPage == AuthPage.pageName) AuthPage(), // wenn pageName AuthPage ist, wird AuthPage ausgegeben.


              ],
              onPopPage: (route, result){
                if(!route.didPop(result)) {
                  return false;
                }
                return true;
              },
            );
          },
        ) ,
      ),
    );
  }
}







