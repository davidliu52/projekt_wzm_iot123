import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:projekt_wzm_iot/mqtt_server_client.dart' if (dart.library.html) 'package:projekt_wzm_iot/mqtt_browser_client.dart' as mqttsetup;
import 'dart:io';

import '../pages/dashboard_page_S2.dart';



class DashboardS2VRGrid extends StatefulWidget {

  @override
  State<DashboardS2VRGrid> createState() => _DashboardS2VRGridState();
}

class _DashboardS2VRGridState extends State<DashboardS2VRGrid> {

  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  final client = mqttsetup.setup('10.22.40.175', 'uniqueID', 1883);
  Map<String, dynamic> pt = {};
  Color _FraunhoferColor = const Color.fromRGBO(23, 156, 125, 1);


  Timer? _updateTimer;
  Timer? _dataReadTimer;

  @override
  void initState() {
    chartData = getChartData();
    _updateTimer=Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
    //  late ChartSeriesController _chartSeriesController;
    connectAndSubscribe1();
  }
//MQTT_listen


  double _x = 0;
  double _y = 0;
  double _z = 0;
  //double _time = 0;
  bool _is_connecting = false;
  String _currentPage = DashboardS2Page.pageName;
  String get currentPage => _currentPage;


  Timer? _timer;

  _DashboardS2VRGridState() {


    _dataReadTimer = Timer.periodic(const Duration(milliseconds: 1000), (_timer) {
      dateneinlesen2();
    });


  }

  @override
  void dispose() {
    print("Connection status before disconnect: ${client.connectionStatus}");

    client.disconnect();

    print("Connection status after disconnect: ${client.connectionStatus}");
    _updateTimer?.cancel(); // Cancel the timers
    _dataReadTimer?.cancel();
    super.dispose();
  }


  //MQTT_connection

  Future<void> connectAndSubscribe1() async {

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('clientId-x1TCmas')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      _is_connecting = true;
      print('the value of the connection $_is_connecting');

      print('Client connected');
    } else {
      print('Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return;
    }

    const subTopic = 'sensor2/data';
    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final ptValue = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //   setState(() {
      pt = json.decode(ptValue);
      // print(pt['t']);
      // });
    });

    const publishTopic = 'sensor2/data'; // You can change this to the topic you want to publish to.
    final builder = MqttClientPayloadBuilder();
    builder.addString(json.encode({
      "serialNumber": "SN-01",
      "sensorType": "Accelerometer",
      "sensorModel": "LIS3DH",
      "x": 42,
      "y": 30,
      "z": 20,
      "time":0.1
    }));
    print('Publishing message to $publishTopic');
    client.publishMessage(publishTopic, MqttQos.atLeastOnce, builder.payload!);


  }

  void onConnected() {
    print('Connected to MQTT server');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }


  //MQTT_connection---end


  void dateneinlesen2()  {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _x=double.parse(pt['x'].toString());
      _y=double.parse(pt['y'].toString());
      _z=double.parse(pt['z'].toString());
      _is_connecting = _is_connecting;

      //   _time;
    });
  }



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: MediaQuery.of(context).size.height * 0.5,
        height: 200,
        child: Column(
            children: [

              Container(
                color: Colors.white,
                child: const SizedBox(
                  height: 10,
                  child: Center(
                    child: Text('Sensor 2', style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),


              Container(
                height:20,
                color: _FraunhoferColor,
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration( borderRadius: BorderRadius.circular(2.0)),
                        alignment: Alignment.center, // You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                        child: const Text(' Connection to MQTT',
                            style:TextStyle(
                              color: Colors.black,
                              fontSize: 4.0,
                              fontWeight: FontWeight.w600 ,)
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          alignment: Alignment.center, // You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                          child: Center(
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                    color: _is_connecting?Colors.green:Colors.red,
                                    borderRadius: BorderRadius.circular(4)
                                ),
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),


              Container(
                height: 80,
                padding: const EdgeInsets.all(0),
                color: Colors.white,

                child: SfCartesianChart(
                  series: <ChartSeries>[
                    LineSeries<LiveData, DateTime>(
                        width: 0.5, // Set the width of the line here

                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: chartData,
                        color: Colors.red,
                        xValueMapper: (LiveData sales, _) => sales.time,
                        yValueMapper: (LiveData sales, _) => sales.x,
                        name: 'X' // Legend label for this series

                    ),

                    LineSeries<LiveData, DateTime>(
                        width: 0.5, // Set the width of the line here

                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: chartData,
                        color: Colors.blue,
                        xValueMapper: (LiveData sales, _) => sales.time,
                        yValueMapper: (LiveData sales, _) => sales.y,
                        name: 'Y' // Legend label for this series

                    ),

                    LineSeries<LiveData, DateTime>(
                        width: 0.5, // Set the width of the line here
                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: chartData,
                        color: Colors.green,
                        xValueMapper: (LiveData sales, _) => sales.time,
                        yValueMapper: (LiveData sales, _) => sales.z,
                        name: 'Z' // Legend label for this series
                    ),
                  ],
                  primaryXAxis: DateTimeAxis(
                      majorGridLines: const MajorGridLines(width: 0.2),
                      dateFormat: DateFormat('HH:mm:ss'), // set the form of the time
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      interval: 1,
                      labelStyle: const TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels

                      title: AxisTitle(text: 'Zeit [s]',  textStyle: const TextStyle(fontSize: 3,color: Colors.black))
                  ),
                  primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0.1, color: Colors.black),
                      majorGridLines: const MajorGridLines(width: 0.2),
                      majorTickLines: const MajorTickLines(size: 0),
                      labelStyle: const TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels
                      interval: 5,
                      title: AxisTitle(text: 'Values [g]',  textStyle: const TextStyle(fontSize: 3,color: Colors.black))
                  ),
                  backgroundColor: Colors.transparent,
                ),
              )
            ]
        )
    );
  }

  int t = 0;

  void updateDataSource(Timer timer) {
    if (t < 8) {
      chartData.add(LiveData(t++, _x, _y, _z,  DateTime.now()));
      _chartSeriesController.updateDataSource(
          addedDataIndex: t);
    }
    else {
      chartData.add(LiveData(t++, _x, _y, _z,  DateTime.now()));
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    }
  }


  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0, 0, 0, DateTime.now())
    ];
  }
}

class LiveData {
  LiveData(this.t, this.x, this.y, this.z, this.time);
  final int t;
  final num x;
  final num y;
  final num z;
  final DateTime time;
}

//  The unsolicited disconnect callback

