import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/auth_page.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page.dart';
import 'package:projekt_wzm_iot/pages/faq_page.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:projekt_wzm_iot/pages/pwreset_page.dart';
import 'package:projekt_wzm_iot/pages/setting_page.dart';

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

  void goToDashboard(){
    _currentPage = DashboardPage.pageName;
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

  void goToOtherPage(String name){
    _currentPage = name;
    notifyListeners();
  }
}
