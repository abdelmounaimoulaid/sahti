import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sahti/services/off_api.dart';

http.Response _json(Object body, [int code = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)), code,
    headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  test('la fiche Sahti complète est utilisée sans appeler OFF', () async {
    var offCalls = 0;
    final api = OffApi(MockClient((req) async {
      if (req.url.path.startsWith('/api/v1/products/')) {
        return _json({
          'status': 1,
          'product': {
            'product_name': 'Confiture Sahti',
            'image_front_url': 'https://img/x.jpg',
            'ingredients_text': 'Oranges, sucre',
          }
        });
      }
      offCalls++;
      return _json({'status': 0}, 404);
    }));
    final p = await api.fetch('6111021012300');
    expect(p?.name, 'Confiture Sahti');
    expect(offCalls, 0);
  });

  test('fiche Sahti sans nom : le nom vient d\'OFF, les ingrédients de Sahti',
      () async {
    final api = OffApi(MockClient((req) async {
      if (req.url.path.startsWith('/api/v1/products/')) {
        return _json({
          'status': 1,
          'product': {'ingredients_text': 'Lait entier'}
        });
      }
      return _json({
        'status': 1,
        'product': {
          'product_name': 'Lait OFF',
          'ingredients_text': 'autre',
        }
      });
    }));
    final p = await api.fetch('6111032004950');
    expect(p?.name, 'Lait OFF');
    expect(p?.ingredientsText, 'Lait entier');
  });

  test('absent de Sahti : retombe sur OFF', () async {
    final api = OffApi(MockClient((req) async {
      if (req.url.path.startsWith('/api/v1/products/')) {
        return _json({'status': 0}, 404);
      }
      return _json({
        'status': 1,
        'product': {'product_name': 'Produit OFF'}
      });
    }));
    expect((await api.fetch('3017620422003'))?.name, 'Produit OFF');
  });
}
