import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'web-storage-helper.dart';



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

  List logs = ['kfam','faweas'];
  String host = 'ws://' + '172.20.0.3:3000';
  WebSocketChannel channel;
  int cnt = 1;
  LocalStorage storage;

  @override
  void initState() {
    cnt = 1;
    connect();
    storage = LocalStorage();
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
          children: logs.reversed.map((val) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('${logs.indexOf(val)+1}:   $val', style: TextStyle(fontSize: 20),),
          )).toList(),
        ),
      ),
    );
  }


  connect () {
    var deviceId = "FAKE_DEVICE_ID";
    channel = HtmlWebSocketChannel.connect(this.host);//, headers: { "device-id": deviceId }
    channel.stream.listen(onData, onError: onError, onDone: onDone);
  }


  onError(err) {
    print ('Connection error: ' + err.toString());
  }


  onDone() {
    print ('connection went down');
    var future = new Future.delayed(const Duration(milliseconds: 1000), connect);
    return future;
  }


  void onData(compressed) {
    print ('connection on data');
/*
    Map <String, Function> txnHandlers = {
      'error': (data) => TxnError().handler(data),
      'init': (data) => TxnInit().handler(data),
      'reinit_ok': (data) => TxnReinitOk().handler(data),
      'login_ok': (data) => TxnLoginOk.handler(data),
    };
*/
    //List<int> buf = new ZLibDecoder().decodeBytes(compressed);

    //String data = utf8.decode(buf);
    //print ('server msg: ' + compressed);
    var obj = jsonDecode (compressed);
    print('DATA::' + obj.toString());
    storage.save((storage.getSize()+1).toString(), obj.toString());
    setState(() {
      logs.add(obj.toString());
    });
//    Config.msgBloc.dispatch(ReceivedMsg(Msg.received(
//      obj['id'],
//      obj['timestamp'],
//      obj['type'],
//      obj['body']
//    )));
  }
}
