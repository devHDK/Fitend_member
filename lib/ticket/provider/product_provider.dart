import 'package:fitend_member/ticket/model/product_model.dart';
import 'package:fitend_member/ticket/repository/products_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productProvider =
    StateNotifierProvider<ProductStateNotifier, ProductsModelBase?>((ref) {
  final repository = ref.watch(productRepositoryProvider);

  return ProductStateNotifier(repository: repository);
});

class ProductStateNotifier extends StateNotifier<ProductsModelBase?> {
  final ProductsRepository repository;

  ProductStateNotifier({
    required this.repository,
  }) : super(null);

  Future<void> getProducts() async {
    try {
      if (state is ProductsModelLoading) {
        return;
      }

      state = ProductsModelLoading();

      final model = await repository.getProducts();

      state = model.copyWith(selectedIndex: 0);
    } catch (e) {
      state = ProductsModelError(message: e.toString());
    }
  }

  void updateSelectedProduct(int index) {
    final pstate = state as ProductsModel;

    state = pstate.copyWith(selectedIndex: index);
  }
}
