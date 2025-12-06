import 'package:iconnect/features/products/domain/entities/product_entity.dart';

class SeriesModel {
  final ModelName? model;
  final bool loading;
  final List<ProductEntity> products;

  SeriesModel({this.model, this.loading = false, this.products = const []});

  SeriesModel copyWith({
    ModelName? model,
    List<ProductEntity>? products,
    bool? loading,
  }) {
    return SeriesModel(
      model: model ?? this.model,
      products: products ?? this.products,
      loading: loading ?? this.loading,
    );
  }

  SeriesModel initial() {
    return SeriesModel(loading: false, products: const []);
  }
}

enum ModelName { iPhone17, samsung, google }
