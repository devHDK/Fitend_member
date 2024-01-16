import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'ticket_repository.g.dart';

final ticketRepositoryProvider = Provider<TicketsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return TicketsRepository(dio);
});

@RestApi()
abstract class TicketsRepository {
  factory TicketsRepository(Dio dio) = _TicketsRepository;

  @GET('/tickets')
  @Headers({
    'accessToken': 'true',
  })
  Future<TicketDetailListModel> getProducts();
}
