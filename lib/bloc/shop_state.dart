part of 'shop_bloc.dart';

abstract class ShopState extends Equatable {
  const ShopState();
}

class ShopInitial extends ShopState {
  const ShopInitial();
  @override
  List<Object> get props => [];
}

class ProductsLoading extends ShopState {
  const ProductsLoading();
  @override
  List<Object> get props => [];
}

class ProductsLoaded extends ShopState {
  final List<Product> products;
  const ProductsLoaded(this.products);
  @override
  List<Object> get props => [products];
}

class CategoriesLoaded extends ShopState {
  final List<dynamic> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class ProductsError extends ShopState {
  final String message;
  const ProductsError(this.message);
  @override
  List<Object> get props => [message];
}
