import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'web-storage-helper.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Logs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Camera Logs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List logs = [];
  String host = 'ws://' + '192.168.1.217:80';
  WebSocketChannel channel;
  LocalStorage storage;

  @override
  void initState() {
    print('here');
    connect();
    storage = LocalStorage();
    channel.sink.add(jsonEncode({
      'sessionId': '1',
      'type': 'events',
      'data': {
        'txn': 'start_events',
        'camera_id': '123'
      },
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(8),
          children: logs.reversed.map((val) {
            DateTime attTime = DateTime.parse(val['timestamp']);
            attTime = attTime.toLocal();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('${logs.indexOf(val)+1}:   ${val['name']} , Timestamp: ${attTime.toString()}', style: TextStyle(fontSize: 20),),
            );
          }).toList(),
        ),
      ),
    );
  }

  connect () {
    var deviceId = "FAKE_DEVICE_ID";
    channel = HtmlWebSocketChannel.connect(this.host);//, headers: { "device-id": deviceId }
    channel.stream.listen(onData, onError: onError, onDone: onDone);
    channel.sink.add(jsonEncode({
      'sessionId': '1',
      'type': 'conn'
    }));
  }


  onError(err) {
    print ('Connection error: ' + err.toString());
  }


  onDone() {
    print ('connection went down');
    var future = new Future.delayed(const Duration(milliseconds: 1000), connect);
    return future;
  }


  onData(compressed) {
    print ('connection on data');
    var buf = new ZLibDecoder().decodeBytes(compressed);
    String data = utf8.decode(buf);
    print ('server msg: ' + data);

    var obj = jsonDecode (data);
    print('DATA::' + obj.toString());
    storage.save((storage.getSize()+1).toString(), obj.toString());
    setState(() {
      if(obj['txn'] == 'events') {
        logs.add(obj['data']);
      }
    });
  }

  @override
  void dispose() {
    channel.sink.add(jsonEncode({
      'sessionId': '1',
      'type': 'events',
      'data': {
        'txn': 'stop_events',
        'camera_id': '123'
      },
    }));
    print('dispose called');
    super.dispose();
  }
}
