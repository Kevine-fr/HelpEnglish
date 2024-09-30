import 'package:flutter/material.dart';
class DataPayment extends StatefulWidget {
  const DataPayment({super.key});

  @override
  State<DataPayment> createState() => _DataPaymentState();
}

class _DataPaymentState extends State<DataPayment> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Aucun payement n'a été effectué !"),
    );
  }
}
