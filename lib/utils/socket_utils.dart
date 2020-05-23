import 'dart:io';
import 'dart:typed_data';

import 'package:openjmu_lite/constants/constants.dart';

class SocketConfig {
  String host;
  int port;

  SocketConfig(this.host, this.port);
}

class SocketUtils {
  static Socket mSocket;
  static Stream<Uint8List> mStream;

  static Future initSocket(SocketConfig config) async {
    try {
      if (mSocket != null) throw ("Socket already inited.");
      return Socket.connect(config.host, config.port).then((Socket socket) {
        socket.setOption(SocketOption.tcpNoDelay, true);
        socket.timeout(const Duration(milliseconds: 5000));
        mSocket = socket;
        mStream = mSocket.asBroadcastStream();
      }).catchError((e) {
        trueDebugPrint("mSocket Error: $e");
      });
    } catch (e) {
      trueDebugPrint("$e");
    }
  }

  static void unInitSocket() {
    mSocket?.destroy();
    mSocket = null;
    mStream = null;
  }
}
