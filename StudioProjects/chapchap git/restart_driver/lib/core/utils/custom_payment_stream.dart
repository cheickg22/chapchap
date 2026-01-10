import 'package:rxdart/rxdart.dart';

class RideRepository {
  final BehaviorSubject<bool> _paymentPaidController =
      BehaviorSubject.seeded(false);

  final BehaviorSubject<String> _paymentChangeController =
      BehaviorSubject.seeded('');

  Stream<bool> get paymentPaidStream => _paymentPaidController.stream;
  Stream<String> get paymentChangeStream => _paymentChangeController.stream;

  Stream<RidePaymentStatus> get paymentStatusStream =>
      Rx.combineLatest2<bool, String, RidePaymentStatus>(
        _paymentPaidController.stream,
        _paymentChangeController.stream,
        (isPaid, changedPayment) =>
            RidePaymentStatus(isPaid: isPaid, changedPayment: changedPayment),
      ).asBroadcastStream();

  void updatePaymentReceived(bool value) {
    _paymentPaidController.add(value);
  }

  void updatePaymentChange(String value) {
    _paymentChangeController.add(value);
  }

  void dispose() {
    _paymentPaidController.close();
    _paymentChangeController.close();
  }
}

class RidePaymentStatus {
  final bool isPaid;
  final String changedPayment;

  RidePaymentStatus({required this.isPaid, required this.changedPayment});
}
