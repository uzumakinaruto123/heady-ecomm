
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:heady_ecommerce/model/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category extends Equatable {

  final String name;
  final int id;
  List<Product> products;
  List<dynamic> child_categories;

  Category(this.name,  this.id,  this.products,  this.child_categories);

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    name,
    products,
    child_categories
  ];

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

}