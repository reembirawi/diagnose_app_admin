import 'package:diagnose_app/models/individual_bar.dart';

class BarData {
  final int sunAmount;
  final int monAmount;
  final int tueAmount;
  final int wedAmount;
  final int thurAmount;
  final int friAmount;
  final int satAmount;

  BarData({
    required this.sunAmount,
    required this.monAmount,
    required this.tueAmount,
    required this.wedAmount,
    required this.thurAmount,
    required this.friAmount,
    required this.satAmount,
  });

  List<IndividualBar> barData = [];

  // initialize bar data
  void initializeBarData() {
    barData = [
      // sun
      IndividualBar(x: 0, y: sunAmount),
      // mon
      IndividualBar(x: 1, y: monAmount),
      // tue
      IndividualBar(x: 2, y: tueAmount),
      // wed
      IndividualBar(x: 3, y: wedAmount),
      // thur
      IndividualBar(x: 4, y: thurAmount),
      // fri
      IndividualBar(x: 5, y: friAmount),
      // sat
      IndividualBar(x: 6, y: satAmount),
    ];
  }
}
