part of 'brand_products_cubit.dart';

abstract class BrandProductsState {
  const BrandProductsState();
}

class BrandProductsInitial extends BrandProductsState {}

class BrandProductsLoading extends BrandProductsState {}

class BrandProductsSuccess extends BrandProductsState {
  final BrandDetailsResponseModel response;

  const BrandProductsSuccess(this.response);
}

class BrandProductsFailure extends BrandProductsState {
  final String message;

  const BrandProductsFailure(this.message);
}

