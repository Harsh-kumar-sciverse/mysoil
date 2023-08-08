import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
  String connectedToDeviceName='';

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
    getStreamOfBluetooth();
    getListOfBluetoothDevices();
    BluetoothServices.getBluetoothStatus().then((value) {
      setState(() {
        bluetoothEnabled=value??false;
      });
    });
  }
  final flutterReactiveBle = FlutterReactiveBle();
  void connect(){

  }
  List<BluetoothDevice> devices=[];

  getListOfBluetoothDevices(){

      FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
        print('bluetooth event ${event.device}');
        devices.add(event.device);
        setState(() {

        });
        // setState(() {
        //   connectedToDeviceName='';
        // });
      });


  }

  getStreamOfBluetooth(){
    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      print('event of bluetooth status ${event.isEnabled}');
      if(event.isEnabled==false){
        isConnected=false;
       // bluetoothEnabled=true;
        setState(() {

        });
      }

    });
  }




  @override
  Widget build(BuildContext context) {
    print('devices ${devices.length}');
    return Scaffold(
      floatingActionButton:isConnected? FloatingActionButton(onPressed: (){
        getListOfBluetoothDevices();
      },
      child:const Icon(Icons.refresh)):Container(),
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
            const SizedBox(height: 20,),
          isConnected?  ElevatedButton(onPressed: null, child: Text('Connected to $connectedToDeviceName')):
          // ElevatedButton(onPressed: () async{
          //   if(Platform.isIOS){
          //     flutterReactiveBle.scanForDevices(  withServices: []).listen((device) {
          //       //code for handling results
          //       print('device ${device.id}');
          //     });
          //
          //
          //   }else{
          //     try{
          //       BluetoothConnection.toAddress('08:B6:1F:6F:9F:AA').then((value) {
          //         print('val ${value.isConnected}');
          //         if(value.isConnected==true){
          //           setState(() {
          //             isConnected=true;
          //           });
          //           value.output.add(ascii.encode("connected"));
          //           value.input?.listen((Uint8List data) {
          //             print('Data incoming: ${ascii.decode(data)}');
          //
          //             ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(ascii.decode(data))));
          //           }).onDone(() {
          //             setState(() {
          //               isConnected=false;
          //             });
          //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection removed.')));
          //           });
          //
          //
          //         }else{
          //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to connect')));
          //         }
          //
          //       });
          //     }catch(e){
          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          //     }
          //   }
          //
          //
          //
          //
          //   }, child:const Text('Connect')),
            const SizedBox(height: 20,),
           // ElevatedButton(onPressed: (){}, child:const Text('Receive')),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                  itemBuilder: (context,index){
                return InkWell(
                  onTap: (){
                    try{
                      BluetoothConnection.toAddress(devices[index].address).then((value) {
                        print('val ${value.isConnected}');
                        if(value.isConnected==true){
                          setState(() {
                            isConnected=true;
                            connectedToDeviceName=devices[index].name??'';
                            devices=[];
                          });
                          value.output.add(ascii.encode("connected"));
                          value.input?.listen((Uint8List data) {
                            print('Data incoming: ${ascii.decode(data)}');

                            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(ascii.decode(data))));
                          }).onDone(() {
                            setState(() {
                              isConnected=false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection removed.')));
                          });


                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to connect')));
                        }

                      });
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: ListTile(
                    title: Text('${devices[index].name??''} ${devices[index].isConnected==true?' Connected':''}'),
                    subtitle: Text('${devices[index].address}'),

                  ),
                );
              }),
            )

          ],
        ),
      ),

    );

  }
}
