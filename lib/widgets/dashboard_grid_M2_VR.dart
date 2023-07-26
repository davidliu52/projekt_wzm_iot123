import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:projekt_wzm_iot/mqtt_server_client.dart' if (dart.library.html) 'package:projekt_wzm_iot/mqtt_browser_client.dart' as mqttsetup;
import 'package:intl/intl.dart';


class DashboardM2VRGrid extends StatefulWidget {

  @override
  State<DashboardM2VRGrid> createState() => _DashboardM2VRGridState();
}

class _DashboardM2VRGridState extends State<DashboardM2VRGrid>  {
  final client = mqttsetup.setup('broker.emqx.io', 'uniqueID', 1883);
  Map<String, dynamic> pt = {};
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  Timer? _updateTimer;
  Timer? _dataReadTimer;
  final Color _FraunhoferColor = const Color.fromRGBO(23, 156, 125, 1);

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {  // This function will initialize the function. It is called only once
    connectAndSubscribe();// This is a custom function that be used to connect MQTT broker.
    chartData = getChartData();
    _updateTimer= Timer.periodic(const Duration(seconds: 3), updateDataSource);
    super.initState();

  }

//---------initialize the parameter-----------
  bool _is_connecting = false;
  double  _pwm_frequency =0.0 ;
  double _speed = 0;



  @override
  // dispose method used to release the memory allocated to variables when state object is removed.
  // If you turn off this page, the MQTT broker will be disconnected.The same for updateTimer and _dataReadTimer
  void dispose() {
    print("Connection status before disconnect: ${client.connectionStatus}");
    client.disconnect();
    print("Connection status after disconnect: ${client.connectionStatus}");
    _updateTimer?.cancel(); // Cancel the timers
    _dataReadTimer?.cancel();
    super.dispose();
  }


  _DashboardM2VRGridState() {
       _dataReadTimer = Timer.periodic(const Duration(milliseconds: 3000), (_timer) {
        dateneinlesen();// get date from the MQTT broker every one seconds to update the Datasource and result in the movement of time in the X axis.
      });

  }

