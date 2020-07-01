
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {

  final String name;
  final String date_added;
  final int id;
  final List<dynamic> variants;
  final dynamic tax;
  int category_id;
  String category_name;

  int view_count;
  int order_count;
  int shares;

  Product(this.category_id, 
  this.category_name, 
  this.name,  this.id,  
  this.date_added,  
  this.variants,  
  this.tax, { this.view_count, this.order_count, this.shares });

  @override
  List<Object> get props => [
    id,
    name,
    date_added,
    variants,
    tax
  ];

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

}