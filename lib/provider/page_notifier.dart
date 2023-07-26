import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/auth_page.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_M1.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_M2.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S1.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S2.dart';
import 'package:projekt_wzm_iot/pages/faq_page.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:projekt_wzm_iot/pages/pwreset_page.dart';
import 'package:projekt_wzm_iot/pages/setting_page.dart';
import 'package:projekt_wzm_iot/pages/AR-Dashboard_page.dart';

class PageNotifier extends ChangeNotifier{
  String _currentPage = MainPage.pageName;

  String get currentPage=>_currentPage;

  void goToAuth(){
    _currentPage = AuthPage.pageName;
    notifyListeners();
  }

  void goToMain(){
    _currentPage = MainPage.pageName;
    notifyListeners();
  }

  void goToDashboardM1(){
    _currentPage = DashboardM1Page.pageName;
    notifyListeners();
  }

  void goToDashboardM2(){
    _currentPage = DashboardM2Page.pageName;
    notifyListeners();
  }

  void goToDashboardS1(){
    _currentPage = DashboardS1Page.pageName;
    notifyListeners();
  }

  void goToDashboardS2(){
    _currentPage = DashboardS2Page.pageName;
    notifyListeners();
  }

  void goToPWreset(){
    _currentPage = PWresetPage.pageName;
    notifyListeners();
  }

  void goToSetting(){
    _currentPage = SettingPage.pageName;
    notifyListeners();
  }

  void goToFAQ(){
    _currentPage = FAQPage.pageName;
    notifyListeners();
  }

  void goToAR(){
    _currentPage =ARcode.pageName;
    notifyListeners();
  }
}