  Future<void> connectAndSubscribe() async {
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .authenticateAs('xdmbXujskqassv7pX6uv', '')
        .withClientIdentifier('clientId-zbi55uUj')
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
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final ptValue = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      // setState(() {
      pt = json.decode(ptValue);
      //});
    });

    //---------subscribe the topic ----------------

    const subTopic = 'motor1/data';
    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final ptValue = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      pt = json.decode(ptValue);
    });
    // ----------------Publishing the topic---------------

    const publishTopic = 'motor1/data'; // You can change this to the topic you want to publish to.
    final builder = MqttClientPayloadBuilder();
    builder.addString(json.encode({
      "serialNumber": "M-01",
      "motorType": "Motor",
      "motorModel": "Motor1",
      "t": 20,
      "s": 20,
      "f": 10,
      "ena": "enabled",
      "dir": "backward",
      "st": "yes",
      "tst": "no",
      "hom": "yes",
      "emer": "no"
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
//--------------------MQTT-connection---end

//--------read the specific values from the pt dataset(MQTT broker)----------

  void dateneinlesen ()  {
    if (!mounted) return; // Check if widget is still mounted
    //setState notify that the parameters inside will update.
    setState(() {
      _is_connecting = _is_connecting;
      _pwm_frequency = double.parse(pt['f'].toString());
      _speed = double.parse(pt['s'].toString());

    });
  }


  @override
  Widget build(BuildContext context) {
//-----isPortrait will detect the orientation of the device, The boolean value will be used to call the function to change the layout of the charts.
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

//-----------Handling the disposition of the two Time Series Line Charts, including their display and layout arrangement------------

    //-------A standalone widget just for displaying a Time Series Line Chart for the PWM values-----------

    Widget Timeserieschart_pwm() {
      return Container(
       height: 50,
          color: Colors.white,

      child: SfCartesianChart(
        series: <LineSeries<LiveData, DateTime>>[
          LineSeries<LiveData, DateTime>(
            width: 0.5, // Set the width of the line here

            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            dataSource: chartData,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.signal,
          )
        ],
        primaryXAxis: DateTimeAxis(
            majorTickLines: const MajorTickLines(size: 0.1),
            majorGridLines: const MajorGridLines(width: 0.1),
            dateFormat: DateFormat('HH:mm:ss'), // set the form of the time
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 1,
            labelStyle: TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels

       //     title: AxisTitle(text: 'Zeit [s]', textStyle: TextStyle(fontSize: 2)   )
        ),
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0.1, color: Colors.black),
            majorGridLines: const MajorGridLines(width: 0.1),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels
            interval: 5,

            title: AxisTitle(text: 'PWM Signal [Hz]',
                textStyle: TextStyle(fontSize: 3,color: Colors.black))
        ),
        backgroundColor: Colors.transparent,
      )
      );
    }


    //-------A standalone widget just for displaying a Time Series Line Chart for the Speed values-----------

    Widget Timeserieschart_speed() {
      return Container(
          height: 50,
          color: Colors.white,
          child: SfCartesianChart(
            series: <LineSeries<LiveData, DateTime>>[
              LineSeries<LiveData, DateTime>(
                width: 0.5, // Set the width of the line here
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController = controller;},
                dataSource: chartData,
                color: const Color.fromRGBO(192, 108, 132, 1),
                xValueMapper: (LiveData sales, _)=> sales.time,
                yValueMapper: (LiveData sales, _) => sales.speed,
              )
            ],
            primaryXAxis: DateTimeAxis(
                majorTickLines: const MajorTickLines(size: 0.1),
                majorGridLines: const MajorGridLines(width: 0.1),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                dateFormat: DateFormat('HH:mm:ss'), // set the form of time
                interval: 1,
                labelStyle: TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels

           //     title: AxisTitle(text: 'Zeit [s]', textStyle: TextStyle(fontSize: 2)   )
            ),
            primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0.1, color: Colors.black),
                majorGridLines: const MajorGridLines(width: 0.1),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(fontSize: 3,color: Colors.black), // Set your desired font size for the labels
                interval: 5,
                title: AxisTitle(text: 'Motorgeschwindigkeit [U/min]',
                    textStyle: TextStyle(fontSize: 3, color: Colors.black))
            ),
            backgroundColor: Colors.transparent,
          )
      );
    }
//-------------Functions used to modify the layout---------------

    // For instance, if the device is currently in portrait mode, it will invoke the buildColumn_Timeserieschart() function.
    // This function arranges the two Time Series Line Charts vertically in a column.

  Widget buildColumn_Timeserieschart(){
      return  Container(
          child: Column(
            children: [
              Container(child: Timeserieschart_pwm()),
              Container(child: Timeserieschart_speed()),
            ],
          )
      );
    }

//-----------------------------------

//---------------------Handling finish-------------------------

//-----------Handling the disposition of the two Radial Gauge Charts, including their display and layout arrangement------------

// ---------A standalone widget just for displaying a  Radial Gauge Chart for the PWM values-----------

    Widget buildPWM_gauges(){

      return Container(
          height:50,
          color: Colors.white,
          child:
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(minimum: 0, maximum: 300,  interval: 50,  labelOffset:3,// <-- Add this line

                axisLineStyle: const AxisLineStyle(
                    thicknessUnit: GaugeSizeUnit.factor,thickness: 0.1),
                majorTickStyle: const MajorTickStyle(length: 1,thickness: 0.8,color: Colors.black),
                minorTickStyle: const MinorTickStyle(length: 0.8,thickness: 0.2,color: Colors.black),
                axisLabelStyle: const GaugeTextStyle(color: Colors.black,fontSize: 3 ),
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: 300, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                    gradient: const SweepGradient(
                        colors: <Color>[Colors.white,Colors.red],
                        stops: <double>[0.0,1]
                    ),
                  ),
                ],
                pointers: <GaugePointer>[NeedlePointer(value: _pwm_frequency.toDouble(), needleLength: 0.5, enableAnimation: false,
                  animationType: AnimationType.ease, needleStartWidth: 0.2, needleEndWidth: 1, needleColor: Colors.red,
                ),],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(widget: Container(child:
                    Column(
                    children: <Widget>[
                      Text(_pwm_frequency.toString(), style: TextStyle(fontSize: 3, fontWeight: FontWeight.bold),),
                      SizedBox(height: 5,),
                      Text('Hz', style: TextStyle(fontSize: 3, fontWeight: FontWeight.bold),)
                    ],
                  )
                  ), angle: 90, positionFactor: 1.5, )],
              ),
            ],
          )
      );
    }
