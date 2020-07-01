part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
}

class FetchNetworkData extends ShopEvent {
  final bool forceRefresh;
  const FetchNetworkData({ this.forceRefresh });
  @override
  List<Object> get props => [forceRefresh];
}

class PopulateCategories extends ShopEvent {
  const PopulateCategories();
  @override
  List<Object> get props => [];
}

class ChangeCategory extends ShopEvent {
  final int id;

  const ChangeCategory(this.id);

  @override
  List<Object> get props => [id];
}

class ChangeOrder extends ShopEvent {
  final Order orderBy;

  const ChangeOrder(this.orderBy);

  @override
  List<Object> get props => [orderBy];
}

class ChangeGroup extends ShopEvent {
  final Group groupBy;

  const ChangeGroup(this.groupBy);

  @override
  List<Object> get props => [groupBy];
}
