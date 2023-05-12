import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:projekt_wzm_iot/pages/auth_page.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kdgaugeview/kdgaugeview.dart';


class DashboardGrid extends StatefulWidget {

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {

  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  var tbClient = ThingsboardClient(thingsBoardApiEndpoint);
  bool _emergency_switch = false;
  bool _is_homing = false;
  bool _is_testing = false;
  int _direction = 1;
  double _pwm_frequency = 0;
  double _speed = 0;
  double _time = 0;
  String _currentPage = DashboardPage.pageName;

  String get currentPage=>_currentPage;


  Timer? _timer;

  _DashboardGridState() {
    login();


    if(_currentPage == DashboardPage.pageName) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (_timer) {
        dateneinlesen();
      });
    }
  }


  // Thingsboard login
  void login() async{
    try{
      await tbClient.login(LoginRequest(ID, PW));
      print('isAuthenticated=${tbClient.isAuthenticated()}');

    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }

  void dateneinlesen() async{
    try{
      // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      // final accessToken = sharedPreferences.getString('access_token');
      // final tbClient = ThingsboardClient(thingsBoardApiEndpoint);


      if(tbClient.isAuthenticated() == true) {
        var deviceName = 'Motor 1';
        var pageLink = PageLink(10);
        PageData<DeviceInfo> devices;
        devices =
        await tbClient.getDeviceService().getTenantDeviceInfos(pageLink);
        //Link mit Token eingeben
        // print('devices: $devices');

        var device = Device(deviceName, 'default');

        var entityFilter = EntityNameFilter(
            entityType: EntityType.DEVICE, entityNameFilter: deviceName);

        var deviceFields = <EntityKey>[
          EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
          EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
          EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
        ];

        // !!!!!!!!!!!!!!timeseries start!!!!!!!!!!!!!!!!
        var deviceTelemetry = <EntityKey>[
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'direction'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'emergency_switch'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'is_homing'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'is_testing'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'pwm_frequency'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'speed'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'time'),
        ];

        var devicesQuery = EntityDataQuery(
            entityFilter: entityFilter,
            entityFields: deviceFields,
            latestValues: deviceTelemetry,
            pageLink: EntityDataPageLink(
                pageSize: 10,
                sortOrder: EntityDataSortOrder(
                    key: EntityKey(
                        type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
                    direction: EntityDataSortOrderDirection.DESC)));


        var currentTime = DateTime
            .now()
            .millisecondsSinceEpoch;
        var timeWindow = Duration(hours: 1).inMilliseconds;

        var tsCmd = TimeSeriesCmd(
            keys: ([
              'direction',
              'emergency_switch',
              'is_homing',
              'is_testing',
              'pwm_frequency',
              'speed',
              'time'
            ]),
            startTs: currentTime - timeWindow,
            timeWindow: timeWindow);

        var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

        var telemetryService = tbClient.getTelemetryService();

        var subscription = TelemetrySubscriber(telemetryService, [cmd]);

        subscription.entityDataStream.listen((entityDataUpdate) {
          var whole_data = entityDataUpdate.toString();


          //print(whole_data);

          // direction ANFANG--------------------------------------------------------
          int Anfang_dir = 0;
          int len_wd = whole_data.length;
          for (var i = 0; i < len_wd - 9; i++) {
            if (whole_data.substring(i, i + 9) == 'direction') {
              break;
            }
            Anfang_dir++;
          }

          int Ende_dir = Anfang_dir;

          for (var i = Anfang_dir; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_dir++;
          }

          for (var i = Anfang_dir; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_dir++;
          }


          _direction = int.parse(whole_data.substring(Anfang_dir, Ende_dir));
          // direction = direction.replaceAll(new RegExp(r'[^0-9]'),'');
          // direction ANFANG--------------------------------------------------------


          // is_homing ANFANG--------------------------------------------------------
          int Anfang_ih = 0;
          for (var i = 0; i < len_wd - 9; i++) {
            if (whole_data.substring(i, i + 9) == 'is_homing') {
              break;
            }
            Anfang_ih++;
          }

          int Ende_ih = Anfang_ih;

          for (var i = Anfang_ih; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_ih++;
          }

          for (var i = Anfang_ih; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_ih++;
          }

          var is_homing = whole_data.substring(Anfang_ih, Ende_ih);
          if (is_homing == 'true') {
            _is_homing = true;
          } else {
            _is_homing = false;
          }

          // is_homing ENDE--------------------------------------------------------


          // is_testing ANFANG--------------------------------------------------------
          int Anfang_it = 0;
          for (var i = 0; i < len_wd - 10; i++) {
            if (whole_data.substring(i, i + 10) == 'is_testing') {
              break;
            }
            Anfang_it++;
          }

          int Ende_it = Anfang_it;

          for (var i = Anfang_it; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_it++;
          }

          for (var i = Anfang_it; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_it++;
          }

          var is_testing = whole_data.substring(Anfang_it, Ende_it);
          if (is_testing == 'true') {
            _is_testing = true;
          } else {
            _is_testing = false;
          }


          // is_testing ENDE--------------------------------------------------------

          // emergency_switch ANFANG--------------------------------------------------------
          int Anfang_es = 0;
          for (var i = 0; i < len_wd - 16; i++) {
            if (whole_data.substring(i, i + 16) == 'emergency_switch') {
              break;
            }
            Anfang_es++;
          }

          int Ende_es = Anfang_es;

          for (var i = Anfang_es; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_es++;
          }

          for (var i = Anfang_es; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_es++;
          }

          var emergency_switch = whole_data.substring(Anfang_es, Ende_es);
          if (emergency_switch == 'true') {
            _emergency_switch = true;
          } else {
            _emergency_switch = false;
          }

          // emergency_switch ENDE--------------------------------------------------------


          // pwm_frequency ANFANG--------------------------------------------------------
          int Anfang_pf = 0;
          for (var i = 0; i < len_wd - 13; i++) {
            if (whole_data.substring(i, i + 13) == 'pwm_frequency') {
              break;
            }
            Anfang_pf++;
          }

          int Ende_pf = Anfang_pf;

          for (var i = Anfang_pf; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_pf++;
          }

          for (var i = Anfang_pf; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_pf++;
          }

          _pwm_frequency =
              double.parse(whole_data.substring(Anfang_pf, Ende_pf));

          // pwm_frequency ENDE--------------------------------------------------------

          // speed ANFANG--------------------------------------------------------
          int Anfang_s = 0;
          for (var i = 0; i < len_wd - 5; i++) {
            if (whole_data.substring(i, i + 5) == 'speed') {
              break;
            }
            Anfang_s++;
          }

          int Ende_s = Anfang_s;

          for (var i = Anfang_s; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_s++;
          }

          for (var i = Anfang_s; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_s++;
          }

          _speed = double.parse(whole_data.substring(Anfang_s, Ende_s));
          // speed ENDE--------------------------------------------------------


          // time ANFANG--------------------------------------------------------
          int Anfang_t = 0;
          for (var i = 0; i < len_wd - 4; i++) {
            if (whole_data.substring(i, i + 4) == 'time') {
              break;
            }
            Anfang_t++;
          }

          int Ende_t = Anfang_t;

          for (var i = Anfang_t; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_t++;
          }

          for (var i = Anfang_t; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_t++;
          }

          _time = double.parse(whole_data.substring(Anfang_t, Ende_t));
          // time ENDE--------------------------------------------------------



          setState(() {
            _is_homing;
            _direction;
            _is_testing;
            _emergency_switch;
            _pwm_frequency;
            _speed;
            _time;
          });
        });


        subscription.subscribe();

        await Future.delayed(Duration(seconds: 1));
        // !!!!!!!!!!!!!!!!!!!!!!!!!timeseries end!!!!!!!!!!!!!!!!!!!!!!
      }
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }



















  void dateneinlesen2() async{
    try{

      var foundDevice = await tbClient.getDeviceService().getDeviceInfo('25c0a450-6332-11ed-8de5-891fb00a7c64');
      var keys = await tbClient.getTelemetryService();
      print('keys: $keys');
      var attributes = await tbClient.getAttributeService().getAttributesByScope(
          foundDevice!.id!,
          AttributeScope.SHARED_SCOPE.toShortString(),
          ['is_homing']
      );
      print('Found device attributes: $attributes');

    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }


  void dateneinlesen3() async{
    try{

      var deviceName = 'My New Device';

      var pageLink = PageLink(10);
      PageData<DeviceInfo> devices;
      devices = await tbClient.getDeviceService().getTenantDeviceInfos(pageLink);
      //Link mit Token eingeben
      // print('devices: $devices');

      var device = Device(deviceName, 'default');

      var entityFilter = EntityNameFilter(
          entityType: EntityType.DEVICE, entityNameFilter: deviceName);

      var deviceFields = <EntityKey>[
        EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
        EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
        EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
      ];

      // !!!!!!!!!!!!!!timeseries start!!!!!!!!!!!!!!!!
      var deviceTelemetry = <EntityKey>[
        EntityKey(type: EntityKeyType.ATTRIBUTE, key: 'direction'),

      ];

      var devicesQuery = EntityDataQuery(
          entityFilter: entityFilter,
          entityFields: deviceFields,
          latestValues: deviceTelemetry,
          pageLink: EntityDataPageLink(
              pageSize: 10,
              sortOrder: EntityDataSortOrder(
                  key: EntityKey(
                      type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
                  direction: EntityDataSortOrderDirection.DESC)));


      // var tsCmd = TimeSeriesCmd(
      //     keys: (['direction', 'emergency_switch', 'is_homing', 'is_testing', 'pwm_frequency', 'speed']),
      //     startTs: currentTime - timeWindow,
      //     timeWindow: timeWindow);

      var cmd = EntityDataCmd(query: devicesQuery);

      var telemetryService = tbClient.getTelemetryService();

      var subscription = TelemetrySubscriber(telemetryService, [cmd]);
      print(subscription);
      subscription.entityDataStream.listen((entityDataUpdate) {


        //----------------------Suche nach Werte-------------------
        print('_------------------Anfang--------------------');
        var whole_data = entityDataUpdate.toString();

        print(whole_data);
        int Anfang = 0;
        int len_wd = whole_data.length;
        for (var i = 0; i<len_wd-9; i++) {

          if(whole_data.substring(i,i+9) == 'direction'){
            break;

          }
          Anfang++;
        }

        int Ende = 0;

        for (var i = 0; i<len_wd-26; i++) {

          if(whole_data.substring(i,i+26) == 'EntityKeyType.ENTITY_FIELD'){
            break;

          }
          Ende++;
        }

        print(whole_data.substring(Anfang,Ende));
        //----------------------Suche nach Werte-------------------

        // var whole_data_Nr = whole_data.replaceAll(new RegExp(r'[^0-9]'),'');
        //
        // whole_data_Nr = whole_data_Nr.substring(22);
        // print(whole_data_Nr);
        // int Anfang = 0;
        // int len_wdN = whole_data_Nr.length;
        //
        // for (var i = 0; i<len_wdN-10; i++) {
        //
        //   if(whole_data_Nr.substring(i,i+10) == '1671058795'){
        //     break;
        //
        //   }
        //   Anfang++;
        //  }
        // var result = whole_data_Nr.substring(0,Anfang-1);
        // print(result);
        // // var result = whole_data_Nr.substring(0,Anfang-1);

        // print(result);

        // var len_wdN = whole_data_Nr.length;
        // for (var i = 0; i<len_wdN; i++) {
        //   if
        //   whole_data_Nr =
        // }


        // String StrC = '';
        // do {
        //
        //   StrC = whole_data;
        //
        // } while(StrC == '');
        // print('whole_data 2222222222222: $whole_data_Nr');
        // for(int i=0;i<str.length;i++){
        //     List<String> s = str[i].split(":");
        //     result.putIfAbsent(s[0].trim(), () => s[1].trim());
        // }
        //   print('result!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        //   print('result: $result');
        //   return result;
        // }
        // print('result!!!!!!!!!!!!!!!!: $whole_data_Nr');
        // var decoded = json.decode(whole_data.toString());
        // var map = Map.fromIterable(decoded, key: (e) => e.keys.first, value: (e) => e.values.first);


        // whole_data in json konvertieren (Youtube)
        //
        // print('Received entity data update: $map');
        // print('type of whole_data: ${map.runtimeType}');

        // var wholedata = entityDataUpdate.update!.asMap();
        // print(wholedata.runtimeType);
        //
        // print(wholedata['0']);
        //
        // var keys = wholedata.keys.toList();
        // print('keys: $keys');
        // var val = wholedata[keys];
        // print('values: $val');


        print('---------------------Ende---------------------');
      });


      print('------------------------------------------------');



      subscription.subscribe();

      await Future.delayed(Duration(seconds: 1));
      // !!!!!!!!!!!!!!!!!!!!!!!!!timeseries end!!!!!!!!!!!!!!!!!!!!!!

    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      //height: MediaQuery.of(context).size.height * 0.5,
      height: 1400,

      child: Column(
        children: <Widget>[
          Container(
            height: 80,
            color: Color.fromRGBO(23, 156, 125, 0.5),
            child: Row(
              children: <Widget>[
                _buildStatCard('Systemzustand', 'ON / OFF',  _emergency_switch?Colors.green:Colors.red),
                _buildStatCard('Test läuft', 'ON / OFF',  _is_testing?Colors.green:Colors.red),
              ],
            ),
          ),

          Container(
            height: 80,
            color: Color.fromRGBO(23, 156, 125, 0.5),
            child: Row(
              children: <Widget>[

                _buildStatCard('Home Position', 'ON / OFF',  _is_homing?Colors.green:Colors.red),

                _buildStatCard_direction('Drehrichtung', '',  _direction==1?IconData(0xe540, fontFamily: 'MaterialIcons'):IconData(0xe53f, fontFamily: 'MaterialIcons')),
              ],
            ),
          ),

          SizedBox(height: 10,),
          Text('PWM Signal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          Container(
              height: 200,
              child:
              SfRadialGauge(

                axes: <RadialAxis>[
                  RadialAxis(minimum: 0, maximum: 300, labelOffset: 10,
                    axisLineStyle: AxisLineStyle(
                        thicknessUnit: GaugeSizeUnit.factor,thickness: 0.03),
                    majorTickStyle: MajorTickStyle(length: 12,thickness: 3,color: Colors.black),
                    minorTickStyle: MinorTickStyle(length: 7,thickness: 1,color: Colors.black),
                    axisLabelStyle: GaugeTextStyle(color: Colors.black,fontSize: 13 ),
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 300, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                        gradient: SweepGradient(
                            colors: const<Color>[Colors.white,Colors.red],
                            stops: const<double>[0.0,1]
                        ),
                      ),
                    ],
                    pointers: <GaugePointer>[NeedlePointer(value: _pwm_frequency, needleLength: 0.95, enableAnimation: true,
                      animationType: AnimationType.ease, needleStartWidth: 1, needleEndWidth: 3, needleColor: Colors.red,
                    ),],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(widget: Container(child:
                      Column(
                        children: <Widget>[
                          Text(_pwm_frequency.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          SizedBox(height: 5,),
                          Text('Hz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                        ],
                      )
                      ), angle: 90, positionFactor: 1.5, )],
                  ),

                ],

              )
          ),
          SizedBox(height: 10,),

          Container(
            color: Color.fromRGBO(23, 156, 125, 0.5),

            child: Column(
              children: [
                SizedBox(height: 10,),

                Text('Speed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                Container(
                    height: 200,

                    child:
                    SfRadialGauge(

                      axes: <RadialAxis>[
                        RadialAxis(minimum: 0, maximum: 100, labelOffset: 10,
                          axisLineStyle: AxisLineStyle(
                              thicknessUnit: GaugeSizeUnit.factor,thickness: 0.1),
                          majorTickStyle: MajorTickStyle(length: 12,thickness: 3,color: Colors.black),
                          minorTickStyle: MinorTickStyle(length: 7,thickness: 1,color: Colors.black),
                          axisLabelStyle: GaugeTextStyle(color: Colors.black,fontSize: 13 ),
                          ranges: <GaugeRange>[
                            GaugeRange(startValue: 0, endValue: 100, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                              gradient: SweepGradient(
                                  colors: const<Color>[Colors.white54,Colors.white54],
                                  stops: const<double>[0.0,1]
                              ),
                            ),
                          ],
                          pointers: <GaugePointer>[RangePointer(value: _speed, width: 0.1, sizeUnit: GaugeSizeUnit.factor,
                            gradient: const SweepGradient(colors: <Color>[Colors.red, Color(0xFFC41A3B)], stops: <double>[0.25, 0.75]),

                          ),],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(widget: Container(child:
                            Column(
                              children: <Widget>[
                                Text(_speed.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                SizedBox(height: 5,),
                                Text('rpm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                              ],
                            )
                            ), angle: 90, positionFactor: 1.5, )],
                        ),

                      ],

                    )
                ),
              ],
            ),
          ),



          Flexible(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child:
                    SfCartesianChart(
                      series: <LineSeries<LiveData, num>>[
                        LineSeries<LiveData, num>(
                          onRendererCreated: (ChartSeriesController controller) {
                            _chartSeriesController = controller;
                          },
                          dataSource: chartData,
                          color: const Color.fromRGBO(192, 108, 132, 1),
                          xValueMapper: (LiveData sales, _) => sales.time,
                          yValueMapper: (LiveData sales, _) => sales.signal,


                        )
                      ],
                      primaryXAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0, color: Colors.black),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          interval: 1,
                          title: AxisTitle(text: 'Zeit (s)')
                      ),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 1, color: Colors.black),
                          majorTickLines: const MajorTickLines(size: 0),
                          title: AxisTitle(text: 'PWM Signal (Hz)')
                      ),

                      backgroundColor: Colors.transparent,

                    ),



                  ),
                ),

              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child:
                    SfCartesianChart(
                      series: <LineSeries<LiveData, num>>[
                        LineSeries<LiveData, num>(
                          onRendererCreated: (ChartSeriesController controller) {
                            _chartSeriesController = controller;
                          },
                          dataSource: chartData,
                          color: const Color.fromRGBO(192, 108, 132, 1),
                          xValueMapper: (LiveData sales, _) => sales.time,
                          yValueMapper: (LiveData sales, _) => sales.speed,


                        )
                      ],
                      primaryXAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0, color: Colors.black),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          interval: 1,
                          title: AxisTitle(text: 'Zeit (s)')
                      ),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 1, color: Colors.black),
                          majorTickLines: const MajorTickLines(size: 0),
                          title: AxisTitle(text: 'Motorgeschwindigkeit (U/min)')
                      ),

                      backgroundColor: Colors.transparent,

                    ),



                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  int t = 0;
  void updateDataSource(Timer timer) {
    if (t < 10) {
      chartData.add(LiveData(t++, _speed, _pwm_frequency, _time));
      _chartSeriesController.updateDataSource(
          addedDataIndex: t);
    }
    else {
      chartData.add(LiveData(t++, _speed, _pwm_frequency, _time));
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    }
  }


  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0, 0, 0)
    ];
  }


  Expanded _buildStatCard(String title, String count, MaterialColor zustandscolor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: zustandscolor,
                  borderRadius: BorderRadius.circular(15)
              ),
            ),

          ],
        ),
      ),
    );
  }
}



Expanded _buildStatCard_direction(String title, String count, IconData icon) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),

          Icon(icon, size: 35,)



        ],
      ),
    ),
  );
}




class LiveData {
  LiveData(this.t, this.speed, this.signal, this.time);
  final int t;
  final num speed;
  final num signal;
  final num time;

}