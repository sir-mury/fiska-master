import 'dart:convert';
import 'package:fiska/models/cart.dart';
import 'package:fiska/models/product_detail.dart';
import 'package:fiska/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:fiska/models/product.dart';
import 'package:dio/dio.dart';

class ApiService {
  static var client = http.Client();
  static var baseUrl = "https://fiskah.com/app-api/v2.3/";
  static Map<String, String> headers = {};

  static void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    List cookieParts = rawCookie.split(",");
    List sessions = [];
    for (var elements in cookieParts) {
      List elementParts = elements.split(";");
      for (String value in elementParts) {
        if (value.contains("PHP")) {
          sessions.add(value);
        }
      }
    }
    headers['Cookie'] = sessions.last;
    print("sessionID:${sessions.last}");
  }

  static Future<List<ProductElement>> fetchProducts() async {
    try {
      http.Response response = await http.get(
        Uri.parse("$baseUrl" + "products/"),
      );
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var product = productFromJson(jsonResponse);
        return product.data.products;
      } else {
        return null;
      }
    } catch (error) {
      return error;
    }
  }

  static Future<ProductData> fetchProductsDetails(int id) async {
    try {
      http.Response response =
          await http.post(Uri.parse("$baseUrl" + 'products/view/$id/'));
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var productDetail = productDetailFromJson(jsonResponse);
        print("stuff: ${productDetail.data.product.data}");
        return productDetail.data.product.data;
      } else {
        return null;
      }
    } catch (error) {
      print("An error occurred");
      return error;
    }
  }

  static Future<UserData> login(UserLogin userLogin) async {
    var body = UserLogin(
      username: userLogin.username,
      password: userLogin.password,
      userType: userLogin.userType,
    ).toJson();
    //print("body: $body");
    var body1 = {
      "username": userLogin.username,
      "password": userLogin.password,
      "userType": "1"
    };
    try {
      http.Response response = await http.post(
        Uri.parse("$baseUrl" + "guest-user/login/"),
        body: body,
      );
      updateCookie(response);
      //print(response);
      if (response.statusCode == 200) {
        print(headers["Cookie"]);
        var jsonResponse = response.body;
        var user = userFromJson(jsonResponse);
        return user.data;
      } else {
        return null;
      }
    } catch (e) {
      print("Login Failed: $e");
      return e;
    }
  }

  static Future<String> logout(UserLogout userLogout) async {
    Map<String, dynamic> body =
        UserLogout(fcmToken: userLogout.fcmToken, userType: userLogout.userType)
            .toJson();
    try {
      http.Response response = await http
          .post(Uri.parse("$baseUrl" + 'guest-user/logout/'), body: body);
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var result = jsonDecode(jsonResponse);
        if (result["status"] == "1") {
          return "1";
        } else {
          return "0";
        }
      } else {
        return null;
      }
    } catch (e) {
      print("logout Error: $e");
      return e;
    }
  }

  static Future<String> addToCart(AddToCart item) async {
    var body = item.toJson();
    try {
      http.Response response = await http.post(
        Uri.parse("$baseUrl" + 'cart/add/'),
        body: body,
      );
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var result = jsonDecode(jsonResponse);
        if (result["status"] == "1" && result["msg"] == "Added Successfully") {
          return "1";
        } else {
          return "0";
        }
      } else {
        return null;
      }
    } catch (e) {
      print("add to cart error:$e");
      return e;
    }
  }

  static Future<String> removeFromCart(RemoveFromCart item) async {
    var body = item.toJson();
    try {
      http.Response response = await http.post(
        Uri.parse("$baseUrl" + 'cart/remove/'),
        body: body,
      );
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        var result = jsonDecode(jsonResponse);
        if (result["status"] == "1") {
          client.close();
          return "1";
        } else {
          client.close();
          return "0";
        }
      } else {
        client.close();
        return null;
      }
    } catch (e) {
      print("Remove cart error:$e");
      return e;
    }
  }

  static Future<Products> shippingCartListing() async {
    try {
      http.Response response = await http.get(
        Uri.parse("$baseUrl" + 'cart/listing/2'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        String jsonResponse = response.body;
        print(jsonResponse);
        Cart result = cartFromJson(jsonResponse);
        return result.data.products;
      } else {
        return null;
      }
    } catch (e) {
      print("cart listing error: $e");
      return e;
    }
  }

  static Future orderListing() async {}
}
