import 'package:freezed_annotation/freezed_annotation.dart';

part 'answer.freezed.dart';
part 'answer.g.dart';

@freezed
abstract class ProductAnswer with _$ProductAnswer {
  const factory ProductAnswer({
    required String query,
    required String summary,
    required List<Product> products,
  }) = _ProductAnswer;

  factory ProductAnswer.fromJson(Map<String, dynamic> json) =>
      _$ProductAnswerFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    required String currency,
    required List<String> tags,
    required List<Spec> specs,
    required String why,
    @Default(0) double score,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class Spec with _$Spec {
  const factory Spec({required String label, required String value}) = _Spec;

  factory Spec.fromJson(Map<String, dynamic> json) => _$SpecFromJson(json);
}
