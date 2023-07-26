import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:projekt_wzm_iot/mqtt_server_client.dart' if (dart.library.html) 'package:projekt_wzm_iot/mqtt_browser_client.dart' as mqttsetup;
import '../pages/dashboard_page_M2.dart';


//DashboardM2Grid is an independent class, solely for displaying the chart.

class DashboardM2Grid extends StatefulWidget {
  const DashboardM2Grid({super.key});

  @override
  State<DashboardM2Grid> createState() => _DashboardGridM2State();
}

class _DashboardGridM2State extends State<DashboardM2Grid> {
  Map<String, dynamic> pt = {};
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  Timer? _updateTimer;
  Timer? _dataReadTimer;
  Uint8List? image64;
  final client = mqttsetup.setup('broker.emqx.io', 'uniqueID', 1883);

// This function will initialize the function. It is called only once---------

  @override
  void initState()  {
    connectAndSubscribe(); // This is a custom function that be used to connect MQTT broker.
    chartData = getChartData();// Prepare the data for the time series chart.
    _updateTimer=  Timer.periodic(const Duration(seconds: 1), updateDataSource);//  This line is initializing a periodic timer that triggers every second. When the timer triggers, it calls the updateDataSource() function.
    super.initState();
  }

  //---------initialize the parameter-----------

  bool _emergency_switch = false;
  bool _is_homing = false;
  bool _is_testing = false;
  bool _is_connecting = false;
  String _direction = '';
 // bool _direction=1;
  double _pwm_frequency = 0;
  double _speed = 0;
  //double _time = 0;
  String _currentPage = DashboardM2Page.pageName;
  String get currentPage=>_currentPage;

// dispose method used to release the memory allocated to variables when state object is removed.
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

  _DashboardGridM2State() {
    if(_currentPage == DashboardM2Page.pageName) {
      _dataReadTimer = Timer.periodic(const Duration(milliseconds: 3000), (_timer) {
        dateneinlesen1();
        // get date from the MQTT broker every one seconds to update the Datasource and result in the movement of time in the X axis.
      });
    }
  }

//-----------MQTT_connection----begin----------------

  Future<void> connectAndSubscribe() async {
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('clientId-nofE1cE43b')
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

    const subTopic = 'v1/devices/me/telemetry/pi_data';
  //   const subTopic = 'Motor1/data';

    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final ptValue = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
       setState(() {
         pt = json.decode(ptValue);

       });

        print(pt);
      print(pt['is_homing']);

    });

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

//----------------MQTT_connection---end-----------------------


//--------read the specific values from the pt dataset(MQTT broker)----------

  void dateneinlesen1()  {
    if (!mounted) return; // Check if widget is still mounted

   // setState(() {     //setState notify that the parameters inside will update.
      _direction = pt['direction'];
    _pwm_frequency = double.parse(pt['pwm_frequency'].toString());

    _speed = double.parse(pt['speed'].toString());
      _is_homing = pt['is_homing'];
      _is_testing = pt['is_testing'];
      _is_connecting = _is_connecting;
      _emergency_switch = pt['emergency_switch'] ;
 //   });
  }


  @override
  Widget build(BuildContext context) {
//-----isPortrait will detect the orientation of the device, The boolean value will be used to call the function to change the layout of the charts.
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

//-----------Handling the disposition of the two Time Series Line Charts, including their display and layout arrangement------------

    //-------A standalone widget just for displaying a Time Series Line Chart for the PWM values-----------

    Widget Timeserieschart_pwm() {
      return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SfCartesianChart(
            series: <LineSeries<LiveData, DateTime>>[
              LineSeries<LiveData, DateTime>(
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
                majorGridLines: const MajorGridLines(width: 0.8),
                dateFormat: DateFormat('HH:mm:ss'), // set the form of the time
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: 1,
                title: AxisTitle(text: 'Zeit [s]')
            ),
            primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 1, color: Colors.black),
                majorTickLines: const MajorTickLines(size: 0),
                title: AxisTitle(text: 'PWM Signal [Hz]')
            ),
            backgroundColor: Colors.transparent,
          )
      );
    }


    //-------A standalone widget just for displaying a Time Series Line Chart for the Speed values-----------

    Widget Timeserieschart_speed() {
      return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SfCartesianChart(
            series: <LineSeries<LiveData, DateTime>>[
              LineSeries<LiveData, DateTime>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController = controller;},
                dataSource: chartData,
                color: const Color.fromRGBO(192, 108, 132, 1),
                xValueMapper: (LiveData sales, _)=> sales.time,
                yValueMapper: (LiveData sales, _) => sales.speed,
              )
            ],
            primaryXAxis: DateTimeAxis(
                majorGridLines: const MajorGridLines(width: 0.8),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                dateFormat: DateFormat('HH:mm:ss'), // set the form of time
                interval: 1,
                title: AxisTitle(text: 'Zeit [s]')
            ),
            primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 1, color: Colors.black),
                majorTickLines: const MajorTickLines(size: 0),
                title: AxisTitle(text: 'Motorgeschwindigkeit [U/min]')
            ),
            backgroundColor: Colors.transparent,
          )
      );
    }

