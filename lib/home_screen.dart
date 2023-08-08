import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mysoil/services/bluetooth_services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool bluetoothEnabled=false;
  bool isConnected=false;

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if(await Permission.bluetooth.isDenied){
      Permission.bluetooth.request();
    }
    if(await Permission.bluetoothAdvertise.isDenied){
      Permission.bluetoothAdvertise.request();
    }
    if(await Permission.bluetoothConnect.isDenied){
      Permission.bluetoothConnect.request();
    }
    if(await Permission.bluetoothScan.isDenied){
      Permission.bluetoothScan.request();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BluetoothServices.getBluetoothStatus().then((value) {
      setState(() {
        bluetoothEnabled=value??false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text('My Soil'),),

      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               const Text('Bluetooth'),
                Switch(
                    activeColor: Colors.blueAccent,
                    value: bluetoothEnabled,
                    onChanged: (bool val) async{
                      if(val==false){
                        await   BluetoothServices.disableBluetooth();
                      }else{
                        BluetoothServices.enableBluetooth();
                      }
                      bluetoothEnabled = val;
                      setState(() {

                      });
                    }),
              ],
            ),
            const SizedBox(height: 50,),
          isConnected? const ElevatedButton(onPressed: null, child: Text('Connected')):  ElevatedButton(onPressed: () async{

            try{
              BluetoothConnection.toAddress('08:B6:1F:6F:9F:AA').then((value) {
                print('val ${value.isConnected}');
                if(value.isConnected==true){
                  setState(() {
                    isConnected=true;
                  });
                  value.output.add(ascii.encode("connected"));
                  value.input?.listen((Uint8List data) {
                    print('Data incoming: ${ascii.decode(data)}');

                    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(ascii.decode(data))));
                  }).onDone(() {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection done')));
                  });


                }else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to connect')));
                }

              });
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }


            }, child:const Text('Connect')),
            const SizedBox(height: 20,),
           // ElevatedButton(onPressed: (){}, child:const Text('Receive')),

          ],
        ),
      ),
    );

  }
}
