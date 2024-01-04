import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/ticket/model/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'products_repository.g.dart';

final productRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ProductsRepository(dio);
});

@RestApi()
abstract class ProductsRepository {
  factory ProductsRepository(Dio dio) = _ProductsRepository;

  @GET('/products')
  Future<ProductsModel> getProducts();
}
