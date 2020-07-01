import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:heady_ecommerce/data/shop_repo.dart';
import 'package:heady_ecommerce/model/product.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository repository;
  ShopBloc(this.repository);

  @override
  ShopState get initialState => ShopInitial();

  @override
  Stream<ShopState> mapEventToState(
    ShopEvent event,
  ) async* {

    yield ProductsLoading();

    if (event is FetchNetworkData) {
      try {
        final products = await repository.fetchData();
        yield ProductsLoaded(products);
      } on NetworkError {
        yield ProductsError("Couldn't fetch products. Try again later!");
      }
    } else if (event is PopulateCategories) {
        final categories = await repository.getCategories();
        yield CategoriesLoaded(categories);
    } else if (event is ChangeCategory) {
      
      repository.activeCategory = event.id;
      try {
        final products = repository.filterProducts();
        yield ProductsLoaded(products);
      } on NetworkError {
        yield ProductsError("Couldn't fetch products. Try again later!");
      }
    } else if (event is ChangeOrder) {
      
      repository.orderBy = event.orderBy;
      try {
        final products = repository.filterProducts();
        yield ProductsLoaded(products);
      } on NetworkError {
        yield ProductsError("Couldn't fetch products. Try again later!");
      }
    } else if (event is ChangeGroup) {
      repository.groupBy = event.groupBy;
      try {
        final products = repository.filterProducts();
        yield ProductsLoaded(products);
      } on NetworkError {
        yield ProductsError("Couldn't fetch products. Try again later!");
      }
    }
  }
}
