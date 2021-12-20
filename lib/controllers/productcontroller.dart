import 'package:fiska/models/product.dart';
import 'package:fiska/models/product_detail.dart';
import 'package:fiska/services/api_service.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  var productList = <ProductElement>[].obs;
  var isLoading = true.obs;
  var productDetail = ProductData().obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
    try {
      isLoading(true);
      var products = await ApiService.fetchProducts();
      if (products != null) {
        productList.assignAll(products);
        print("products: $productList");
      } else {}
    } catch (e) {
      print("error: $e");
    } finally {
      isLoading(false);
    }
  }

  void fetchProductDetails(int id) async {
    try {
      //isLoading(true);
      var detail = await ApiService.fetchProductsDetails(id);
      if (detail != null) {
        productDetail.value = detail;
        print("productdetail: ${productDetail.value.productName}");
      } else {
        print("error");
      }
    } finally {
      //isLoading(false);
    }
  }
}
