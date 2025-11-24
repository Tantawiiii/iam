part of 'resell_product_cubit.dart';

abstract class ResellProductState {
  const ResellProductState();
}

class ResellProductInitial extends ResellProductState {}

class ResellProductLoading extends ResellProductState {}

class ResellProductSuccess extends ResellProductState {}

class ResellProductFailure extends ResellProductState {
  final String message;

  const ResellProductFailure(this.message);
}
