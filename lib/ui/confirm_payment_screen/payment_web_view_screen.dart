
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../resource/app_colors.dart';


class PaymentWebViewScreen extends StatefulWidget {
  String url;
  PaymentWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          "Payment",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
              cacheEnabled: true,
              useShouldInterceptRequest: true
          ),
          onReceivedError: (controller, request, error) {
            log('error: ${error.toString()}');
          },
          onLoadResource: (controller, resource) {
            log('onLoadResource : ${resource}');
          },
          onLoadStart: (controller, url) {
            log('start url: ${url.toString()}');
          },
          onReceivedHttpError: (controller, request, error) {
            log('http error: ${error.toString()} and req is $request');
          },
          onLoadStop: (controller, url)async {
            log('onLoadStop called: ${url.toString()}');
            // log('check: ${imgBaseurl}payment-success');
          },
          onWebViewCreated: (webviewcontroller) {
            _controller = webviewcontroller;

            log('onWebViewCreated: }');

            kIsWeb
                ? {}
                : _controller.addJavaScriptHandler(
              handlerName: 'PaymentSuccess',
              callback: (args) {
                log('loaded PaymentSuccess: ${args.toString()}');


              },
            );
            kIsWeb
                ? {}
                : _controller.addJavaScriptHandler(
              handlerName: 'PaymentFailed',
              callback: (args) {
                log('loaded PaymentFailed: ${args.toString()}');

              },
            );
          },
        ),
      ),
    );
  }


}
