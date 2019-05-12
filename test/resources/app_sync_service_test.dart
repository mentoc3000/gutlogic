import 'package:flutter_test/flutter_test.dart';
import 'user_service_stub.dart';
import 'package:gut_ai/resources/app_sync_service.dart';

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
      const parsedJson = {
        'data': {
          operationName: {
            'items': items
          }
        }
      };
      expect(AppSyncService.getItems(parsedJson, operationName), items);
    });
  });
}
