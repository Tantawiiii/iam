part of 'brands_cubit.dart';

abstract class BrandsState {
  const BrandsState();
}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsSuccess extends BrandsState {
  final BrandsResponseModel response;

  const BrandsSuccess(this.response);
}

class BrandsFailure extends BrandsState {
  final String message;

  const BrandsFailure(this.message);
}

