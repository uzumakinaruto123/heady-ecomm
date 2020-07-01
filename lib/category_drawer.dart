import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heady_ecommerce/bloc/shop_bloc.dart';

class CategoryDrawer extends StatefulWidget {
  final ShopBloc shopBloc;
  CategoryDrawer(this.shopBloc);

  @override
  _CategoryDrawerState createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  @override
  void initState() {
    super.initState();
    // widget.shopBloc = BlocProvider.of<ShopBloc>(context);
    widget.shopBloc.add(PopulateCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocListener<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ProductsError) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            // print(state);
            if (state is CategoriesLoaded && state.categories.isNotEmpty) {
              return Container(child: addMenu(state.categories));
            } else {
              return Center(child: Text('No Categories found!'));
            }
          },
        ),
      ),
    );
  }

  ListView addMenu(categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        return item.child_categories.length > 0
            ? ExpansionTile(
                title: Text(item.name.trim()),
                children: [
                  for (var child in item.child_categories)
                    child.child_categories.length == 0
                        ? ListTile(
                            title: Text(child.name.trim()),
                            onTap: () => onCategoryClick(child),
                          )
                        : ExpansionTile(
                            title: Text(child.name.trim()),
                            children: [
                              for (var root in child.child_categories) ListTile(
                                        title: Text(root.name.trim()),
                                        onTap: () => onCategoryClick(root),
                                      )
                            ],
                          )
                ],
              )
            : ListTile(
                title: Text(item.name.trim()),
                onTap: () => onCategoryClick(item),
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
