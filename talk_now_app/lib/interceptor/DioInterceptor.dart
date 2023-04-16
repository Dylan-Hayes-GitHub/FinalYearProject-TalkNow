import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:talk_now_app/dto/refresh.dart';

class DioInterceptor {
  final Dio _dio = Dio();
  late SharedPreferences _prefs;

  DioInterceptor() {
    getSharedPref();

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String? jwt = _prefs.getString(Constants.JWT);
        //add JWT
        if (jwt != null) {
          options.headers['Authorization'] = 'Bearer $jwt';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        return handler.next(response);
      },
      onError: (options, handler) async {
        if (options.response?.statusCode == 401) {
          //refresh validation then make a new request
          if (await refreshToken()) {
            return handler.resolve(await RetryRequest(options.requestOptions));
          }
        } else if (options.response?.statusCode == 404) {
          return handler.next(options);
        }
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> getSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> refreshToken() async {
    Dio separateDio = Dio();
    String url =
        Platform.isAndroid ? Constants.ANDROID_API_URL : Constants.IOS_API_URL;

    String? refreshTok = _prefs.getString(Constants.REFRESH_TOKEN);
    RefreshTokenRequest refreshTokenRequest =
        RefreshTokenRequest(refreshTokenToValidate: refreshTok!);

    final response = await separateDio.post('$url/api/user/refresh',
        data: {'refreshTokenToValidate': refreshTok});

    if (response.statusCode == 200) {
      var tokens = response.data;

      _prefs.setString(Constants.JWT, tokens["jwtToken"]);
      _prefs.setString(Constants.REFRESH_TOKEN, tokens["refreshToken"]);
      return true;
    } else {
      return false;
    }
  }

  Future<Response<dynamic>> RetryRequest(RequestOptions requestOptions) async {
    final options =
        Options(method: requestOptions.method, headers: requestOptions.headers);
    options.headers!['Authorization'] =
        'Bearer ${_prefs.getString(Constants.JWT)}';

    final completer = Completer<Response<dynamic>>();
    dio
        .request<dynamic>(requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: options)
        .then((response) {
      completer.complete(response);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }
}