// -------A standalone widget just for displaying a Radial Gauge Chart for the Speed values-----------

    Widget buildSpeed_gauges(){
      return Container(
          height: 50,
          color: _FraunhoferColor,

          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(minimum: 0, maximum: 300,  interval: 50,  labelOffset:3,// <-- Add this line
                axisLineStyle: const AxisLineStyle(
                    thicknessUnit: GaugeSizeUnit.factor,thickness: 0.1),
                majorTickStyle: const MajorTickStyle(length: 1,thickness: 0.8,color: Colors.black),
                minorTickStyle: const MinorTickStyle(length: 0.8,thickness: 0.2,color: Colors.black),
                axisLabelStyle: const GaugeTextStyle(color: Colors.black,fontSize: 3 ),
                ranges: <GaugeRange>[
                  GaugeRange(startValue: 0, endValue: 300, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                    gradient: const SweepGradient(
                        colors: <Color>[Colors.white54,Colors.white54],
                        stops: <double>[0.0,1]
                    ),
                  ),
                ],
                pointers: <GaugePointer>[RangePointer(value: _speed, width: 0.1, sizeUnit: GaugeSizeUnit.factor,
                  gradient: const SweepGradient(colors: <Color>[Colors.red, Color(0xFFC41A3B)], stops: <double>[0.25, 0.75]),
                  enableAnimation: false,
                ),],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(widget: Container(child:
                  Column(
                    children: <Widget>[
                      Text(_speed.toString(), style: TextStyle(fontSize: 3, fontWeight: FontWeight.bold),),
                      SizedBox(height: 5,),
                      Text('rpm', style: TextStyle(fontSize: 3, fontWeight: FontWeight.bold),)
                    ],
                  )
                  ), angle: 90, positionFactor: 1.5, )],
              ),

            ],

          )
      );
    }


//-------------Functions used to modify the layout---------------

    // For instance, if the device is currently in portrait mode, it will invoke the buildRow_gauges() function.
    // This function arranges the two Radial Gauge Chart vertically in a column.

    Widget buildRow_gauges(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child:buildPWM_gauges()),
          Expanded(child:buildSpeed_gauges()),
        ],
      );
    }
    Widget buildColumn_gauges(){
      return Container(
        child: Column(
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: buildPWM_gauges()),
            Container(child: buildSpeed_gauges()),
          ],
        ),
      );
    }
    //----------------------------

//---------------------Handling finish-------------------------

    Widget buildRow_Timeserieschart(){
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child:Timeserieschart_pwm()),
          Expanded(child:Timeserieschart_speed()),
        ],
      );
    }
//-----------------------test----------------



//--------------Displaying all the information related to Motor1-----------

    return Container(
//-------the five Container will be arrange in a -------
       height: 200,
       child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: const SizedBox(
              height: 10,
              child: Center(
                child: Text('Motor 2', style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
          isPortrait ? buildColumn_gauges() : buildRow_gauges(),
          isPortrait ? buildColumn_Timeserieschart() : buildRow_Timeserieschart(),

        ],
      ),
    );
  }

  int t = 0;
  void updateDataSource(Timer timer) {
    if (t < 5) {
      chartData.add(LiveData(t++, _speed, _pwm_frequency, DateTime.now()));
     // print('the value of the time ${DateTime.now()}');

      _chartSeriesController.updateDataSource(
          addedDataIndex: t);
    }
    else {
      chartData.add(LiveData(t++, _speed, _pwm_frequency, DateTime.now()));
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
          addedDataIndex: chartData.length - 1, removedDataIndex: 0);
    }
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0, 0, DateTime.now())
    ];
  }

}


class LiveData {
  LiveData(this.t, this.speed, this.signal, this.time);
  final int t;
  final num speed;
  final num signal;
  final DateTime  time;

}

