import 'package:dio/dio.dart';
import 'package:fitend_member/payment/model/payment_confirm_req_model.dart';
import 'package:fitend_member/payment/repository/payment_repository.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentProvider = StateNotifierProvider.autoDispose<PaymnetStateNotifier,
    ActiveTicketResponseBase?>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);

  return PaymnetStateNotifier(repository: repository);
});

class PaymnetStateNotifier extends StateNotifier<ActiveTicketResponseBase?> {
  final PaymentsRepository repository;

  PaymnetStateNotifier({
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

      state = resp;

      return resp;
    } catch (e) {
      if (e is DioException) {
        state = ActiveTicketResponseError(
          error: e.toString(),
          statusCode: e.response!.statusCode!,
        );
      }
    }
    return null;
  }

  Future<void> deletePayments({required int ticketId}) async {
    try {
      await repository.deletePayment(ticketId: ticketId);
    } catch (e) {
      if (e is DioException) {
        state = ActiveTicketResponseError(
          error: e.toString(),
          statusCode: e.response!.statusCode!,
        );
      }
    }
    return;
  }
}
