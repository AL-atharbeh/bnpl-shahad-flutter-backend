import 'auth_service.dart';
import 'payment_service.dart';
import 'home_service.dart';
import 'notification_service.dart';
import 'store_service.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  // Services
  final AuthService auth = AuthService();
  final PaymentService payment = PaymentService();
  final HomeService home = HomeService();
  final NotificationService notification = NotificationService();
  final StoreService store = StoreService();

  // Singleton pattern for easy access
  static ServiceManager get instance => _instance;
}
