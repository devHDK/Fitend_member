import 'package:fitend_member/payment/model/payment_confirm_req_model.dart';
import 'package:fitend_member/payment/repository/payment_repository.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentProvider = StateNotifierProvider.autoDispose<PaymentStateNotifier,
    ActiveTicketResponseBase?>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);

  return PaymentStateNotifier(repository: repository);
});

class PaymentStateNotifier extends StateNotifier<ActiveTicketResponseBase?> {
  final PaymentsRepository repository;

  PaymentStateNotifier({
    required this.repository,
  }) : super(null);

  Future<ActiveTicketResponse?> postConfirmPayments(
      {required PaymentConfirmReqModel reqModel}) async {
    try {
      if (state is ActiveTicketResponseLoading) {
        return null;
      }

      state = ActiveTicketResponseLoading();

      final resp = await repository.postConfirmPayment(reqModel);

      // state = resp;

      return resp;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePayments({required int ticketId}) async {
    try {
      await repository.deletePayment(ticketId: ticketId);
    } catch (e) {
      rethrow;
    }
  }
}
