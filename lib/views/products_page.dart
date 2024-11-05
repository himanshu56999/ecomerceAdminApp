import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../container/additional_confirm.dart';
import '../controllers/db_service.dart';
import '../models/products_model.dart';
import '../providers/admin_provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch categories when the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.getCategories(); // Fetch categories
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: Consumer<AdminProvider>(builder: (context, value, child) {
        List<ProductsModel> products = ProductsModel.fromJsonList(value.products) as List<ProductsModel>;

        if (products.isEmpty) {
          return Center(child: Text("No Products Found"));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Choose what you want"),
                    content: Text("Delete cannot be undone"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AdditionalConfirm(
                              contentText: "Are you sure you want to delete this product",
                              onYes: () {
                                DbService().deleteProduct(docId: products[index].id);
                                Navigator.pop(context);
                              },
                              onNo: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        child: Text("Delete Product"),
                      ),
                      TextButton(
                        onPressed: () {}, // Add your edit logic here
                        child: Text("Edit Product"),
                      ),
                    ],
                  ),
                );
              },
              onTap: () => Navigator.pushNamed(context, "/view_product", arguments: products[index]),
              leading: Container(
                height: 50,
                width: 50,
                child: Image.network(products[index].image),
              ),
              title: Text(
                products[index].name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("₹ ${products[index].new_price.toString()}"),
                  Container(
                    padding: EdgeInsets.all(4),
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      products[index].category.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, "/add_product", arguments: products[index]);
                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  adminProvider.getProducts();
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/add_product");
        },
      ),
    );
  }
}
