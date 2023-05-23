import 'package:flutter/widgets.dart';

class PaginationUtils {
  static paginate({
    required ScrollController controller,
  }) {
    if (controller.offset > controller.position.maxScrollExtent - 300) {}
  }
}
