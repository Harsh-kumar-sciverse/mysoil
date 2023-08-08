import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothServices{
  static Future<bool?> getBluetoothStatus() async {
    bool? status = await FlutterBluetoothSerial.instance.isEnabled;
    return status;
  }
  static Future<void> enableBluetooth() async {
    /// enable bluetooth
    await FlutterBluetoothSerial.instance
        .requestEnable();
  }
  static Future<void> disableBluetooth() async {
    /// enable bluetooth
    await FlutterBluetoothSerial.instance
        .requestDisable();
  }
}