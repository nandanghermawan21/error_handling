library error_handling;

import 'dart:convert';

import 'package:error_handling/basic_response.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class ErrorHandlingUtil {
  static handleApiError(
    dynamic error, {
    String? prefix = "",
    String? onTimeOut = "",
    String? unAuthorizedMessageError = "",
    String? databaseMessageError = "",
  }) {
    String _message = "";
    if (error is BasicResponse) {
      _message = error.message ?? "";
    } else if (error is FormatException) {
      _message = error.toString();
    } else if (error is http.Response) {
      switch (error.statusCode) {
        case 401:
          _message = unAuthorizedMessageError ?? "Unauthorized";
          break;
        default:
          _message = error.body;
      }
    } else if (error is DatabaseException) {
      _message =
          databaseMessageError ?? "Database Error, please reset your database";
    } else {
      _message = error.toString();
    }

    _message = "$prefix $_message";

    return _message.replaceAll('"', "");
  }

  static String readMessage(http.Response response) {
    try {
      return json.decode(response.body)["Message"].toString() == ""
          ? defaultMessage(response)
          : json.decode(response.body)["Message"].toString();
    } catch (e) {
      return defaultMessage(response);
    }
  }

  static String defaultMessage(http.Response response) {
    return "${response.body.isNotEmpty ? response.body : response.statusCode}";
  }
}
