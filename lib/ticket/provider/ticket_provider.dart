import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:fitend_member/ticket/repository/ticket_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ticketProvider =
    StateNotifierProvider<TicketStateNotifier, TicketDetailListModelBase?>(
        (ref) {
  final repository = ref.watch(ticketRepositoryProvider);

  return TicketStateNotifier(repository: repository);
});

class TicketStateNotifier extends StateNotifier<TicketDetailListModelBase?> {
  final TicketsRepository repository;

  TicketStateNotifier({
    required this.repository,
  }) : super(TicketDetailListModelLoading()) {
    getTickets();
  }

  Future<void> getTickets() async {
    try {
      state = TicketDetailListModelLoading();

      final model = await repository.getProducts();

      state = model.copyWith();
    } catch (e) {
      state = TicketDetailListModelError(message: e.toString());
    }
  }
}
