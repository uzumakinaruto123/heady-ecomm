// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
    json['category_id'] as int,
    json['category_name'] as String,
    json['name'] as String,
    json['id'] as int,
    json['date_added'] as String,
    json['variants'] as List,
    json['tax'],
    view_count: json['view_count'] as int,
    order_count: json['order_count'] as int,
    shares: json['shares'] as int,
  );
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'name': instance.name,
      'date_added': instance.date_added,
      'id': instance.id,
      'variants': instance.variants,
      'tax': instance.tax,
      'category_id': instance.category_id,
      'category_name': instance.category_name,
      'view_count': instance.view_count,
      'order_count': instance.order_count,
      'shares': instance.shares,
    };
