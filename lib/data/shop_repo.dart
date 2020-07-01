import 'package:connectivity/connectivity.dart';
import 'package:heady_ecommerce/model/category.dart';
import 'package:heady_ecommerce/model/product.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum Group { All, MostShared, MostOrdered, MostViewed }
enum Order { Ascending, Descending, None }

class ShopRepository {
  List<Product> allProducts = [];
  List<Category> allCategories = [];
  List<dynamic> allRankings = [];
  List<dynamic> menu = [];

  Group groupBy = Group.All;
  Order orderBy = Order.None;
  int activeCategory = -1;

  final LocalStorage storage = new LocalStorage('heady_ecomm.json');

  String appTitle = "Heady Ecommerce";

  Future<List<Product>> fetchData({bool forceRefresh}) async {
    try {
      await storage.ready;
      var storageShop = await storage.getItem("shop");
      return await setDetails(storageShop, forceRefresh);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<dynamic>> getCategories() {
    if (allProducts.isNotEmpty && allCategories.isNotEmpty && menu.isEmpty) {
      List<Category> parents =
          allCategories.where((e) => e.child_categories.isNotEmpty).toList();
      List<Category> grand_parent = allCategories
          .where((element) => checkMatch(element.child_categories, parents))
          .toList();
      List<Category> root_category = allCategories
          .where((element) =>
              parents.indexWhere((p) => p.id == element.id) == -1 &&
              grand_parent.indexWhere((p) => p.id == element.id) == -1)
          .toList();
      parents = parents
          .where((element) =>
              grand_parent.indexWhere((p) => p.id == element.id) == -1)
          .toList();

      parents = parents.map((e) {
        e.child_categories = e.child_categories
            .map((ce) => root_category.singleWhere((r) => r.id == ce))
            .toList();
        return e;
      }).toList();

      grand_parent = grand_parent.map((e) {
        e.child_categories = e.child_categories
            .map((ce) => parents.singleWhere((r) => r.id == ce))
            .toList();
        return e;
      }).toList();

      grand_parent.sort((a, b) => a.name.trim().compareTo(b.name.trim()));
      grand_parent.insert(0, Category('All Products', -1, [], []));
      menu = grand_parent;
      return Future.value(menu);
    } else {
      return menu.isNotEmpty ? Future.value(menu) : Future.value([]);
    }
  }

  Future<List<Product>> getProducts({int category_id}) {
    return Future.delayed(Duration(seconds: 1), () {
      return [];
    });
  }

  List<Product> filterProducts() {
    print(groupBy);
    switch (groupBy) {
      case Group.All:
        if (orderBy == Order.None) {
          return allProducts
              .where((element) => (activeCategory > -1
                  ? activeCategory == element.category_id
                  : true))
              .toList();
        } else {
          List<Product> p = allProducts
              .where((element) => (activeCategory > -1
                  ? activeCategory == element.category_id
                  : true))
              .toList();
          p.sort((e1, e2) => e1.name.compareTo(e2.name));
          if (orderBy == Order.Descending) {
            p = new List.from(p.reversed);
          }
          return p;
        }
        break;
      case Group.MostOrdered:
        List<Product> p = allProducts
            .where((element) =>
                element.order_count != null &&
                (activeCategory > -1
                    ? activeCategory == element.category_id
                    : true))
            .toList();
        p.sort((e1, e2) => e1.order_count.compareTo(e2.order_count));
        if (orderBy == Order.Descending) {
          p = new List.from(p.reversed);
        }
        return p;
        break;
      case Group.MostShared:
        List<Product> p = allProducts
            .where((element) =>
                element.shares != null &&
                (activeCategory > -1
                    ? activeCategory == element.category_id
                    : true))
            .toList();
        p.sort((e1, e2) => e1.shares.compareTo(e2.shares));
        if (orderBy == Order.Descending) {
          p = new List.from(p.reversed);
        }
        return p;
        break;
      case Group.MostViewed:
        List<Product> p = allProducts
            .where((element) =>
                element.view_count != null &&
                (activeCategory > -1
                    ? activeCategory == element.category_id
                    : true))
            .toList();
        print(p.length);
        print(activeCategory);
        p.sort((e1, e2) => e1.view_count.compareTo(e2.view_count));
        if (orderBy == Order.Descending) {
          p = new List.from(p.reversed);
        }
        return p;
        break;
      default:
    }
  }

  Future<dynamic> apiRequest() async {
    try {
      var url = "https://stark-spire-93433.herokuapp.com/json";
      var httpClient = http.Client();
      dynamic response = await httpClient
          .get(url, headers: {'Content-Type': 'application/json'});
      dynamic decodedResponse = json.decode(response.body);
      return Future.value(decodedResponse);
    } catch (e) {
      //
      return Future.delayed(e);
    }
  }

  Future<List<Product>> setDetails(storageShop, forceRefresh) async {
    if (storageShop == null || forceRefresh == true) {
      Connectivity connectivity = new Connectivity();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // I am connected to a mobile network.
        throw(NetworkError());
      }

      var shop = await apiRequest();
      for (var i = 0; i < shop['categories'].length; i++) {
        Category e = Category.fromJson(shop['categories'][i]);
        allProducts.addAll(e.products.map((c) => mapProduct(c, e)));
        e.products = [];
        allCategories.add(e);
      }

      allRankings = shop['rankings'];
      setRankings();

      storage.setItem('shop', {
        'categories': allCategories,
        'products': allProducts,
        'rankings': allRankings
      });
      return allProducts;
    } else {
      allCategories = (storageShop['categories'] as List)
          .map((i) => Category.fromJson(i))
          .toList();
      allProducts = (storageShop['products'] as List)
          .map((i) => Product.fromJson(i))
          .toList();
      allRankings = (storageShop['rankings'] as List<dynamic>);
      return allProducts;
    }
  }

  mapProduct(Product c, Category e) {
    c.category_id = e.id;
    c.category_name = e.name;
    return c;
  }

  void setRankings() {
    List<dynamic> ranks = [];
    allRankings.forEach((element) {
      ranks.addAll(element['products']);
    });

    ranks.forEach((element) {
      int idToUpdate = allProducts.indexWhere((p) => p.id == element['id']);

      if (idToUpdate > -1) {
        if (element['order_count'] != null) {
          allProducts[idToUpdate].order_count = element['order_count'];
        }
        if (element['view_count'] != null) {
          allProducts[idToUpdate].view_count = element['view_count'];
        }
        if (element['shares'] != null) {
          allProducts[idToUpdate].shares = element['shares'];
        }
      }
    });
  }

  bool checkMatch(List child_categories, List<Category> parents) {
    for (var element in child_categories) {
      int index = parents.indexWhere((p) => p.id == element);
      if (index > -1) {
        return true;
      }
    }
    return false;
  }
}

class NetworkError extends Error {}
