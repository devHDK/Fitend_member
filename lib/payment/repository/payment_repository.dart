import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/payment/model/payment_confirm_req_model.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'payment_repository.g.dart';

final paymentRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return PaymentsRepository(dio);
});

@RestApi()
abstract class PaymentsRepository {
  factory PaymentsRepository(Dio dio) = _PaymentsRepository;

  @POST('/payments')
  @Headers({
    'accessToken': 'true',
  })
  Future<ActiveTicketResponse> postConfirmPayment(
    @Body() PaymentConfirmReqModel reqModel,
  );

  @DELETE('/payments/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deletePayment({
    @Path('id') required int ticketId,
  });
}
