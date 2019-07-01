import './user_repository.dart';

class IdService {
  final UserRepository userRepository;

  IdService(this.userRepository);

  String getUserId() => userRepository.getCurrentUsername();

  String getId() {
    String userId = getUserId();
    DateTime now = DateTime.now();
    return userId + now.millisecond.toString();
  }
}
