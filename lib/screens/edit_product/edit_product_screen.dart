import 'package:krishfarm/models/Product.dart';
import 'package:krishfarm/screens/edit_product/components/edit_product_form.dart';
import 'package:krishfarm/screens/edit_product/provider_models/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatelessWidget {
  final Product? productToEdit;
  final String? title;

  const EditProductScreen(
      {this.productToEdit, this.title = "Upload new Product"});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductDetails(),
      // child: ProductUploadSelectionScreen(),
      child: ProductUploadForm(
        product: productToEdit,
        title: title!,
      ),
    );
  }
}