//-------------Functions used to modify the layout---------------

    // For instance, if the device is currently in portrait mode, it will invoke the buildColumn_Timeserieschart() function.
    // This function arranges the two Time Series Line Charts vertically in a column.

    Widget buildColumn(){
      return  Column(
        children: [
          Container(child: Timeserieschart_pwm()),
          Container(child: Timeserieschart_speed()),
        ],
      );
    }

    Widget buildRow(){
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child:Timeserieschart_pwm()),
          Expanded(child:Timeserieschart_speed(),
          ),
        ],
      );
    }

//------------Handling of the chart layout is complete-------------------------


//-----------Handling the disposition of the two Radial Gauge Charts, including their display and layout arrangement------------

// ---------A standalone widget just for displaying a  Radial Gauge Chart for the PWM values-----------

    Widget buildPWM_gauges(){
      return Container(
          color: Colors.white,
          child: Column(
              children: [
                const SizedBox(height: 10,),
                const Text('PWM Signal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                SizedBox(
                    height: 200,
                    child:
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(minimum: 0, maximum: 300, labelOffset: 10,
                          axisLineStyle: const AxisLineStyle(
                              thicknessUnit: GaugeSizeUnit.factor,thickness: 0.03),
                          majorTickStyle: const MajorTickStyle(length: 12,thickness: 3,color: Colors.black),
                          minorTickStyle: const MinorTickStyle(length: 7,thickness: 1,color: Colors.black),
                          axisLabelStyle: const GaugeTextStyle(color: Colors.black,fontSize: 13 ),
                          ranges: <GaugeRange>[
                            GaugeRange(startValue: 0, endValue: 300, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                              gradient: const SweepGradient(
                                  colors: <Color>[Colors.white,Colors.red],
                                  stops: <double>[0.0,1]
                              ),
                            ),
                          ],
                          pointers: <GaugePointer>[NeedlePointer(value: _pwm_frequency.toDouble(), needleLength: 0.95, enableAnimation: true,
                            animationType: AnimationType.ease, needleStartWidth: 1, needleEndWidth: 3, needleColor: Colors.red,
                          ),],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(widget: Column(
                              children: <Widget>[
                                Text(_pwm_frequency.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                const SizedBox(height: 5,),
                                const Text('Hz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                              ],
                            ), angle: 90, positionFactor: 1.5, )],
                        ),
                      ],
                    )
                ),
              ]
          )
      );
    }


// -------A standalone widget just for displaying a Radial Gauge Chart for the Speed values-----------

    Widget buildSpeed_gauges(){
      return Container(
        color: const Color.fromRGBO(23, 156, 125, 0.5),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            const Text('Speed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(
                height: 200,
                child:
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 100, labelOffset: 10,
                      axisLineStyle: const AxisLineStyle(
                          thicknessUnit: GaugeSizeUnit.factor,thickness: 0.1),
                      majorTickStyle: const MajorTickStyle(length: 12,thickness: 3,color: Colors.black),
                      minorTickStyle: const MinorTickStyle(length: 7,thickness: 1,color: Colors.black),
                      axisLabelStyle: const GaugeTextStyle(color: Colors.black,fontSize: 13 ),
                      ranges: <GaugeRange>[
                        GaugeRange(startValue: 0, endValue: 100, sizeUnit: GaugeSizeUnit.factor, startWidth: 0.1, endWidth: 0.1,
                          gradient: const SweepGradient(
                              colors: <Color>[Colors.white54,Colors.white54],
                              stops: <double>[0.0,1]
                          ),
                        ),
                      ],
                      pointers: <GaugePointer>[RangePointer(value: _speed, width: 0.1, sizeUnit: GaugeSizeUnit.factor,
                        gradient: const SweepGradient(colors: <Color>[Colors.red, Color(0xFFC41A3B)], stops: <double>[0.25, 0.75]),

                       ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(widget: Column(
                          children: <Widget>[
                            Text(_speed.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 5,),
                            const Text('rpm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                          ],
                        ), angle: 90, positionFactor: 1.5, )],
                    ),
                  ],
                )
            ),
          ],
        ),
      );
    }


