import 'package:flutter_test/flutter_test.dart';
import 'user_service_stub.dart';
import 'package:gut_ai/resources/app_sync_service.dart';

void main() {
  group('AppSync Service', () {
    test('lists all foods', () async {
      
      final userService = UserServiceStub();
      final credentials = await userService.getCredentials();
      final appSyncService =AppSyncService(credentials);
      String foodList = await appSyncService.listFoods();
      expect(foodList, '[]');
    });
  });
}