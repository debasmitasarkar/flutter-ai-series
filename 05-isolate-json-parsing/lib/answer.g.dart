// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductAnswer _$ProductAnswerFromJson(Map<String, dynamic> json) =>
    _ProductAnswer(
      query: json['query'] as String,
      summary: json['summary'] as String,
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductAnswerToJson(_ProductAnswer instance) =>
    <String, dynamic>{
      'query': instance.query,
      'summary': instance.summary,
      'products': instance.products,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  specs: (json['specs'] as List<dynamic>)
      .map((e) => Spec.fromJson(e as Map<String, dynamic>))
      .toList(),
  why: json['why'] as String,
  score: (json['score'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'currency': instance.currency,
  'tags': instance.tags,
  'specs': instance.specs,
  'why': instance.why,
  'score': instance.score,
};

_Spec _$SpecFromJson(Map<String, dynamic> json) =>
    _Spec(label: json['label'] as String, value: json['value'] as String);

Map<String, dynamic> _$SpecToJson(_Spec instance) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
};
