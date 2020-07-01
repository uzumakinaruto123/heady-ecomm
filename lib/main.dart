import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heady_ecommerce/bloc/shop_bloc.dart';
import 'package:heady_ecommerce/data/shop_repo.dart';
import 'package:heady_ecommerce/model/product.dart';
import 'package:intl/intl.dart';

import 'category_drawer.dart';
import 'filter_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (BuildContext context) => ShopBloc(ShopRepository()),
        child: SafeArea(child: MyHomePage()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ShopBloc shopBloc = null;

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    shopBloc = BlocProvider.of<ShopBloc>(context);
    shopBloc.add(FetchNetworkData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shopBloc.repository.appTitle), actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ]),
      drawer: Drawer(child: CategoryDrawer(shopBloc)),
      endDrawer: Drawer(child: FilterDrawer(shopBloc)),
      body: BlocListener<ShopBloc, ShopState>(
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
            if (state is ShopInitial) {
              return buildInitialInput();
            } else if (state is ProductsLoading) {
              return buildLoading();
            } else if (state is ProductsLoaded) {
              products = state.products;
              return Container(
                  child: buildColumnWithData(context, state.products));
            } else if (state is ProductsError) {
              return buildError(msg: 'Something went wrong. Check your network connection!', shopBloc: shopBloc);
            } else {
              return Container(child: buildColumnWithData(context, products));
            }
          },
        ),
      ),
    );
  }

  Widget buildColumnWithData(BuildContext context, List<Product> products) {
    return products.isNotEmpty
        ? ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          item.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(item.category_name.trim(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: getVariantList(item.variants),
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          getViewWidget('Views', getCount(item.view_count)),
                          getViewWidget('Orders', getCount(item.order_count)),
                          getViewWidget('Shares', getCount(item.shares)),
                        ],
                      )
                    ],
                  ),
                ),
                // title: Text(item.name),
                // subtitle: Text(item.category_name),
              );
            },
          )
        : Center(child: Text('No Products found!'));
  }

  ListView getVariantList(variants) {
    return ListView.separated(
      itemCount: variants.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(
        color: Colors.black26,
      ),
      itemBuilder: (context, index) {
        final item = variants[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 1,
                  child: Text(
                    item['color'] != null ? item['color'].toString() : '-',
                    textAlign: TextAlign.start,
                  )),
              Expanded(
                  flex: 1,
                  child: Text(
                    item['size'] != null ? item['size'].toString() : '-',
                    textAlign: TextAlign.start,
                  )),
              Expanded(
                  flex: 1,
                  child: Text(
                    item['price'] != null
                        ? item['price'].toString() + ' /-'
                        : '-',
                    textAlign: TextAlign.start,
                  )),
              GestureDetector(
                onTap: () {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product added to cart!'),
                    ),
                  );
                },
                child: Icon(
                  Icons.add,
                  color: Colors.black54,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Column getViewWidget(label, value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: Colors.black54),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget buildInitialInput() {
    return Center(
      child: Text('No Data!'),
    );
  }

  Widget buildError({ String msg, ShopBloc shopBloc }) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(msg != null? msg:'No Data!'),
            RaisedButton(onPressed: () {
              shopBloc.add(FetchNetworkData());
            },
            child: Text('Retry'),)
          ],
        ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  getCount(number) {
    if (number == null || number == 0) {
      return '-';
    }

    return NumberFormat.compactCurrency(
      decimalDigits: 1,
      symbol:
          '', // if you want to add currency symbol then pass that in this else leave it empty.
    ).format(number);
  }
}
