import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ProductsLoading extends StoreState {
  const ProductsLoading();
}

class ProductLoaded extends StoreState {
  final ProductDetails product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class Subscribed extends StoreState {
  const Subscribed();
}

class SubscriptionPending extends StoreState {
  const SubscriptionPending();
}

class Unavailable extends StoreState {
  const Unavailable();
}

class SubscriptionError extends StoreState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  SubscriptionError({required this.message}) : report = null;

  SubscriptionError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory SubscriptionError.fromReport(ErrorReport report) =>
      SubscriptionError.fromError(error: report.error, trace: report.trace);
}
