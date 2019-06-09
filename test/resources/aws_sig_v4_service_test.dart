import 'package:test/test.dart';
import 'user_service_stub.dart';
import 'package:gut_ai/resources/aws_sig_v4_service.dart';

void main() {
  group('SigV4 service', () {
    test('should say hello', () async {
      final userService = UserServiceStub();
      final credentials = await userService.getCredentials();
      final sigV4Service = new AwsSigV4Service(credentials);
      final response = await sigV4Service.apiRequest('GET', '/say-hello');
      expect(response.body, '"Greetings Earthling!"');
    });
  });
}
