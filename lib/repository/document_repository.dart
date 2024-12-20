// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:docs_clone_flutter/constants.dart';
import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/models/error_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      var res = await _client.post(
        Uri.parse('$host/doc/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(jsonDecode(res.body)),
          );
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
          break;
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }
Future<ErrorModel> getDocuments(String token) async {
  ErrorModel error = ErrorModel(
    error: 'Some unexpected error occurred.',
    data: null,
  );
  try {
    print('Sending GET request to: $host/docs/me with token: $token');
    
    var res = await _client.get(
      Uri.parse('$host/docs/me'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    print('Response status code: ${res.statusCode}');
    print('Response body: ${res.body}');
    
    switch (res.statusCode) {
      case 200:
        List<DocumentModel> documents = [];

        var decoded = jsonDecode(res.body);
        
        if (decoded is List) {
          print('Decoded response is a List');
          for (var doc in decoded) {
            documents.add(DocumentModel.fromJson(doc));
          }
        } else {
          print('Decoded response is not a List');
          // Handle the case where the response is not a list
          error = ErrorModel(
            error: 'Unexpected data structure received.',
            data: null,
          );
        }

        error = ErrorModel(
          error: null,
          data: documents,
        );
        break;
      default:
        error = ErrorModel(
          error: res.body,
          data: null,
        );
        break;
    }
  } catch (e) {
    print('Error occurred: $e');
    error = ErrorModel(
      error: e.toString(),
      data: null,
    );
  }
  return error;
}

  void updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'title': title,
        'id': id,
      }),
    );
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          throw 'This Document does not exist, please create a new one.';
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }
}
