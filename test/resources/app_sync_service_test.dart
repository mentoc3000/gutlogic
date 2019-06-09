import 'package:test/test.dart';
import 'user_service_stub.dart';
import 'package:gut_ai/resources/app_sync_service.dart';
import 'dart:convert';

void main() {
  group('AppSync Service', () {
    test('lists all foods', () async {
      final userService = UserServiceStub();
      final session = await userService.getSession();
      final appSyncService = AppSyncService(session);
      final operationName = 'listFoods';
      final operation = '''listFoods {
        items {
          name
        }
      }''';
      Map<String, dynamic> foodList = await appSyncService.query(operationName, operation);
      Map<String, dynamic> expected = {
        'data': {
          'listFoods': {
            'items': [
              {"name":"Orange Juice"},
              {"name":"Egg"},
              {"name":"Cream Cheese"},
              {"name":"Tomato"},
              {"name":"Bread"}
            ]
          }
        }
      };
      expect(foodList, expected);

    });

    test('extracts list of items', () {
      const operationName = 'listFoods';
      const items = [
              {"name":"Orange Juice"},
              {"name":"Egg"},
              {"name":"Cream Cheese"},
              {"name":"Tomato"},
              {"name":"Bread"}
            ];
      Map<String, dynamic> response = {
        'data': {
          operationName: {
            'items': items
          }
        }
      };
      Map<String, dynamic> parsedJson = json.decode(json.encode(response));
      expect(AppSyncService.getItems(parsedJson, operationName), items);
    });
  });
}
