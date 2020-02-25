import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';

import 'package:openjmu_lite/constants/constants.dart';

@FFRoute(name: 'openjmu-lite://scan-qrcode', routeName: '扫描二维码')
class ScanQrCodePage extends StatefulWidget {
  @override
  _ScanQrCodePageState createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

  Widget backdrop({double width, double height, Widget child}) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Color(0x99000000),
        child: child ?? null,
      );

  Future<void> onScan(BuildContext context, String data) async {
    if (data == null) {
      showCenterErrorToast('没有识别到二维码~换一张试试');
      return;
    }
    if (API.urlReg.stringMatch(data) != null) {
      Navigator.of(context).pop();
      unawaited(API.launchWeb(url: '$data'));
    } else {
      final bool needCopy = await ConfirmationDialog.show(
        context,
        title: '扫码结果',
        content: '$data',
        showConfirm: true,
        confirmLabel: '复制',
        cancelLabel: '返回',
      );
      if (needCopy) {
        unawaited(Clipboard.setData(ClipboardData(text: '$data')));
      }
      _key.currentState.startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const FixedAppBar(title: Text('扫描二维码')),
          Expanded(
            child: QrcodeReaderView(
              key: _key,
              onScan: (String data) => onScan(context, data),
            ),
          ),
        ],
      ),
    );
  }
}
