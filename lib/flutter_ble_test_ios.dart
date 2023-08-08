import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];

  void startScanning() {
    final scanSubscription = _flutterReactiveBle.scanForDevices(
      withServices: [],
    ).listen((device) {
      setState(() {
        devices.add(device);
      });
    });

    // Cancel the scan after a certain time, if desired
    Future.delayed(Duration(seconds: 10), () {
      scanSubscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: BluetoothList(devices),
      floatingActionButton: FloatingActionButton(
        onPressed: startScanning,
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }
}

class BluetoothList extends StatelessWidget {
  final List<DiscoveredDevice> devices;
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();


  BluetoothList(this.devices);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async{
            try {
              _flutterReactiveBle.connectToDevice(
                id: devices[index].id,
              ).listen((event) {
                print('event of device in ios ${event.connectionState}');
              });

            } catch (e) {
              print('Error connecting to device: $e');
            }
          },
          child: ListTile(
            title: Text(devices[index].name),
            subtitle: Text(devices[index].id),
          ),
        );
      },
    );
  }
}