//-------------Functions used to modify the layout---------------

    // For instance, if the device is currently in portrait mode, it will invoke the buildRow_gauges() function.
    // This function arranges the two Radial Gauge Chart vertically in a column.

    Widget buildRow_gauges(){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child:buildPWM_gauges()),
            Expanded(child:buildSpeed_gauges()),
          ],
        ),
      );
    }

    Widget buildColumn_gauges(){
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(child: buildPWM_gauges()),
          Container(child: buildSpeed_gauges()),
        ],
      );
    }

//------------Handling of the chart layout is complete-------------------------


//--------------Displaying all the information related to Motor2, It includes five main container--------

    return Column(
      children: <Widget>[

        //-----------The first container displays the status of the connection with the MQTT broker--------

        Container(
          height:80,
          color: Colors.blue[100],
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular(50.0)),
                  alignment: Alignment.center,
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
                    alignment: Alignment.center,
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

        //-----------The second container displays the status of two parameters of Motor1 (Systemzustand, Test läuft)",
        // it uses function _buildStatCard() to design the layout-------

        Container(
          height: 80,
          color: const Color.fromRGBO(23, 156, 125, 0.5),
          child: Row(
            children: <Widget>[
              _buildStatCard('Systemzustand', 'ON / OFF',  _emergency_switch?Colors.green:Colors.red),
              _buildStatCard('Test läuft', 'ON / OFF',  _is_testing?Colors.green:Colors.red),
            ],
          ),
        ),

        //-----------The third container displays the status of two parameters of Motor1 (Home Position, Drehrichtung)"
        // it uses function _buildStatCard() and _buildStatCard_direction to design the layout---

        Container(
          height: 80,
          color: const Color.fromRGBO(23, 156, 125, 0.5),
          child: Row(
            children: <Widget>[
              _buildStatCard('Home Position', 'ON / OFF',  _is_homing?Colors.green:Colors.red),
              _buildStatCard_direction('Drehrichtung', '',  _direction=='VorwÃ¤rts'?const IconData(0xe540, fontFamily: 'MaterialIcons'):const IconData(0xe53f, fontFamily: 'MaterialIcons')),
            ],
          ),
        ),

        const SizedBox(height: 10,),

        //----------The fourth container displays two gauge charts, which may be arranged in a column or row, depending on the value of isPortrait.----------

        isPortrait ? buildColumn_gauges() : buildRow_gauges(),

        //----------The fifth container displays two Time Series Line Charts, which may be arranged in a column or row, depending on the value of isPortrait.----------

        isPortrait ? buildColumn() : buildRow(),

        const SizedBox(height: 50,),

      ],
    );
  }
  //---- Widget build(BuildContext context) ends. The main structure of the layout is complete---------------



// The function updateDataSource() updates the data source for the chart every second,
  //The updateDataSource() function is adding new data to chartData, which is a list of LiveData objects.
  // If less than 8 seconds have passed, it simply adds new data to chartData
  // After 8 seconds, it also removes the oldest data point to maintain a steady flow of data on the chart

  int t = 0;
  void updateDataSource(Timer timer) {
    if (t < 8) {
      chartData.add(LiveData(t++, _speed, _pwm_frequency, DateTime.now()));
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

  // The function getChartData() initializes the chart data with one data point with default values

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 0, 0, DateTime.now())
    ];
  }

//------This function is  responsible for the layout of the three parameters (Systemzustand,Test läuft, Home Position)-----

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

//------This function is  responsible for the layout of the  parameters (Drehrichtung)-------

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

//------- Define the LiveData class to hold each data point for the chart------

class LiveData {
  LiveData(this.t, this.speed, this.signal, this.time);
  final int t;
  final num speed;
  final num signal;
  final DateTime time;

}