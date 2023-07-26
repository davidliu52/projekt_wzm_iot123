import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projekt_wzm_iot/pages/dashboard_page_S2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:projekt_wzm_iot/mqtt_server_client.dart' if (dart.library.html) 'package:projekt_wzm_iot/mqtt_browser_client.dart' as mqttsetup;


//DashboardS2Grid is an independent class, solely for displaying the chart.

class DashboardS2Grid extends StatefulWidget {
  const DashboardS2Grid({super.key});

  @override
  State<DashboardS2Grid> createState() => _DashboardS2GridState();
}

class _DashboardS2GridState extends State<DashboardS2Grid> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  Map<String, dynamic> pt = {};
  Timer? _updateTimer;
  Timer? _dataReadTimer;
  final client = mqttsetup.setup('broker.emqx.io', 'uniqueID', 1883);

  //----- This function will initialize the function. It is called only once------

  @override
  void initState() {
    chartData = getChartData();// Prepare the data for the time series chart.
    _updateTimer=Timer.periodic(const Duration(seconds: 1), updateDataSource);
    //  This line is initializing a periodic timer that triggers every second. When the timer triggers, it calls the updateDataSource() function.
    super.initState();
    connectAndSubscribe1();// This is a custom function that be used to connect MQTT broker.
  }

  //---------initialize the parameter-----------

  double _x = 0;
  double _y = 0;
  double _z = 0;
 // double _time = 0;
  bool _is_connecting = false;
  String _currentPage = DashboardS2Page.pageName;
  String get currentPage => _currentPage;

  _DashboardS2GridState() {
    if (_currentPage == DashboardS2Page.pageName) {
      _dataReadTimer = Timer.periodic(const Duration(milliseconds: 1000), (_timer) {
        dateneinlesen();
      });
    }
  }

//dispose method used to release the memory allocated to variables when state object is removed.
//If you turn off this page, the MQTT broker will be disconnected.The same for updateTimer and _dataReadTimer

  @override
  void dispose() {
    print("Connection status before disconnect: ${client.connectionStatus}");
    client.disconnect();
    print("Connection status after disconnect: ${client.connectionStatus}");
    _updateTimer?.cancel(); // Cancel the timers
    _dataReadTimer?.cancel();
    super.dispose();
  }

//-----------MQTT_connection----begin----------------

  Future<void> connectAndSubscribe1() async {
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('clientId-x1TCmasbCY')
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
      print('Client connected');
    } else {
      print('Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return;
    }

    //---------subscribe the topic ----------------

    const subTopic = 'sensor2/data';
    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final ptValue = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        pt = json.decode(ptValue);
    });

    //---------Publish the data into the topic---------------

    const publishTopic = 'sensor2/data'; // You can change this to the topic you want to publish to.
    final builder = MqttClientPayloadBuilder();
    builder.addString(json.encode({
      "serialNumber": "SN-01",
      "sensorType": "Accelerometer",
      "sensorModel": "LIS3DH",
      "x": 30,
      "y": 10,
      "z": 25,
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

  //----------------MQTT_connection---end

//--------read the specific values from the pt dataset(MQTT broker)----------

  void dateneinlesen()  {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _x=double.parse(pt['x'].toString());
      _y=double.parse(pt['y'].toString());
      _z=double.parse(pt['z'].toString());
      _is_connecting = this._is_connecting;
    });
  }


  @override
  Widget build(BuildContext context) {


    //-------------------------Widget chart end ---------



    return Column(
        children: [
          Container(
            height:80,
            color: const Color.fromRGBO(23, 156, 125, 0.5),
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(50.0)),
                    alignment: Alignment.center, // You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                    child: const Text(' Connection to MQTT',
                        style:TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600 ,)
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      alignment: Alignment.center, // You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
                      child: Center(
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                color: _is_connecting?Colors.green:Colors.red,
                                borderRadius: BorderRadius.circular(15)
                            ),
                          )
                      )
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SfCartesianChart(
              series: <ChartSeries>[
                LineSeries<LiveData, DateTime>(
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
                  majorGridLines: const MajorGridLines(width: 0.8),
                  dateFormat: DateFormat('HH:mm:ss'), // set the form of the time
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1,
                  title: AxisTitle(text: 'Zeit [s]')
              ),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 1, color: Colors.black),
                  majorTickLines: const MajorTickLines(size: 0),
                  title: AxisTitle(text: 'Values [g]')
              ),
              legend: Legend(isVisible: true),
              backgroundColor: Colors.transparent,
            ),
          )
        ]
    );



  }

  int t = 0;

  void updateDataSource(Timer timer) {
    if (t < 15) {
      chartData.add(LiveData(t++, _x, _y, _z, DateTime.now()));
      _chartSeriesController.updateDataSource(
          addedDataIndex: t);
    }
    else {
      chartData.add(LiveData(t++, _x, _y, _z, DateTime.now()));
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