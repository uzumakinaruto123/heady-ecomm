import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heady_ecommerce/bloc/shop_bloc.dart';
import 'package:heady_ecommerce/data/shop_repo.dart';

class FilterDrawer extends StatefulWidget {
  final ShopBloc shopBloc;
  FilterDrawer(this.shopBloc);

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  @override
  void initState() {
    super.initState();
    // widget.shopBloc = BlocProvider.of<ShopBloc>(context);
    widget.shopBloc.add(PopulateCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(title: Text('Group By')),
          addGroups(),
          ListTile(title: Text('Sort By')),
          addOrders(),
          RaisedButton(onPressed: () {
            setState(() {
              widget.shopBloc.repository.groupBy = Group.All;
              widget.shopBloc.repository.orderBy = Order.None;
              widget.shopBloc.add(ChangeCategory(widget.shopBloc.repository.activeCategory));
            });
          }, child: Text('Clear Filters'),),
        ],
      ),
    );
  }

  ListView addGroups() {

    List groups = [ {
      'name': 'Most Viewed',
      'value': Group.MostViewed
    },{
      'name': 'Most Shared',
      'value': Group.MostShared
    },{
      'name': 'Most Ordered',
      'value': Group.MostOrdered
    }];

    return ListView.builder(
      itemCount: groups.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = groups[index];
        return RadioListTile(
          value: item['value'],
          groupValue: widget.shopBloc.repository.groupBy,
          onChanged: (ind) => setState(() {
            widget.shopBloc.add(ChangeGroup(ind));
          }),
          title: Text(item['name']),
        );
      },
    );
  }

    ListView addOrders() {

    List orders = [ {
      'name': 'Ascending',
      'value': Order.Ascending
    }, {
      'name': 'Descending',
      'value': Order.Descending
    }];

    return ListView.builder(
      itemCount: orders.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = orders[index];
        return RadioListTile(
          value: item['value'],
          groupValue: widget.shopBloc.repository.orderBy,
          onChanged: (ind) => setState(() {
            widget.shopBloc.add(ChangeOrder(ind));
          }),
          title: Text(item['name']),
        );
      },
    );
  }

  onCategoryClick(category) {
    // print(category.child_categories[0].child_categories);
    widget.shopBloc.add(ChangeCategory(category.id));
    Navigator.of(context).pop();
  }
}
