import 'package:flutter/material.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S2.dart';
import 'package:projekt_wzm_iot/pages/main_page.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_client/thingsboard_client.dart';


class DashboardS2Grid extends StatefulWidget {

  @override
  State<DashboardS2Grid> createState() => _DashboardS2GridState();
}

class _DashboardS2GridState extends State<DashboardS2Grid> {

  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 3), updateDataSource);
    super.initState();
  }

  var tbClient = ThingsboardClient(thingsBoardApiEndpoint);
  double _x = 0;
  double _y = 0;
  double _z = 0;
  double _time = 0;
  String _currentPage = DashboardS2Page.pageName;

  String get currentPage => _currentPage;


  Timer? _timer;

  _DashboardS2GridState() {
    login();


    if (_currentPage == DashboardS2Page.pageName) {
      _timer = Timer.periodic(const Duration(milliseconds: 3000), (_timer) {
        dateneinlesen();
      });
    }
  }


  // Thingsboard login
  void login() async {
    try {
      await tbClient.login(LoginRequest(ID, PW));
      print('isAuthenticated=${tbClient.isAuthenticated()}');
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }

  void dateneinlesen() async {
    try {
      // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      // final accessToken = sharedPreferences.getString('access_token');
      // final tbClient = ThingsboardClient(thingsBoardApiEndpoint);


      if (tbClient.isAuthenticated() == true) {
        var deviceName = 'Sensor 1';
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
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'x'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'y'),
          EntityKey(type: EntityKeyType.TIME_SERIES, key: 'z'),
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
              'x',
              'y',
              'z',
              'time'
            ]),
            startTs: currentTime - timeWindow,
            timeWindow: timeWindow);

        var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

        var telemetryService = tbClient.getTelemetryService();

        var subscription = TelemetrySubscriber(telemetryService, [cmd]);

        subscription.entityDataStream.listen((entityDataUpdate) {
          var whole_data = entityDataUpdate.toString();


          print(whole_data);

          int len_wd = whole_data.length;

          // x ANFANG--------------------------------------------------------
          int Anfang_x = 0;
          for (var i = 0; i < len_wd - 2; i++) {
            if (whole_data.substring(i, i + 2) == 'x:') {
              break;
            }
            Anfang_x++;
          }

          int Ende_x = Anfang_x;

          for (var i = Anfang_x; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_x++;
          }

          for (var i = Anfang_x; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_x++;
          }

          _x =
              double.parse(whole_data.substring(Anfang_x, Ende_x));

          // x ENDE--------------------------------------------------------

          // y ANFANG--------------------------------------------------------
          int Anfang_y = 0;
          for (var i = 0; i < len_wd - 2; i++) {
            if (whole_data.substring(i, i + 2) == 'y:') {
              break;
            }
            Anfang_y++;
          }

          int Ende_y = Anfang_y;

          for (var i = Anfang_y; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_y++;
          }

          for (var i = Anfang_y; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_y++;
          }

          _y =
              double.parse(whole_data.substring(Anfang_y, Ende_y));

          // y ENDE--------------------------------------------------------

          // z ANFANG--------------------------------------------------------
          int Anfang_z = 0;
          for (var i = 0; i < len_wd - 2; i++) {
            if (whole_data.substring(i, i + 2) == 'z:') {
              break;
            }
            Anfang_z++;
          }

          int Ende_z = Anfang_z;

          for (var i = Anfang_z; i < len_wd; i++) {
            if (whole_data[i] == '}') {
              break;
            }
            Ende_z++;
          }

          for (var i = Anfang_z; i < len_wd; i++) {
            if (whole_data.substring(i - 7, i) == 'value: ') {
              break;
            }
            Anfang_z++;
          }

          _z =
              double.parse(whole_data.substring(Anfang_z, Ende_z));

          // z ENDE--------------------------------------------------------

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
            _x;
            _y;
            _z;
            _time;
          });
        });


        subscription.subscribe();

        await Future.delayed(Duration(seconds: 3));
        // !!!!!!!!!!!!!!!!!!!!!!!!!timeseries end!!!!!!!!!!!!!!!!!!!!!!
      }
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      //height: MediaQuery.of(context).size.height * 0.5,
        height: 1000,

        child: Column(
            children: [
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
                              onRendererCreated: (
                                  ChartSeriesController controller) {
                                _chartSeriesController = controller;
                              },
                              dataSource: chartData,
                              color: Colors.red,
                              xValueMapper: (LiveData sales, _) => sales.t,
                              yValueMapper: (LiveData sales, _) => sales.x,


                            )
                          ],
                          primaryXAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(
                                  width: 0, color: Colors.black),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              interval: 1,
                              title: AxisTitle(text: 'Zeit [s]')
                          ),
                          primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(
                                  width: 1, color: Colors.black),
                              majorTickLines: const MajorTickLines(size: 0),
                              title: AxisTitle(text: 'x [g]')
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
                              onRendererCreated: (
                                  ChartSeriesController controller) {
                                _chartSeriesController = controller;
                              },
                              dataSource: chartData,
                              color: Colors.green,
                              xValueMapper: (LiveData sales, _) => sales.t,
                              yValueMapper: (LiveData sales, _) => sales.y,


                            )
                          ],
                          primaryXAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(
                                  width: 0, color: Colors.black),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              interval: 1,
                              title: AxisTitle(text: 'Zeit [s]')
                          ),
                          primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(
                                  width: 1, color: Colors.black),
                              majorTickLines: const MajorTickLines(size: 0),
                              title: AxisTitle(
                                  text: 'y [g]')
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
                              onRendererCreated: (
                                  ChartSeriesController controller) {
                                _chartSeriesController = controller;
                              },
                              dataSource: chartData,
                              color: Colors.blue,
                              xValueMapper: (LiveData sales, _) => sales.t,
                              yValueMapper: (LiveData sales, _) => sales.z,


                            )
                          ],
                          primaryXAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(
                                  width: 0, color: Colors.black),
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              interval: 1,
                              title: AxisTitle(text: 'Zeit [s]')
                          ),
                          primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(
                                  width: 1, color: Colors.black),
                              majorTickLines: const MajorTickLines(size: 0),
                              title: AxisTitle(
                                  text: 'z [g]')
                          ),

                          backgroundColor: Colors.transparent,

                        ),


                      ),
                    ),

                  ],
                ),
              ),
            ]
        )
    );
  }

  int t = 0;

  void updateDataSource(Timer timer) {
    if (t < 10) {
      chartData.add(LiveData(t++, _x, _y, _z, _time));
      _chartSeriesController.updateDataSource(
          addedDataIndex: t);
    }
    else {
      chartData.add(LiveData(t++, _x, _y, _z, _time));
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    }
  }


  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0, 0, 0, 0)
    ];
  }

}





class LiveData {
  LiveData(this.t, this.x, this.y, this.z, this.time);
  final int t;
  final num x;
  final num y;
  final num z;
  final num time;

}