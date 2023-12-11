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
    String? onServerErrorMessage = "",
    String? databaseMessageError = "",
  }) {
    String message = "";
    if (error is BasicResponse) {
      message = error.message ?? "";
    } else if (error is FormatException) {
      message = error.toString();
    } else if (error is http.Response) {
      switch (error.statusCode) {
        case 401:
          message = unAuthorizedMessageError ?? "Unauthorized";
          break;
        case 500:
          message = onServerErrorMessage ??
              "oops, something went wrong, internal server error";
          break;
        default:
          message = error.body;
      }
    } else if (error is DatabaseException) {
      message =
          databaseMessageError ?? "Database Error, please reset your database";
    } else {
      message = error.toString();
    }

    message = "$prefix $message";

    return message.replaceAll('"', "");
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
