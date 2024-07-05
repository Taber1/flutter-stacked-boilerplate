import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:my_first_app/ui/common/ui_helpers.dart';

import '../utils/storage/local_storage.dart';
import '../utils/storage/storage_keys.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com/';

  final Dio _dio = Dio();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log("${options.uri} ${options.queryParameters} ${options.data}");
          // Add common headers here
          // options.headers['Content-Type'] = 'application/json';

          // Add the 'cookie' header only if it exists in LocalStorage
          // final storedCookie =
          //     LocalStorage.getString(LocalStorageKeys.kLSCookieKey);
          // if (storedCookie != null) {
          //   options.headers['cookie'] = storedCookie;
          // }

          // Show loader while making the API request
          if (options.extra['showLoader'] == true) {
            log("onRequest: ${options.extra['showLoader']}");
            showCustomLoader();
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Hide loader after API response only if showLoader is true
          log("onResponse: ${response.requestOptions.extra['showLoader']}");

          if (response.requestOptions.extra['showLoader'] == true) {
            hideCustomLoader();
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Hide loader on error
          hideCustomLoader();

          // Handle error here, e.g., show toast message
          if (e.response != null) {
            final Map<String, dynamic> responseJson =
                json.decode(e.response!.toString());
            log(responseJson.toString());
            showToast(msg: responseJson['message']);
          } else {
            showToast(msg: 'Network Error');
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool showLoader = true,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/$endpoint',
        queryParameters: queryParameters,
        options: Options(extra: {'showLoader': showLoader}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool showLoader = true,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: jsonEncode(body),
        options: Options(extra: {'showLoader': showLoader}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data');
    }
  }

  Future<dynamic> postMultiple(
    String endpoint, {
    List<Map<String, dynamic>>? body,
    bool showLoader = true,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: jsonEncode(body),
        options: Options(extra: {'showLoader': showLoader}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool showLoader = false,
  }) async {
    try {
      final response = await _dio.put(
        '$baseUrl/$endpoint',
        data: jsonEncode(body),
        options: Options(extra: {'showLoader': showLoader}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    bool showLoader = true,
  }) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/$endpoint',
        options: Options(extra: {'showLoader': showLoader}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete data');
    }
  }

  Future<dynamic> fileUpload(
    String endpoint, {
    required String filePath,
    bool showLoader = false,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/$endpoint');

      Map<String, String> headers = {"x-api-x": '4'};

      // Add the 'cookie' header only if it exists in LocalStorage
      final storedCookie =
          LocalStorage.getString(LocalStorageKeys.kLSCookieKey);
      if (storedCookie != null) {
        headers['cookie'] = storedCookie;
      }

      FormData formData = FormData.fromMap(
        {
          "picture": await MultipartFile.fromFile(
            filePath,
            contentType: MediaType('image', 'png'),
          ),
        },
      );

      final response = await _dio.postUri(
        uri,
        data: formData,
        options: Options(headers: headers, extra: {'showLoader': showLoader}),
      );
      hideCustomLoader();
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200) {
      setCookiesIfExists(response);
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  setCookiesIfExists(Response response) {
    List<String>? setCookieHeaders = response.headers['Set-Cookie'];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      // Retrieve the first 'Set-Cookie' header and extract the value before the first semicolon (;)
      String setCookieHeader = setCookieHeaders.first;
      int semicolonIndex = setCookieHeader.indexOf(';');
      if (semicolonIndex != -1) {
        String cookieValue = setCookieHeader.substring(0, semicolonIndex);
        LocalStorage.setString(LocalStorageKeys.kLSCookieKey, cookieValue);
        debugPrint("cookieValue $cookieValue setted");
      }
    }
  }
}
