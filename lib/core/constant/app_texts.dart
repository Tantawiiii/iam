import 'package:flutter/material.dart';

import '../localization/app_language.dart';

final class AppTexts {
  AppTexts._();

  static AppLanguage _currentLanguage = AppLanguage.ar;

  static void updateLocale(Locale locale) {
    _currentLanguage = appLanguageFromLocale(locale);
  }

  static AppLanguage get currentLanguage => _currentLanguage;

  static String _text(String key) {
    final translations = _localizedValues[key];
    if (translations == null) return key;
    return translations[_currentLanguage] ??
        translations[AppLanguage.en] ??
        key;
  }

  static String get welcomeBack => _text('welcomeBack');
  static String get loginToCont => _text('loginToCont');
  static String get email => _text('email');
  static String get password => _text('password');
  static String get confirmPassword => _text('confirmPassword');
  static String get phoneNum => _text('phoneNum');
  static String get login => _text('login');
  static String get loginLoading => _text('loginLoading');
  static String get pleaseEnterPass => _text('pleaseEnterPass');
  static String get pleaseEnterEmail => _text('pleaseEnterEmail');
  static String get pleaseEnterValidEmail => _text('pleaseEnterValidEmail');
  static String get pleaseEnterName => _text('pleaseEnterName');
  static String get passwordsDoNotMatch => _text('passwordsDoNotMatch');
  static String get newPasswordOptional => _text('newPasswordOptional');
  static String get updating => _text('updating');
  static String get name => _text('name');
  static String get loginSuccess => _text('loginSuccess');
  static String get unauthenticatedMessage => _text('unauthenticatedMessage');
  static String get signUp => _text('signUp');
  static String get fullName => _text('fullName');
  static String get dontHaveAcc => _text('dontHaveAcc');
  static String get createAcc => _text('createAcc');
  static String get continueAsGuest => _text('continueAsGuest');

  static String get onTitle1 => _text('onTitle1');
  static String get onDesTitle1 => _text('onDesTitle1');
  static String get onTitle2 => _text('onTitle2');
  static String get onDesTitle2 => _text('onDesTitle2');
  static String get onTitle3 => _text('onTitle3');
  static String get onDesTitle3 => _text('onDesTitle3');
  static String get onTitle4 => _text('onTitle4');
  static String get onDesTitle4 => _text('onDesTitle4');
  static String get onTitle5 => _text('onTitle5');
  static String get onDesTitle5 => _text('onDesTitle5');
  static String get onTitle6 => _text('onTitle6');
  static String get notifWelcomeTitle => _text('notifWelcomeTitle');
  static String get notifWelcomeBody => _text('notifWelcomeBody');
  static String get notifSubscribedTitle => _text('notifSubscribedTitle');
  static String get notifSubscribedBody => _text('notifSubscribedBody');
  static String get notifOrderAppliedTitle => _text('notifOrderAppliedTitle');
  static String get notifOrderAppliedBody => _text('notifOrderAppliedBody');
  static String get notifOrderAcceptedTitle => _text('notifOrderAcceptedTitle');
  static String get notifOrderAcceptedBody => _text('notifOrderAcceptedBody');
  static String get notifOrderRejectedTitle => _text('notifOrderRejectedTitle');
  static String get notifOrderRejectedBody => _text('notifOrderRejectedBody');
  static String get notifCashOrderSuccessTitle =>
      _text('notifCashOrderSuccessTitle');
  static String get notifCashOrderSuccessBody =>
      _text('notifCashOrderSuccessBody');

  static String get skip => _text('skip');
  static String get prev => _text('prev');
  static String get getStarted => _text('getStarted');
  static String get next => _text('next');
  static String get camera => _text('camera');
  static String get gallery => _text('gallery');
  static String get videoAvailable => _text('videoAvailable');
  static String get tapToPlay => _text('tapToPlay');
  static String get cart => _text('cart');
  static String get cartEmpty => _text('cartEmpty');
  static String get addItemsToCart => _text('addItemsToCart');

  static String get allProducts => _text('allProducts');
  static String get bestProducts => _text('bestProducts');
  static String get viewProducts => _text('viewProducts');
  static String get noAvailableProducts => _text('noAvailableProducts');

  static String get settings => _text('settings');
  static String get updateProfile => _text('updateProfile');
  static String get editYourInfo => _text('editYourInfo');
  static String get contactUs => _text('contactUs');
  static String get sendUsMessage => _text('sendUsMessage');
  static String get logout => _text('logout');
  static String get logoutConfirmationMessage =>
      _text('logoutConfirmationMessage');
  static String get cancel => _text('cancel');
  static String get signOutReturn => _text('signOutReturn');
  static String get language => _text('language');
  static String get changeLanguage => _text('changeLanguage');
  static String get arabic => _text('arabic');
  static String get english => _text('english');
  static String get allCategories => _text('allCategories');
  static String get noCategoriesAvailable => _text('noCategoriesAvailable');
  static String get allBrands => _text('allBrands');
  static String get noBrandsAvailable => _text('noBrandsAvailable');
  static String get seeAll => _text('seeAll');
  static String get myAccount => _text('myAccount');
  static String get orders => _text('orders');
  static String get noOrdersYet => _text('noOrdersYet');
  static String get productsForSale => _text('productsForSale');
  static String get noProductsForSale => _text('noProductsForSale');
  static String get total => _text('total');
  static String get invoice => _text('invoice');
  static String get checkout => _text('checkout');
  static String get eGP => _text('eGP');
  static String get contactInformation => _text('contactInformation');
  static String get phone => _text('phone');
  static String get pleaseEnterPhone => _text('pleaseEnterPhone');
  static String get shippingAddress => _text('shippingAddress');
  static String get addressLine => _text('addressLine');
  static String get pleaseEnterAddress => _text('pleaseEnterAddress');
  static String get city => _text('city');
  static String get pleaseEnterCity => _text('pleaseEnterCity');
  static String get state => _text('state');
  static String get pleaseEnterState => _text('pleaseEnterState');
  static String get zipCode => _text('zipCode');
  static String get pleaseEnterZipCode => _text('pleaseEnterZipCode');
  static String get paymentMethod => _text('paymentMethod');
  static String get card => _text('card');
  static String get cash => _text('cash');
  static String get promoCodeOptional => _text('promoCodeOptional');
  static String get enterPromoCode => _text('enterPromoCode');
  static String get applyPromoCode => _text('applyPromoCode');
  static String get couponApplied => _text('couponApplied');
  static String get invalidPromoCode => _text('invalidPromoCode');
  static String get processing => _text('processing');
  static String get placeOrder => _text('placeOrder');
  static String get search => _text('search');
  static String get searchProductsHint => _text('searchProductsHint');
  static String get startTypingToSearchProducts =>
      _text('startTypingToSearchProducts');
  static String get noResultsFound => _text('noResultsFound');
  static String get wishlist => _text('wishlist');
  static String get favorites => _text('favorites');
  static String get home => _text('home');
  static String get retry => _text('retry');
  static String get wishlistEmpty => _text('wishlistEmpty');
  static String get addItemsToWishlist => _text('addItemsToWishlist');
  static String get addReview => _text('addReview');
  static String get pleaseSelectRating => _text('pleaseSelectRating');
  static String get rateThisProduct => _text('rateThisProduct');
  static String get writeYourReview => _text('writeYourReview');
  static String get shareYourExperience => _text('shareYourExperience');
  static String get pleaseWriteReview => _text('pleaseWriteReview');
  static String get reviewMinCharacters => _text('reviewMinCharacters');
  static String get submitting => _text('submitting');
  static String get submitReview => _text('submitReview');
  static String get order => _text('order');
  static String get orderInformation => _text('orderInformation');
  static String get orderNumberLabel => _text('orderNumberLabel');
  static String get orderDate => _text('orderDate');
  static String get customer => _text('customer');
  static String get paymentInformation => _text('paymentInformation');
  static String get paymentStatus => _text('paymentStatus');
  static String get promoCode => _text('promoCode');
  static String get orderItems => _text('orderItems');
  static String get quantity => _text('quantity');
  static String get paid => _text('paid');
  static String get pending => _text('pending');
  static String get cancelOrder => _text('cancelOrder');
  static String get deleteOrder => _text('deleteOrder');
  static String get confirmCancelOrder => _text('confirmCancelOrder');
  static String get cancelOrderConfirmationMessage =>
      _text('cancelOrderConfirmationMessage');
  static String get confirmDeleteOrder => _text('confirmDeleteOrder');
  static String get deleteOrderConfirmationMessage =>
      _text('deleteOrderConfirmationMessage');
  static String get orderCancelledSuccess => _text('orderCancelledSuccess');
  static String get orderDeletedSuccess => _text('orderDeletedSuccess');
  static String get orderNotLoaded => _text('orderNotLoaded');
  static String get orderSuccessTitle => _text('orderSuccessTitle');
  static String get orderPlacedSuccessfully => _text('orderPlacedSuccessfully');
  static String get viewInvoice => _text('viewInvoice');
  static String get downloadInvoice => _text('downloadInvoice');
  static String get backToHome => _text('backToHome');
  static String get downloading => _text('downloading');
  static String get invoiceDownloaded => _text('invoiceDownloaded');
  static String get downloadFailed => _text('downloadFailed');
  static String get close => _text('close');
  static String get deleteAccount => _text('deleteAccount');
  static String get deleteAccountConfirmationTitle =>
      _text('deleteAccountConfirmationTitle');
  static String get deleteAccountConfirmationMessage =>
      _text('deleteAccountConfirmationMessage');
  static String get deleteAccountSuccess => _text('deleteAccountSuccess');
  static String get shopWithConfidence => _text('shopWithConfidence');
  static String get secureTransaction => _text('secureTransaction');
  static String get safeDelivery => _text('safeDelivery');
  static String get returnIn15Days => _text('returnIn15Days');
  static String get freeDelivery => _text('freeDelivery');
  static String get oneYearWarranty => _text('oneYearWarranty');
  static String get description => _text('description');
  static String get productDetails => _text('productDetails');
  static String get brand => _text('brand');
  static String get productNumber => _text('productNumber');
  static String get copied => _text('copied');
  static String get price => _text('price');
  static String get type => _text('type');
  static String get color => _text('color');
  static String get quantityAvailable => _text('quantityAvailable');
  static String get inCart => _text('inCart');
  static String get addToCart => _text('addToCart');
  static String get addingToCart => _text('addingToCart');
  static String get reviewsTitle => _text('reviewsTitle');
  static String get reviewsCountLabel => _text('reviewsCountLabel');
  static String get writeAReview => _text('writeAReview');
  static String get anonymous => _text('anonymous');
  static String get failedToUpdateCart => _text('failedToUpdateCart');
  static String get off => _text('off');
  static String get age => _text('age');
  static String get pleaseEnterAge => _text('pleaseEnterAge');
  static String get gender => _text('gender');
  static String get pleaseSelectGender => _text('pleaseSelectGender');
  static String get male => _text('male');
  static String get female => _text('female');
  static String get country => _text('country');
  static String get pleaseEnterCountry => _text('pleaseEnterCountry');
  static String get termsAndConditions => _text('termsAndConditions');
  static String get acceptTermsAndConditions =>
      _text('acceptTermsAndConditions');
  static String get pleaseAcceptTerms => _text('pleaseAcceptTerms');
  static String get accountCreatedSuccess => _text('accountCreatedSuccess');
  static String get pleaseConfirmPassword => _text('pleaseConfirmPassword');
  static String get passwordMinLength => _text('passwordMinLength');
  static String get validAge => _text('validAge');
  static String get creating => _text('creating');
  static String get idImage => _text('idImage');
  static String get pleaseUploadIdImage => _text('pleaseUploadIdImage');
  static String get bankStatementImage => _text('bankStatementImage');
  static String get invoiceImage => _text('invoiceImage');
  static String get installment => _text('installment');
  static String get selectInstallmentMonths => _text('selectInstallmentMonths');
  static String get installmentMonths => _text('installmentMonths');
  static String get originalAmount => _text('originalAmount');
  static String get increaseAmount => _text('increaseAmount');
  static String get totalAmount => _text('totalAmount');
  static String get months => _text('months');
  static String get updateYourData => _text('updateYourData');
  static String get pleaseUpdateYourData => _text('pleaseUpdateYourData');
  static String get uploadMissingImages => _text('uploadMissingImages');
  static String get pleaseUploadMissingImages =>
      _text('pleaseUploadMissingImages');
  static String get dataUnderReview => _text('dataUnderReview');
  static String get dataUnderReviewMessage => _text('dataUnderReviewMessage');
  static String get goToUpdateProfile => _text('goToUpdateProfile');
  static String get ok => _text('ok');
  static String get confirmWhatsApp => _text('confirmWhatsApp');
  static String get phoneWithWhatsApp => _text('phoneWithWhatsApp');
  static String get pleaseSelectCountry => _text('pleaseSelectCountry');
  static String get ageRange => _text('ageRange');
  static String get verifyOtp => _text('verifyOtp');
  static String get notifications => _text('notifications');
  static String get accountUnderReview => _text('accountUnderReview');
  static String get vipFeatureTitle => _text('vipFeatureTitle');
  static String get vipFeatureMessage => _text('vipFeatureMessage');
  static String get subscribeToVipNow => _text('subscribeToVipNow');
  static String get accountApproved => _text('accountApproved');
  static String get accountRejected => _text('accountRejected');
  static String get noNotifications => _text('noNotifications');
  static String get markAllAsRead => _text('markAllAsRead');
  static String get accountUnderReviewTitle => _text('accountUnderReviewTitle');
  static String get accountApprovedTitle => _text('accountApprovedTitle');
  static String get accountRejectedTitle => _text('accountRejectedTitle');
  static String get accountApprovedMessage => _text('accountApprovedMessage');
  static String get accountRejectedMessage => _text('accountRejectedMessage');
  static String get additionalDocumentsRequiredTitle =>
      _text('additionalDocumentsRequiredTitle');
  static String get additionalDocumentsRequiredMessage =>
      _text('additionalDocumentsRequiredMessage');
  static String get uploadDocuments => _text('uploadDocuments');
  static String get documentsNotClearTitle => _text('documentsNotClearTitle');
  static String get documentsNotClearMessage =>
      _text('documentsNotClearMessage');
  static String get installmentRequestExpiredTitle =>
      _text('installmentRequestExpiredTitle');
  static String get installmentRequestExpiredMessage =>
      _text('installmentRequestExpiredMessage');
  static String get creditLimitUpdatedTitle => _text('creditLimitUpdatedTitle');
  static String get creditLimitUpdatedMessage =>
      _text('creditLimitUpdatedMessage');
  static String get installmentServiceSuspendedTitle =>
      _text('installmentServiceSuspendedTitle');
  static String get installmentServiceSuspendedMessage =>
      _text('installmentServiceSuspendedMessage');
  static String get shareApp => _text('shareApp');
  static String get shareAppMessage => _text('shareAppMessage');
  static String get now => _text('now');
  static String get minutesAgo => _text('minutesAgo');
  static String get hoursAgo => _text('hoursAgo');
  static String get yesterday => _text('yesterday');
  static String get daysAgo => _text('daysAgo');
  static String get resellProduct => _text('resellProduct');
  static String get resellProductSubtitle => _text('resellProductSubtitle');
  static String get productSubmittedSuccess => _text('productSubmittedSuccess');
  static String get submit => _text('submit');
  static String get pleaseEnterProductName => _text('pleaseEnterProductName');
  static String get pleaseEnterDescription => _text('pleaseEnterDescription');
  static String get descriptionMustBeAtLeast10Characters =>
      _text('descriptionMustBeAtLeast10Characters');
  static String get pleaseEnterPrice => _text('pleaseEnterPrice');
  static String get pleaseEnterValidPrice => _text('pleaseEnterValidPrice');
  static String get pleaseEnterProductNumber =>
      _text('pleaseEnterProductNumber');
  static String get enterOtp => _text('enterOtp');
  static String get pleaseEnterOtp => _text('pleaseEnterOtp');
  static String get otpMustBe6Digits => _text('otpMustBe6Digits');
  static String get enter6DigitCodeSentToEmail =>
      _text('enter6DigitCodeSentToEmail');
  static String get verifying => _text('verifying');
  static String get otpVerifiedSuccess => _text('otpVerifiedSuccess');
  static String get forgetPassword => _text('forgetPassword');
  static String get resetPassword => _text('resetPassword');
  static String get resetPasswordTitle => _text('resetPasswordTitle');
  static String get resetPasswordDescription =>
      _text('resetPasswordDescription');
  static String get newPassword => _text('newPassword');
  static String get pleaseEnterNewPassword => _text('pleaseEnterNewPassword');
  static String get passwordResetSuccess => _text('passwordResetSuccess');
  static String get sendingOtp => _text('sendingOtp');
  static String get resettingPassword => _text('resettingPassword');
  static String get send => _text('send');
  static String get termsAndConditionsContent =>
      _text('termsAndConditionsContent');
  static String get termsAndConditionsStatic =>
      _text('termsAndConditionsStatic');
  static String get termsAndConditionsLastUpdate =>
      _text('termsAndConditionsLastUpdate');
  static String get readTermsAndConditions => _text('readTermsAndConditions');
  static String get completePayment => _text('completePayment');
  static String get paymentSuccess => _text('paymentSuccess');
  static String get paymentFailed => _text('paymentFailed');
  static String get paymentCancelled => _text('paymentCancelled');
  static String get paymentProcessing => _text('paymentProcessing');
  static String get payNow => _text('payNow');
  static String get paymentRetryInstructions => _text('paymentRetryInstructions');
  static String get confirmYourPayment => _text('confirmYourPayment');
  static String get orderSubmittedSuccessTitle =>
      _text('orderSubmittedSuccessTitle');
  static String get orderSubmittedSuccessMessage =>
      _text('orderSubmittedSuccessMessage');

  static String get pleaseLoginFirst => _text('pleaseLoginFirst');
  static String get messageSentSuccess => _text('messageSentSuccess');
  static String get getInTouch => _text('getInTouch');
  static String get contactUsSubtitle => _text('contactUsSubtitle');
  static String get messageLabel => _text('messageLabel');
  static String get pleaseEnterMessage => _text('pleaseEnterMessage');
  static String get messageMinLengthError => _text('messageMinLengthError');
  static String get sending => _text('sending');
  static String get sendMessage => _text('sendMessage');

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    'welcomeBack': {
      AppLanguage.en: 'Welcome back',
      AppLanguage.ar: 'مرحباً بعودتك',
    },
    'pleaseLoginFirst': {
      AppLanguage.en: 'Please login first',
      AppLanguage.ar: 'يرجى تسجيل الدخول أولاً',
    },
    'messageSentSuccess': {
      AppLanguage.en: 'Message sent successfully!',
      AppLanguage.ar: 'تم إرسال الرسالة بنجاح!',
    },
    'getInTouch': {
      AppLanguage.en: 'Get in Touch',
      AppLanguage.ar: 'تواصل معنا',
    },
    'contactUsSubtitle': {
      AppLanguage.en:
          'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
      AppLanguage.ar: 'نحب أن نسمع منك. أرسل لنا رسالة وسنرد في أقرب وقت ممكن.',
    },
    'messageLabel': {AppLanguage.en: 'Message', AppLanguage.ar: 'الرسالة'},
    'pleaseEnterMessage': {
      AppLanguage.en: 'Please enter your message',
      AppLanguage.ar: 'يرجى إدخال رسالتك',
    },
    'messageMinLengthError': {
      AppLanguage.en: 'Message must be at least 10 characters',
      AppLanguage.ar: 'يجب أن تكون الرسالة 10 أحرف على الأقل',
    },
    'sending': {
      AppLanguage.en: 'Sending...',
      AppLanguage.ar: 'جارٍ الإرسال...',
    },
    'sendMessage': {
      AppLanguage.en: 'Send Message',
      AppLanguage.ar: 'إرسال الرسالة',
    },
    'completePayment': {
      AppLanguage.en: 'Complete Payment',
      AppLanguage.ar: 'استكمال الدفع',
    },
    'paymentSuccess': {
      AppLanguage.en: 'Payment successful!',
      AppLanguage.ar: 'تم الدفع بنجاح!',
    },
    'paymentFailed': {
      AppLanguage.en: 'Payment failed. Please try again.',
      AppLanguage.ar: 'فشل الدفع. يرجى المحاولة مرة أخرى.',
    },
    'paymentCancelled': {
      AppLanguage.en: 'Payment cancelled.',
      AppLanguage.ar: 'تم إلغاء الدفع.',
    },
    'paymentProcessing': {
      AppLanguage.en: 'Processing payment...',
      AppLanguage.ar: 'جارٍ معالجة الدفع...',
    },
    'confirmYourPayment': {
      AppLanguage.en: 'Confirm your Payment',
      AppLanguage.ar: 'تأكيد الدفع',
    },
    'orderSubmittedSuccessTitle': {
      AppLanguage.en: 'Your order has been submitted successfully',
      AppLanguage.ar: 'تم تقديم طلبك بنجاح',
    },
    'orderSubmittedSuccessMessage': {
      AppLanguage.en:
          'A customer service representative will contact you to complete the remaining procedures.',
      AppLanguage.ar:
          'سوف يقوم احد ممثلى خدمة العملاء بالتواصل معك لاستكمال باقى الإجراءات.',
    },
    'payNow': {
      AppLanguage.en: 'Pay Now',
      AppLanguage.ar: 'ادفع الآن',
    },
    'paymentRetryInstructions': {
      AppLanguage.en:
          'You can retry the payment anytime from your order details in the profile section.',
      AppLanguage.ar:
          'يمكنك إعادة محاولة الدفع في أي وقت من تفاصيل الطلب في قسم الملف الشخصي.',
    },
    'loginToCont': {
      AppLanguage.en: 'Login to continue',
      AppLanguage.ar: 'سجّل الدخول للمتابعة',
    },
    'email': {AppLanguage.en: 'Email', AppLanguage.ar: 'البريد الإلكتروني'},
    'total': {AppLanguage.en: 'Total', AppLanguage.ar: 'المجموع'},
    'eGP': {AppLanguage.en: 'AED', AppLanguage.ar: 'درهم'},
    'checkout': {AppLanguage.en: 'Checkout', AppLanguage.ar: 'الدفع'},
    'myAccount': {AppLanguage.en: 'My Account', AppLanguage.ar: 'حسابي'},
    'noOrdersYet': {
      AppLanguage.en: 'No Orders Yet',
      AppLanguage.ar: 'لا يوجد طالبات',
    },
    'orders': {AppLanguage.en: 'Orders', AppLanguage.ar: 'طلباتي'},
    'productsForSale': {
      AppLanguage.en: 'Products for Sale',
      AppLanguage.ar: 'المنتجات المعروضة للبيع',
    },
    'noProductsForSale': {
      AppLanguage.en: 'No Products for Sale',
      AppLanguage.ar: 'لا توجد منتجات معروضة للبيع',
    },
    'allCategories': {
      AppLanguage.en: 'All Categories',
      AppLanguage.ar: 'جميع الفئات',
    },
    'noCategoriesAvailable': {
      AppLanguage.en: 'No Categories available',
      AppLanguage.ar: 'لا يوجد فئات متاحة',
    },
    'allBrands': {
      AppLanguage.en: 'All Brands',
      AppLanguage.ar: 'جميع الماركات',
    },
    'seeAll': {AppLanguage.en: 'see all', AppLanguage.ar: 'كل المنتجات'},
    'noBrandsAvailable': {
      AppLanguage.en: 'No Brands available',
      AppLanguage.ar: 'لا يوجد ماركات متاحه',
    },
    'password': {AppLanguage.en: 'Password', AppLanguage.ar: 'كلمة المرور'},
    'confirmPassword': {
      AppLanguage.en: 'Confirm password',
      AppLanguage.ar: 'تأكيد كلمة المرور',
    },
    'phoneNum': {AppLanguage.en: 'Phone number', AppLanguage.ar: 'رقم الهاتف'},
    'login': {AppLanguage.en: 'Login', AppLanguage.ar: 'تسجيل الدخول'},
    'loginLoading': {
      AppLanguage.en: 'Logging in...',
      AppLanguage.ar: 'جارٍ تسجيل الدخول...',
    },
    'pleaseEnterPass': {
      AppLanguage.en: 'Please enter your password',
      AppLanguage.ar: 'يرجى إدخال كلمة المرور',
    },
    'pleaseEnterEmail': {
      AppLanguage.en: 'Please enter your email',
      AppLanguage.ar: 'يرجى إدخال البريد الإلكتروني',
    },
    'pleaseEnterValidEmail': {
      AppLanguage.en: 'Please enter a valid email',
      AppLanguage.ar: 'يرجى إدخال بريد إلكتروني صالح',
    },
    'pleaseEnterName': {
      AppLanguage.en: 'Please enter your name',
      AppLanguage.ar: 'يرجى إدخال اسمك',
    },
    'passwordsDoNotMatch': {
      AppLanguage.en: 'Passwords do not match',
      AppLanguage.ar: 'كلمات المرور غير متطابقة',
    },
    'newPasswordOptional': {
      AppLanguage.en: 'New Password (optional)',
      AppLanguage.ar: 'كلمة المرور الجديدة (اختياري)',
    },
    'updating': {
      AppLanguage.en: 'Updating...',
      AppLanguage.ar: 'جارٍ التحديث...',
    },
    'name': {AppLanguage.en: 'Name', AppLanguage.ar: 'الاسم'},
    'loginSuccess': {
      AppLanguage.en: 'Login successful!',
      AppLanguage.ar: 'تم تسجيل الدخول بنجاح!',
    },
    'unauthenticatedMessage': {
      AppLanguage.en:
          'Your session has expired. Please login again to continue.',
      AppLanguage.ar:
          'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى للمتابعة.',
    },
    'signUp': {AppLanguage.en: 'Sign Up', AppLanguage.ar: 'إنشاء حساب'},
    'fullName': {AppLanguage.en: 'Full name', AppLanguage.ar: 'الاسم الكامل'},
    'dontHaveAcc': {
      AppLanguage.en: 'Don\'t have an account?',
      AppLanguage.ar: 'ليس لديك حساب؟',
    },
    'continueAsGuest': {
      AppLanguage.en: 'Continue as Guest',
      AppLanguage.ar: 'المتابعة كضيف',
    },
    'createAcc': {
      AppLanguage.en: 'Create Account',
      AppLanguage.ar: 'إنشاء حساب',
    },
    'onTitle1': {
      AppLanguage.en: 'Free and secure delivery within 7 days',
      AppLanguage.ar: 'توصيل مجاني وآمن خلال 7 أيام',
    },
    'onDesTitle1': {
      AppLanguage.en:
          'Discover a wide range of original products, all at your fingertips.',
      AppLanguage.ar:
          'اكتشف مجموعة واسعة من المنتجات الأصلية، جميعها بين يديك.',
    },
    'onTitle2': {
      AppLanguage.en:
          'Full protection for your data and transactions on every purchase.',
      AppLanguage.ar: 'حماية كاملة لبياناتك ومعاملاتك في كل عملية شراء .',
    },
    'onDesTitle2': {
      AppLanguage.en:
          'Use smart search to find the right part for your device in seconds.',
      AppLanguage.ar:
          'استخدم البحث الذكي للعثور على القطعة المناسبة لجهازك في ثوانٍ.',
    },
    'onTitle3': {
      AppLanguage.en: 'Subscribe now and become a VIP',
      AppLanguage.ar: 'إشترك الآن وكن VIP',
    },
    'onDesTitle3': {
      AppLanguage.en:
          'Get your orders delivered quickly and safely right to your doorstep.',
      AppLanguage.ar: 'استلم طلباتك بسرعة وأمان حتى باب منزلك.',
    },
    'onTitle4': {
      AppLanguage.en:
          'Shop freely without the need for a subscription or offers',
      AppLanguage.ar: 'تسوق بحرية دون الحاجة إلي إشتراك أو عروض',
    },
    'onDesTitle4': {AppLanguage.en: 'Description 4', AppLanguage.ar: 'الوصف 4'},
    'onTitle5': {
      AppLanguage.en:
          'Products worth 25,000 AED with payment plans up to 24 months under an independent sales agreement. App is for application only.',
      AppLanguage.ar:
          'منتجات بقيمة 25,000 درهم مع ترتيب الدفع لمدة  تصل إلي 24 شهر وفق إتفاقية بيع مستقل .التطبيق للتقديم فقط',
    },
    'onDesTitle5': {AppLanguage.en: 'Description 5', AppLanguage.ar: 'الوصف 5'},
    'onTitle6': {
      AppLanguage.en:
          'Join VIP now and enjoy 20% discounts on payments throughout the subscription period.',
      AppLanguage.ar:
          'إنضم الان لل VIP وتمتع بخصومات %20 عند الدفع طوال مدة الاشتراك .',
    },
    'notifWelcomeTitle': {
      AppLanguage.en: 'Welcome to IAM',
      AppLanguage.ar: 'مرحبا بك في lAM',
    },
    'notifWelcomeBody': {
      AppLanguage.en:
          'Your account has been created successfully. Subscribe now to benefit from discounts and special features.',
      AppLanguage.ar:
          'مرحبا بك في lAM تم إنشاء حسابك بنجاح إشترك الان لتستفيد من الخصومات والمزايا الخاصة',
    },
    'notifSubscribedTitle': {
      AppLanguage.en: 'Subscription Successful',
      AppLanguage.ar: 'تم الاشتراك بنجاح',
    },
    'notifSubscribedBody': {
      AppLanguage.en:
          'Welcome to IAM Premium membership. You can now get a 20% discount on all products and apply for a flexible purchase request.',
      AppLanguage.ar:
          'مرحبا بك في عضوية lAM المميزة ..يمكنك الان الحصول علي خصم %20 علي جميع المنتجات والتقديم علي طلب الشراء المرن',
    },
    'notifOrderAppliedTitle': {
      AppLanguage.en: 'Request Received',
      AppLanguage.ar: 'تم إستلام طلب الشراء',
    },
    'notifOrderAppliedBody': {
      AppLanguage.en:
          'Your purchase request has been received. This request is for application only and does not constitute final approval or a contract. The IAM team will contact you to complete the procedures.',
      AppLanguage.ar:
          'تم إستلام طلب الشراء الخاص بك _ هذا الطلب يعد طلب تقديم فقط ولا يعتبر موافقة نهائية أو عقد سيتم التواصل معك من قبل فريق IAM لاستكمال الاجراءات .',
    },
    'notifOrderAcceptedTitle': {
      AppLanguage.en: 'Request Accepted',
      AppLanguage.ar: 'تم قبول طلبك',
    },
    'notifOrderAcceptedBody': {
      AppLanguage.en:
          'Your request has been successfully accepted. You will be contacted via email to complete the procedures.',
      AppLanguage.ar:
          'تم قبول طلبك بنجاح سيتم التواصل معك عبر البريد الالكتروني لاستكمال الاجراءات',
    },
    'notifOrderRejectedTitle': {
      AppLanguage.en: 'Request Status',
      AppLanguage.ar: 'حالة الطلب',
    },
    'notifOrderRejectedBody': {
      AppLanguage.en:
          'We would like to inform you that after reviewing the request, your request has not been approved at this time. You can resubmit your request later or benefit from our services via instant purchase and enjoy offers through the IAM app.',
      AppLanguage.ar:
          'نود إعلامك بأنه بعد مراجعة الطلب لم تتم الموافقة علي طلبك في الوقت الحالي يمكنك إعادة تقديم طلبك في وقت لاحق أو الاستفادة من خدماتنا عبر الشراء الفوري والتمتع بالعروض من خلال تطبيق IAM',
    },
    'notifCashOrderSuccessTitle': {
      AppLanguage.en: 'Order Received',
      AppLanguage.ar: 'تم إستلام طلبك',
    },
    'notifCashOrderSuccessBody': {
      AppLanguage.en:
          'Your order has been received successfully. You will be contacted by the delivery officer. Expected delivery time is within 5-7 days.',
      AppLanguage.ar:
          'تم إستلام طلبك بنجاح سيتم التواصل معك من قبل مسؤول التسليم . مدة التوصيل المتوقعة خلال 5_7أيام .',
    },
    'skip': {AppLanguage.en: 'Skip', AppLanguage.ar: 'تخطي'},
    'prev': {AppLanguage.en: 'Prev', AppLanguage.ar: 'السابق'},
    'getStarted': {AppLanguage.en: 'Get Started', AppLanguage.ar: 'ابدأ الآن'},
    'next': {AppLanguage.en: 'Next', AppLanguage.ar: 'التالي'},
    'camera': {AppLanguage.en: 'Camera', AppLanguage.ar: 'الكاميرا'},
    'gallery': {AppLanguage.en: 'Gallery', AppLanguage.ar: 'المعرض'},
    'videoAvailable': {
      AppLanguage.en: 'Video Available',
      AppLanguage.ar: 'فيديو متاح',
    },
    'tapToPlay': {
      AppLanguage.en: 'Tap to play',
      AppLanguage.ar: 'اضغط للتشغيل',
    },
    'cart': {AppLanguage.en: 'Cart', AppLanguage.ar: 'السلة'},
    'cartEmpty': {
      AppLanguage.en: 'Your cart is empty',
      AppLanguage.ar: 'سلة التسوق فارغة',
    },
    'addItemsToCart': {
      AppLanguage.en: 'Add items to your cart to see them here',
      AppLanguage.ar: 'أضف عناصر إلى سلة التسوق لتظهر هنا',
    },
    'allProducts': {
      AppLanguage.en: 'All Products',
      AppLanguage.ar: 'كل المنتجات',
    },
    'bestProducts': {
      AppLanguage.en: 'Best Products',
      AppLanguage.ar: 'أفضل المنتجات',
    },
    'viewProducts': {
      AppLanguage.en: 'View Product',
      AppLanguage.ar: 'عرض المنتج',
    },
    'noAvailableProducts': {
      AppLanguage.en: 'No products available',
      AppLanguage.ar: 'لا توجد منتجات متاحة',
    },
    'settings': {AppLanguage.en: 'Settings', AppLanguage.ar: 'الإعدادات'},
    'updateProfile': {
      AppLanguage.en: 'Update Profile',
      AppLanguage.ar: 'تحديث الملف الشخصي',
    },
    'editYourInfo': {
      AppLanguage.en: 'Edit your info',
      AppLanguage.ar: 'عدّل معلوماتك',
    },
    'contactUs': {AppLanguage.en: 'Contact Us', AppLanguage.ar: 'تواصل معنا'},
    'send': {AppLanguage.en: 'Send', AppLanguage.ar: 'إرسال'},
    'sendUsMessage': {
      AppLanguage.en: 'Send us a message',
      AppLanguage.ar: 'أرسل لنا رسالة',
    },
    'logout': {AppLanguage.en: 'Logout', AppLanguage.ar: 'تسجيل الخروج'},
    'logoutConfirmationMessage': {
      AppLanguage.en: 'Are you sure you want to logout?',
      AppLanguage.ar: 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    },
    'cancel': {AppLanguage.en: 'Cancel', AppLanguage.ar: 'إلغاء'},
    'signOutReturn': {
      AppLanguage.en: 'Sign out and return to login',
      AppLanguage.ar: 'سجّل الخروج وعد إلى شاشة الدخول',
    },
    'language': {AppLanguage.en: 'Language', AppLanguage.ar: 'اللغة'},
    'changeLanguage': {
      AppLanguage.en: 'Change the app language',
      AppLanguage.ar: 'غيّر لغة التطبيق',
    },
    'arabic': {AppLanguage.en: 'Arabic', AppLanguage.ar: 'العربية'},
    'english': {AppLanguage.en: 'English', AppLanguage.ar: 'الإنجليزية'},
    'contactInformation': {
      AppLanguage.en: 'Contact Information',
      AppLanguage.ar: 'معلومات التواصل',
    },
    'phone': {AppLanguage.en: 'Phone', AppLanguage.ar: 'الهاتف'},
    'pleaseEnterPhone': {
      AppLanguage.en: 'Please enter your phone number',
      AppLanguage.ar: 'يرجى إدخال رقم هاتفك',
    },
    'shippingAddress': {
      AppLanguage.en: 'Shipping Address',
      AppLanguage.ar: 'عنوان الشحن',
    },
    'addressLine': {
      AppLanguage.en: 'Address Line',
      AppLanguage.ar: 'العنوان التفصيلي',
    },
    'pleaseEnterAddress': {
      AppLanguage.en: 'Please enter your address',
      AppLanguage.ar: 'يرجى إدخال عنوانك',
    },
    'city': {AppLanguage.en: 'City', AppLanguage.ar: 'المدينة'},
    'pleaseEnterCity': {
      AppLanguage.en: 'Please enter city',
      AppLanguage.ar: 'يرجى إدخال المدينة',
    },
    'state': {AppLanguage.en: 'State', AppLanguage.ar: 'الإمارة/الولاية'},
    'pleaseEnterState': {
      AppLanguage.en: 'Please enter state',
      AppLanguage.ar: 'يرجى إدخال الإمارة/الولاية',
    },
    'zipCode': {AppLanguage.en: 'Zip Code', AppLanguage.ar: 'الرمز البريدي'},
    'pleaseEnterZipCode': {
      AppLanguage.en: 'Please enter zip code',
      AppLanguage.ar: 'يرجى إدخال الرمز البريدي',
    },
    'paymentMethod': {
      AppLanguage.en: 'Payment Method',
      AppLanguage.ar: 'طريقة الدفع',
    },
    'card': {AppLanguage.en: 'Card', AppLanguage.ar: 'بطاقة'},
    'cash': {AppLanguage.en: 'Cash', AppLanguage.ar: 'نقداً'},
    'promoCodeOptional': {
      AppLanguage.en: 'Promo Code (Optional)',
      AppLanguage.ar: 'رمز الخصم (اختياري)',
    },
    'enterPromoCode': {
      AppLanguage.en: 'Enter promo code',
      AppLanguage.ar: 'أدخل رمز الخصم',
    },
    'applyPromoCode': {
      AppLanguage.en: 'Apply',
      AppLanguage.ar: 'تطبيق',
    },
    'couponApplied': {
      AppLanguage.en: 'Coupon applied successfully',
      AppLanguage.ar: 'تم تطبيق رمز الخصم بنجاح',
    },
    'invalidPromoCode': {
      AppLanguage.en: 'Invalid or expired promo code',
      AppLanguage.ar: 'رمز الخصم غير صالح أو منتهي الصلاحية',
    },
    'processing': {
      AppLanguage.en: 'Processing...',
      AppLanguage.ar: 'جارٍ المعالجة...',
    },
    'placeOrder': {
      AppLanguage.en: 'Place Order',
      AppLanguage.ar: 'إتمام الطلب',
    },
    'search': {AppLanguage.en: 'Search', AppLanguage.ar: 'بحث'},
    'searchProductsHint': {
      AppLanguage.en: 'Search products...',
      AppLanguage.ar: 'ابحث عن المنتجات...',
    },
    'startTypingToSearchProducts': {
      AppLanguage.en: 'Start typing to search products',
      AppLanguage.ar: 'ابدأ بالكتابة للبحث عن المنتجات',
    },
    'noResultsFound': {
      AppLanguage.en: 'No results found',
      AppLanguage.ar: 'لا توجد نتائج',
    },
    'wishlist': {AppLanguage.en: 'Wishlist', AppLanguage.ar: 'المفضلة'},
    'favorites': {AppLanguage.en: 'Favorites', AppLanguage.ar: 'المفضلة'},
    'home': {AppLanguage.en: 'Home', AppLanguage.ar: 'الرئيسية'},
    'retry': {AppLanguage.en: 'Retry', AppLanguage.ar: 'إعادة المحاولة'},
    'wishlistEmpty': {
      AppLanguage.en: 'Your wishlist is empty',
      AppLanguage.ar: 'قائمة المفضلة فارغة',
    },
    'addItemsToWishlist': {
      AppLanguage.en: 'Add items to your wishlist to see them here',
      AppLanguage.ar: 'أضف عناصر إلى قائمة المفضلة لتظهر هنا',
    },
    'addReview': {AppLanguage.en: 'Add Review', AppLanguage.ar: 'إضافة مراجعة'},
    'pleaseSelectRating': {
      AppLanguage.en: 'Please select a rating',
      AppLanguage.ar: 'يرجى اختيار التقييم',
    },
    'rateThisProduct': {
      AppLanguage.en: 'Rate this product',
      AppLanguage.ar: 'قيّم هذا المنتج',
    },
    'writeYourReview': {
      AppLanguage.en: 'Write your review',
      AppLanguage.ar: 'اكتب مراجعتك',
    },
    'shareYourExperience': {
      AppLanguage.en: 'Share your experience...',
      AppLanguage.ar: 'شاركنا تجربتك...',
    },
    'pleaseWriteReview': {
      AppLanguage.en: 'Please write a review',
      AppLanguage.ar: 'يرجى كتابة مراجعة',
    },
    'reviewMinCharacters': {
      AppLanguage.en: 'Review must be at least 10 characters',
      AppLanguage.ar: 'يجب أن تحتوي المراجعة على 10 أحرف على الأقل',
    },
    'submitting': {
      AppLanguage.en: 'Submitting...',
      AppLanguage.ar: 'جارٍ الإرسال...',
    },
    'submitReview': {
      AppLanguage.en: 'Submit Review',
      AppLanguage.ar: 'إرسال المراجعة',
    },
    'description': {AppLanguage.en: 'Description', AppLanguage.ar: 'الوصف'},
    'productDetails': {
      AppLanguage.en: 'Product Details',
      AppLanguage.ar: 'تفاصيل المنتج',
    },
    'brand': {AppLanguage.en: 'Brand', AppLanguage.ar: 'العلامة التجارية'},
    'productNumber': {
      AppLanguage.en: 'Product Number',
      AppLanguage.ar: 'رقم المنتج',
    },
    'copied': {AppLanguage.en: 'copied', AppLanguage.ar: 'تم النسخ'},
    'price': {AppLanguage.en: 'Price', AppLanguage.ar: 'السعر'},
    'type': {AppLanguage.en: 'Type', AppLanguage.ar: 'النوع'},
    'color': {AppLanguage.en: 'Color', AppLanguage.ar: 'اللون'},
    'quantityAvailable': {
      AppLanguage.en: 'Quantity Available',
      AppLanguage.ar: 'الكمية المتاحة',
    },
    'inCart': {AppLanguage.en: 'In Cart', AppLanguage.ar: 'في السلة'},
    'addToCart': {
      AppLanguage.en: 'Add to Cart',
      AppLanguage.ar: 'أضف إلى السلة',
    },
    'addingToCart': {
      AppLanguage.en: 'Adding to Cart...',
      AppLanguage.ar: 'جارٍ الإضافة إلى السلة...',
    },
    'reviewsTitle': {AppLanguage.en: 'Reviews', AppLanguage.ar: 'المراجعات'},
    'reviewsCountLabel': {AppLanguage.en: 'reviews', AppLanguage.ar: 'مراجعات'},
    'writeAReview': {
      AppLanguage.en: 'Write a Review',
      AppLanguage.ar: 'اكتب مراجعة',
    },
    'anonymous': {AppLanguage.en: 'Anonymous', AppLanguage.ar: 'مجهول'},
    'failedToUpdateCart': {
      AppLanguage.en: 'Failed to update cart',
      AppLanguage.ar: 'فشل تحديث السلة',
    },
    'off': {AppLanguage.en: 'Off', AppLanguage.ar: 'خصم'},
    'invoice': {AppLanguage.en: 'Invoice', AppLanguage.ar: 'فاتورة'},
    'order': {AppLanguage.en: 'Order', AppLanguage.ar: 'طلب'},
    'orderInformation': {
      AppLanguage.en: 'Order Information',
      AppLanguage.ar: 'معلومات الطلب',
    },
    'orderNumberLabel': {
      AppLanguage.en: 'Order Number',
      AppLanguage.ar: 'رقم الطلب',
    },
    'orderDate': {AppLanguage.en: 'Date', AppLanguage.ar: 'التاريخ'},
    'customer': {AppLanguage.en: 'Customer', AppLanguage.ar: 'العميل'},
    'paymentInformation': {
      AppLanguage.en: 'Payment Information',
      AppLanguage.ar: 'معلومات الدفع',
    },
    'paymentStatus': {
      AppLanguage.en: 'Payment Status',
      AppLanguage.ar: 'حالة الدفع',
    },
    'promoCode': {AppLanguage.en: 'Promo Code', AppLanguage.ar: 'رمز الخصم'},
    'orderItems': {
      AppLanguage.en: 'Order Items',
      AppLanguage.ar: 'عناصر الطلب',
    },
    'quantity': {AppLanguage.en: 'Qty', AppLanguage.ar: 'الكمية'},
    'paid': {AppLanguage.en: 'Paid', AppLanguage.ar: 'مدفوع'},
    'pending': {AppLanguage.en: 'Pending', AppLanguage.ar: 'قيد الانتظار'},
    'cancelOrder': {
      AppLanguage.en: 'Cancel Order',
      AppLanguage.ar: 'إلغاء الطلب',
    },
    'deleteOrder': {
      AppLanguage.en: 'Delete Order',
      AppLanguage.ar: 'حذف الطلب',
    },
    'confirmCancelOrder': {
      AppLanguage.en: 'Confirm Cancellation',
      AppLanguage.ar: 'تأكيد الإلغاء',
    },
    'cancelOrderConfirmationMessage': {
      AppLanguage.en: 'Are you sure you want to cancel this order?',
      AppLanguage.ar: 'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟',
    },
    'confirmDeleteOrder': {
      AppLanguage.en: 'Confirm Deletion',
      AppLanguage.ar: 'تأكيد الحذف',
    },
    'deleteOrderConfirmationMessage': {
      AppLanguage.en: 'Are you sure you want to delete this order?',
      AppLanguage.ar: 'هل أنت متأكد أنك تريد حذف هذا الطلب؟',
    },
    'orderCancelledSuccess': {
      AppLanguage.en: 'Order cancelled successfully.',
      AppLanguage.ar: 'تم إلغاء الطلب بنجاح.',
    },
    'orderDeletedSuccess': {
      AppLanguage.en: 'Order deleted successfully.',
      AppLanguage.ar: 'تم حذف الطلب بنجاح.',
    },
    'orderNotLoaded': {
      AppLanguage.en: 'Order data is not available yet.',
      AppLanguage.ar: 'بيانات الطلب غير متاحة بعد.',
    },
    'orderSuccessTitle': {
      AppLanguage.en: 'Order Details',
      AppLanguage.ar: 'تفاصيل الطلب',
    },
    'orderPlacedSuccessfully': {
      AppLanguage.en: 'Your order has been placed successfully.',
      AppLanguage.ar: 'تم تقديم طلبك بنجاح.',
    },
    'viewInvoice': {
      AppLanguage.en: 'View Invoice',
      AppLanguage.ar: 'عرض الفاتورة',
    },
    'downloadInvoice': {
      AppLanguage.en: 'Download Invoice',
      AppLanguage.ar: 'تحميل الفاتورة',
    },
    'backToHome': {
      AppLanguage.en: 'Back to Home',
      AppLanguage.ar: 'العودة للرئيسية',
    },
    'downloading': {
      AppLanguage.en: 'Downloading...',
      AppLanguage.ar: 'جارٍ التحميل...',
    },
    'invoiceDownloaded': {
      AppLanguage.en: 'Invoice downloaded successfully.',
      AppLanguage.ar: 'تم تنزيل الفاتورة بنجاح.',
    },
    'downloadFailed': {
      AppLanguage.en: 'Failed to download invoice. Please try again.',
      AppLanguage.ar: 'فشل تنزيل الفاتورة. يرجى المحاولة مرة أخرى.',
    },
    'close': {AppLanguage.en: 'Close', AppLanguage.ar: 'إغلاق'},
    'deleteAccount': {
      AppLanguage.en: 'Delete Account',
      AppLanguage.ar: 'حذف الحساب',
    },
    'deleteAccountConfirmationTitle': {
      AppLanguage.en: 'Confirm Account Deletion',
      AppLanguage.ar: 'تأكيد حذف الحساب',
    },
    'deleteAccountConfirmationMessage': {
      AppLanguage.en:
          'This action is permanent. Do you really want to delete your account?',
      AppLanguage.ar: 'هذا الإجراء نهائي. هل تريد بالتأكيد حذف حسابك؟',
    },
    'deleteAccountSuccess': {
      AppLanguage.en: 'Account deleted successfully.',
      AppLanguage.ar: 'تم حذف الحساب بنجاح.',
    },
    'shopWithConfidence': {
      AppLanguage.en: 'Shop with confidence',
      AppLanguage.ar: 'تسوق بثقة',
    },
    'secureTransaction': {
      AppLanguage.en: 'Secure transaction',
      AppLanguage.ar: 'معاملتك آمنة',
    },
    'safeDelivery': {
      AppLanguage.en: 'Safe delivery',
      AppLanguage.ar: 'توصيلك آمن',
    },
    'returnIn15Days': {
      AppLanguage.en: '15-day return',
      AppLanguage.ar: '١٥ يوم للارجاع',
    },
    'freeDelivery': {
      AppLanguage.en: 'Free delivery',
      AppLanguage.ar: 'توصيل مجاني',
    },
    'oneYearWarranty': {
      AppLanguage.en: '1-year warranty',
      AppLanguage.ar: 'ضمان لمدة عام',
    },
    'age': {AppLanguage.en: 'Age', AppLanguage.ar: 'العمر'},
    'pleaseEnterAge': {
      AppLanguage.en: 'Please enter your age',
      AppLanguage.ar: 'يرجى إدخال عمرك',
    },
    'gender': {AppLanguage.en: 'Gender', AppLanguage.ar: 'الجنس'},
    'pleaseSelectGender': {
      AppLanguage.en: 'Please select gender',
      AppLanguage.ar: 'يرجى اختيار الجنس',
    },
    'male': {AppLanguage.en: 'Male', AppLanguage.ar: 'ذكر'},
    'female': {AppLanguage.en: 'Female', AppLanguage.ar: 'أنثى'},
    'country': {AppLanguage.en: 'Country', AppLanguage.ar: 'الدولة'},
    'pleaseEnterCountry': {
      AppLanguage.en: 'Please enter country',
      AppLanguage.ar: 'يرجى إدخال الدولة',
    },
    'termsAndConditions': {
      AppLanguage.en: 'Terms and Conditions',
      AppLanguage.ar: 'الشروط والأحكام',
    },
    'acceptTermsAndConditions': {
      AppLanguage.en: 'I accept the Terms and Conditions',
      AppLanguage.ar: 'أوافق على الشروط والأحكام',
    },
    'pleaseAcceptTerms': {
      AppLanguage.en: 'Please accept the Terms and Conditions',
      AppLanguage.ar: 'يرجى الموافقة على الشروط والأحكام',
    },
    'accountCreatedSuccess': {
      AppLanguage.en: 'Account created successfully!',
      AppLanguage.ar: 'تم إنشاء الحساب بنجاح!',
    },
    'pleaseConfirmPassword': {
      AppLanguage.en: 'Please confirm your password',
      AppLanguage.ar: 'يرجى تأكيد كلمة المرور',
    },
    'passwordMinLength': {
      AppLanguage.en: 'Password must be at least 6 characters',
      AppLanguage.ar: 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    },
    'validAge': {
      AppLanguage.en: 'Please enter a valid age',
      AppLanguage.ar: 'يرجى إدخال عمر صحيح',
    },
    'creating': {
      AppLanguage.en: 'Creating...',
      AppLanguage.ar: 'جارٍ الإنشاء...',
    },
    'idImage': {
      AppLanguage.en: 'ID Image',
      AppLanguage.ar: 'الهوية او جواز السفر',
    },
    'pleaseUploadIdImage': {
      AppLanguage.en: 'Please upload ID image',
      AppLanguage.ar: 'يرجى رفع صورة الهوية',
    },
    'bankStatementImage': {
      AppLanguage.en: 'Bank Statement Image',
      AppLanguage.ar: 'اوراق اخرى',
    },
    'invoiceImage': {
      AppLanguage.en: 'Invoice Image',
      AppLanguage.ar: 'صورة الفاتورة',
    },
    'installment': {
      AppLanguage.en: 'Flexible Purchase Request',
      AppLanguage.ar: 'طلب شراء مرن',
    },
    'selectInstallmentMonths': {
      AppLanguage.en: 'Number of Installments',
      AppLanguage.ar: 'عدد الدفعات',
    },
    'installmentMonths': {
      AppLanguage.en: 'Contractual Commitment Period',
      AppLanguage.ar: 'مدة الالتزام التعاقدي',
    },
    'originalAmount': {
      AppLanguage.en: 'Original Amount',
      AppLanguage.ar: 'المبلغ الأصلي',
    },
    'increaseAmount': {
      AppLanguage.en: 'Installment Sale Price',
      AppLanguage.ar: 'سعر البيع بالتقسيط',
    },
    'totalAmount': {
      AppLanguage.en: 'Total Amount',
      AppLanguage.ar: 'المبلغ الإجمالي',
    },
    'months': {AppLanguage.en: 'months', AppLanguage.ar: 'شهر'},
    'updateYourData': {
      AppLanguage.en: 'Update Your Data',
      AppLanguage.ar: 'تحديث بياناتك',
    },
    'pleaseUpdateYourData': {
      AppLanguage.en:
          'Please update your data to complete your order. You need to upload your ID image.',
      AppLanguage.ar:
          'يرجى تحديث بياناتك لإتمام طلبك. تحتاج إلى رفع صورة الهوية.',
    },
    'uploadMissingImages': {
      AppLanguage.en: 'Upload Missing Images',
      AppLanguage.ar: 'رفع الصور المفقودة',
    },
    'pleaseUploadMissingImages': {
      AppLanguage.en:
          'Please upload the missing images (Bank Statement and/or Invoice) to complete your order.',
      AppLanguage.ar:
          'يرجى رفع الصور المفقودة (كشف الحساب و/أو الفاتورة) لإتمام طلبك.',
    },
    'dataUnderReview': {
      AppLanguage.en: 'Data Under Review',
      AppLanguage.ar: 'بياناتك قيد المراجعة',
    },
    'dataUnderReviewMessage': {
      AppLanguage.en: 'Your account is currently under review. The installment feature will be available once your verification is completed. We will notify you as soon as it is approved.',
      AppLanguage.ar: 'حسابك قيد المراجعة حالياً. سيتم تفعيل ميزة التقسيط بعد الانتهاء من التحقق من بياناتك. سنقوم بإشعارك فور الموافقة.',
    },
    'goToUpdateProfile': {
      AppLanguage.en: 'Go to Update Profile',
      AppLanguage.ar: 'الذهاب لتحديث الملف الشخصي',
    },
    'ok': {AppLanguage.en: 'OK', AppLanguage.ar: 'حسناً'},
    'confirmWhatsApp': {
      AppLanguage.en: 'Confirm WhatsApp',
      AppLanguage.ar: 'تأكيد وتساب',
    },
    'phoneWithWhatsApp': {
      AppLanguage.en: 'Phone number (Confirm WhatsApp)',
      AppLanguage.ar: 'رقم الهاتف (تأكيد وتساب)',
    },
    'pleaseSelectCountry': {
      AppLanguage.en: 'Please select country',
      AppLanguage.ar: 'يرجى اختيار الدولة',
    },
    'ageRange': {
      AppLanguage.en: 'Age must be between 21 and 55',
      AppLanguage.ar: 'يجب أن يكون العمر بين 21 و 55',
    },
    'verifyOtp': {
      AppLanguage.en: 'Verify OTP',
      AppLanguage.ar: 'التحقق من رمز OTP',
    },
    'enterOtp': {AppLanguage.en: 'Enter OTP', AppLanguage.ar: 'أدخل رمز OTP'},
    'pleaseEnterOtp': {
      AppLanguage.en: 'Please enter OTP',
      AppLanguage.ar: 'يرجى إدخال رمز OTP',
    },
    'otpMustBe6Digits': {
      AppLanguage.en: 'OTP must be 6 digits',
      AppLanguage.ar: 'يجب أن يكون رمز OTP 6 أرقام',
    },
    'enter6DigitCodeSentToEmail': {
      AppLanguage.en: 'Please enter your email to reset password',
      AppLanguage.ar: 'يرجى إدخال بريدك الإلكتروني لإعادة تعيين كلمة المرور',
    },
    'verifying': {
      AppLanguage.en: 'Verifying...',
      AppLanguage.ar: 'جارٍ التحقق...',
    },
    'otpVerifiedSuccess': {
      AppLanguage.en: 'OTP verified successfully!',
      AppLanguage.ar: 'تم التحقق من رمز OTP بنجاح!',
    },
    'forgetPassword': {
      AppLanguage.en: 'Forgot Password?',
      AppLanguage.ar: 'نسيت كلمة المرور؟',
    },
    'resetPassword': {
      AppLanguage.en: 'Reset Password',
      AppLanguage.ar: 'إعادة تعيين كلمة المرور',
    },
    'resetPasswordTitle': {
      AppLanguage.en: 'Reset Your Password',
      AppLanguage.ar: 'إعادة تعيين كلمة المرور',
    },
    'resetPasswordDescription': {
      AppLanguage.en: 'Please enter your new password',
      AppLanguage.ar: 'يرجى إدخال كلمة المرور الجديدة',
    },
    'newPassword': {
      AppLanguage.en: 'New Password',
      AppLanguage.ar: 'كلمة المرور الجديدة',
    },
    'pleaseEnterNewPassword': {
      AppLanguage.en: 'Please enter new password',
      AppLanguage.ar: 'يرجى إدخال كلمة المرور الجديدة',
    },
    'passwordResetSuccess': {
      AppLanguage.en: 'Password reset successfully!',
      AppLanguage.ar: 'تم إعادة تعيين كلمة المرور بنجاح!',
    },
    'sendingOtp': {
      AppLanguage.en: 'Sending OTP...',
      AppLanguage.ar: 'جارٍ إرسال رمز التحقق...',
    },
    'resettingPassword': {
      AppLanguage.en: 'Resetting Password...',
      AppLanguage.ar: 'جارٍ إعادة تعيين كلمة المرور...',
    },
    'notifications': {
      AppLanguage.en: 'Notifications',
      AppLanguage.ar: 'الإشعارات',
    },
    'accountUnderReview': {
      AppLanguage.en:
          'Your installment request is currently under review. You will be notified once the evaluation is complete.',
      AppLanguage.ar:
          'طلب التقسيط الخاص بك قيد المراجعة حاليًا.\nسيتم إشعارك فور الانتهاء من التقييم.',
    },
    'vipFeatureTitle': {
      AppLanguage.en: 'VIP Only',
      AppLanguage.ar: 'لمشتركي VIP فقط',
    },
    'vipFeatureMessage': {
      AppLanguage.en:
          'This feature is available to VIP subscribers only. Please subscribe to the VIP package to enjoy all exclusive benefits.',
      AppLanguage.ar:
          'هذه الميزة متاحة لمشتركي VIP فقط. يرجى الاشتراك في باقة VIP للاستفادة من جميع المزايا الحصرية.',
    },
    'subscribeToVipNow': {
      AppLanguage.en: 'Subscribe to VIP now',
      AppLanguage.ar: 'اشترك الان في VIP',
    },
    'accountApproved': {
      AppLanguage.en: 'Account approved',
      AppLanguage.ar: 'تم الموافقة على الحساب',
    },
    'accountRejected': {
      AppLanguage.en: 'Account rejected',
      AppLanguage.ar: 'تم رفض الحساب',
    },
    'noNotifications': {
      AppLanguage.en: 'No notifications',
      AppLanguage.ar: 'لا توجد إشعارات',
    },
    'markAllAsRead': {
      AppLanguage.en: 'Mark all as read',
      AppLanguage.ar: 'تحديد الكل كمقروء',
    },
    'accountUnderReviewTitle': {
      AppLanguage.en: '⏳ Request Under Review',
      AppLanguage.ar: '⏳ طلبك قيد المراجعة',
    },
    'accountApprovedTitle': {
      AppLanguage.en: '✅ VIP Subscription Activated Successfully',
      AppLanguage.ar: 'تم تفعيل اشتراك VIP بنجاح',
    },
    'accountRejectedTitle': {
      AppLanguage.en: '❌ Installment Request Not Approved',
      AppLanguage.ar: '❌ تعذر قبول طلب التقسيط',
    },
    'accountApprovedMessage': {
      AppLanguage.en:
          'We would like to inform you that your IAM VIP subscription has been successfully activated.\nYou can now enjoy all membership benefits, including the ability to place flexible purchase requests and take advantage of all exclusive discounts within the app.',
      AppLanguage.ar:
          'نود إعلامك بأنه تم تفعيل اشتراكك في IAM VIP بنجاح.\nيمكنك الآن الاستفادة من جميع مزايا العضوية، بما في ذلك إمكانية طلب الشراء بالأجل و الاستفاده من جميع الخصومات الحصرية داخل التطبيق.',
    },
    'accountRejectedMessage': {
      AppLanguage.en:
          'We regret to inform you that your installment request has not been approved at this time based on the evaluation results. You can reapply later or contact support for more details.',
      AppLanguage.ar:
          'نأسف لإبلاغك بأنه لم يتم قبول طلب التقسيط حاليًا بناءً على نتائج التقييم.\nيمكنك إعادة التقديم لاحقًا أو التواصل مع الدعم لمزيد من التفاصيل',
    },
    'additionalDocumentsRequiredTitle': {
      AppLanguage.en: '📄 Additional Documents Required',
      AppLanguage.ar: '📄 مطلوب مستندات إضافية',
    },
    'additionalDocumentsRequiredMessage': {
      AppLanguage.en:
          'Please upload additional documents such as a bank statement or phone bill with a detailed address to complete the review of your installment request. You can upload the required documents through the "Documents" page.',
      AppLanguage.ar:
          'يرجى رفع مستندات إضافية مثل كشف حساب بنكي او فتورة هاتف مذكور فيها العنوان با التفصيل لاستكمال دراسة طلب التقسيط الخاص بك.\nيمكنك رفع الأوراق المطلوبة من خلال صفحة "المستندات".',
    },
    'uploadDocuments': {
      AppLanguage.en: '📤 Upload Documents',
      AppLanguage.ar: '📤 رفع المستندات',
    },
    'documentsNotClearTitle': {
      AppLanguage.en: '⚠️ Documents Not Clear',
      AppLanguage.ar: '⚠️ المستندات غير واضحة',
    },
    'documentsNotClearMessage': {
      AppLanguage.en:
          'The documents you uploaded are not clear or incomplete. Please re-upload clear images of the required documents to ensure prompt review.',
      AppLanguage.ar:
          'المستندات التي قمت برفعها غير واضحة أو غير مكتملة.\nيرجى إعادة رفع صور واضحة للمستندات المطلوبة لضمان سرعة المراجعة.',
    },
    'installmentRequestExpiredTitle': {
      AppLanguage.en: '⌛ Request Expired',
      AppLanguage.ar: '⌛ انتهت صلاحية الطلب',
    },
    'installmentRequestExpiredMessage': {
      AppLanguage.en:
          'Your installment request has expired due to failure to complete the required documents within the specified period. You can reapply at any time.',
      AppLanguage.ar:
          'انتهت صلاحية طلب التقسيط بسبب عدم استكمال المستندات خلال الفترة المحددة.\nيمكنك إعادة التقديم في أي وقت.',
    },
    'creditLimitUpdatedTitle': {
      AppLanguage.en: '💳 Credit Limit Updated',
      AppLanguage.ar: '💳 تحديث الحد الائتماني',
    },
    'creditLimitUpdatedMessage': {
      AppLanguage.en:
          'Your credit limit has been updated.\nCurrent available limit: {{amount}}',
      AppLanguage.ar:
          'تم تحديث الحد الائتماني الخاص بك.\nالحد المتاح حاليًا: {{المبلغ}}',
    },
    'installmentServiceSuspendedTitle': {
      AppLanguage.en: '🚫 Installment Service Temporarily Suspended',
      AppLanguage.ar: '🚫 تم إيقاف خدمة التقسيط مؤقتًا',
    },
    'installmentServiceSuspendedMessage': {
      AppLanguage.en:
          'The installment service has been temporarily suspended for your account. Please contact support for more details.',
      AppLanguage.ar:
          'تم إيقاف خدمة التقسيط مؤقتًا لحسابك.\nيرجى التواصل مع الدعم لمزيد من التفاصيل.',
    },
    'shareApp': {AppLanguage.en: 'Share App', AppLanguage.ar: 'مشاركة التطبيق'},
    'shareAppMessage': {
      AppLanguage.en: 'Check out IAM Store app!',
      AppLanguage.ar: 'جرب تطبيق IAM Store!',
    },
    'now': {AppLanguage.en: 'Now', AppLanguage.ar: 'الآن'},
    'minutesAgo': {
      AppLanguage.en: 'minutes ago',
      AppLanguage.ar: 'منذ %minutes% دقيقة',
    },
    'hoursAgo': {
      AppLanguage.en: 'hours ago',
      AppLanguage.ar: 'منذ %hours% ساعة',
    },
    'yesterday': {AppLanguage.en: 'Yesterday', AppLanguage.ar: 'أمس'},
    'daysAgo': {AppLanguage.en: 'days ago', AppLanguage.ar: 'منذ %days% أيام'},
    'resellProduct': {
      AppLanguage.en: 'Resell Product',
      AppLanguage.ar: 'إعادة بيع المنتج',
    },
    'resellProductSubtitle': {
      AppLanguage.en: 'Sell products you purchased from the app only',
      AppLanguage.ar: 'أنه يبيع المنتج الذي اشتراه من التطبيق فقط ليس إلا',
    },
    'productSubmittedSuccess': {
      AppLanguage.en: 'Product submitted successfully',
      AppLanguage.ar: 'تم إرسال المنتج بنجاح',
    },
    'submit': {AppLanguage.en: 'Submit', AppLanguage.ar: 'إرسال'},
    'pleaseEnterProductName': {
      AppLanguage.en: 'Please enter product name',
      AppLanguage.ar: 'يرجى إدخال اسم المنتج',
    },
    'pleaseEnterDescription': {
      AppLanguage.en: 'Please enter product description',
      AppLanguage.ar: 'يرجى إدخال وصف المنتج',
    },
    'descriptionMustBeAtLeast10Characters': {
      AppLanguage.en: 'Description must be at least 10 characters',
      AppLanguage.ar: 'يجب أن يكون الوصف على الأقل 10 أحرف',
    },
    'pleaseEnterPrice': {
      AppLanguage.en: 'Please enter product price',
      AppLanguage.ar: 'يرجى إدخال سعر المنتج',
    },
    'pleaseEnterValidPrice': {
      AppLanguage.en: 'Please enter a valid price',
      AppLanguage.ar: 'يرجى إدخال سعر صحيح',
    },
    'pleaseEnterProductNumber': {
      AppLanguage.en: 'Please enter product number',
      AppLanguage.ar: 'يرجى إدخال رقم المنتج',
    },
    'termsAndConditionsLastUpdate': {
      AppLanguage.en: 'Last updated: December 20, 2025',
      AppLanguage.ar: 'آخر تحديث: 20 / 12/ 2025',
    },
    'readTermsAndConditions': {
      AppLanguage.en: 'I have read and agree to the Terms and Conditions',
      AppLanguage.ar: 'أوافق على الشروط والأحكام',
    },
    'termsAndConditionsContent': {
      AppLanguage.en: '''Terms & Conditions 🔶️
IAM Smart Store

_ Company Information
_ App / Platform Name: IAM Smart Store
_ Owner & Operator: IAM SOFTWARE PUBLISHING - L.L.C - S.P.S
_ Country / Emirate: United Arab Emirates – Abu Dhabi
_ Commercial Registration No.: CN-6154365
_ Official Email: iamsoftwarepublishing@gmail.com

1/ Scope and Acceptance
_ By using the App, creating an account, browsing products, or submitting any request, you confirm that you have read, understood, and agreed to these Terms & Conditions.
_ If you do not agree with any part of these Terms, you must stop using the App immediately.

2/ Definitions
_ App / Platform: IAM Smart Store application.
_ Company: IAM SOFTWARE PUBLISHING - L.L.C - S.P.S.
_ User / Customer / Consumer: Any person who uses the App, purchases, or submits a request.
_ Products: All goods and devices displayed and owned by the Company.
_ Subscription: A paid membership that grants marketing benefits such as discounts and offers and is not part of any product price.
_ Cash Purchase: Full payment of the product price in one single payment.
_ Flexible Purchase Request: A non-binding request submitted by a subscriber to study a possible later purchase outside the App under a separate contract.

3/ Legal Nature
_ The App is an e-commerce platform for displaying and selling products.
_ The App and the Company do not provide financing, installments, BNPL, loans, or any credit or banking services.
_ All purchases inside the App are cash purchases with full payment only. Any special arrangements occur outside the App under a separate independent contract.

4/ Approved Purchase Methods
4-1) Cash Purchase without Subscription
_ Users may purchase products at the full listed price with immediate full payment. No discounts or additional benefits apply.
4-2) Cash Purchase with Subscription and Discounts
_ Subscribers may access discounts, but all payments remain full and cash only. Subscription is not part of the product price and does not create financing.
4-3) Flexible Purchase Request (Subscribers Only)
_ Available only to subscribers. Requests are non-binding and not contracts.
_ Submitting a flexible purchase request does not create any obligation on the Company.
_ The Company does not guarantee approval and reserves the right to reject any request without justification. If approved, the process occurs outside the App under a separate contract. No financing – No installments – No BNPL.

5/ Accounts and Use
_ Users must use the App lawfully and keep credentials secure.

6/ Prices, Invoices, and Taxes
_ Prices are valid at the time of ordering.
_ The Company reserves the right to change prices before confirming any order.
_ Invoices are issued according to UAE regulations.

7/ Consumer Protection
_ The Company complies with UAE consumer protection laws.
_ Consumers have the right to products matching their description, free from material defects, and covered by warranty if applicable.

8/ Return and Exchange Policy
_ Return period: 14 days from delivery.
_ Product must be unused and in original condition and packaging. Subscriptions are non-refundable after activation.
_ Refunds (if approved) will be processed within a reasonable time according to applicable procedures.

9/ Delivery and Address
_ User is responsible for providing a correct delivery address.
_ Return period starts from the confirmed delivery date recorded by the delivery or shipping company.

10/ Warranty and After-Sales
_ Warranty applies as per its terms provided by the Company or the manufacturer.
_ Warranty does not cover misuse, negligence, accidents, breakage, or unauthorized modifications.

11/ Complaints and Support
_ Complaints and support requests can be submitted via the official email: iamsoftwarepublishing@gmail.com
_ The Company will respond and attempt to resolve the issue within a reasonable time.

12/ Privacy and Data Protection
_ The Company protects user data in accordance with applicable UAE laws.
_ Data is used only for operational, legal, and regulatory purposes related to providing the services.

13/ Cybersecurity
_ Any illegal or abusive use of the App, including hacking or tampering attempts, is strictly prohibited.
_ The Company reserves the right to take appropriate legal action against any violator.

14/ Limitation of Liability
_ The App is provided “as is”.
_ The Company shall not be liable for any indirect, incidental, or consequential damages to the maximum extent permitted by law.

15/ Intellectual Property
_ All rights related to the App name, trademarks, content, design, and software belong to the Company or are licensed to it.
_ No part of the App or its content may be copied or reused without prior written consent.

16/ Amendments
_ The Company may amend these Terms & Conditions at any time as it deems appropriate.
_ Continued use of the App after publishing the amendments constitutes acceptance.

17/ Governing Law and Jurisdiction
_ These Terms & Conditions are governed by the laws of the United Arab Emirates.
_ The competent UAE courts have exclusive jurisdiction over any dispute.

18/ General Provisions
_ If any provision of these Terms is invalid, the remaining provisions remain in force.
_ Headings are for convenience only and do not affect interpretation.

19/ Technical & Pricing Errors
_ The Company reserves the right to cancel or reject any order in case of a technical or pricing error.
_ The Company is not obliged to honor any order resulting from an obvious or unintended error.

20/ Right to Refuse Service or Suspend Accounts
_ The Company reserves the right to refuse service, suspend, or delete an account in case of misuse or illegal activity.

21/ Marketing Content & Illustrations
_ All images and descriptions are for illustrative and marketing purposes only. Actual specifications may vary slightly.

22/ No Marketing Commitment
_ No advertising or promotional content in the App shall be considered binding unless officially confirmed.

23/ Force Majeure
_ The Company shall not be liable for any delay or failure caused by events beyond its reasonable control such as natural disasters, government actions, or system failures.

24/ Additional Limitation of Liability
_ The Company shall not be liable for loss of profits, data, or any indirect damages.

25/ No Partnership or Agency
_ Use of the App does not create any partnership, agency, or joint venture between the user and the Company.

26/ Prevailing Language
_ In case of any discrepancy between the Arabic and English versions, the Arabic version shall prevail.

27/ Official Notices
_ Communications via the official email are considered valid legal notices between the Company and the User.

User Agreement Confirmation
_ By clicking “Agree”, you acknowledge that you have read, understood, and accepted these Terms & Conditions without limitation, condition, or reservation.''',
      AppLanguage.ar: '''الشروط والأحكام 🔶️
IAM Smart Store

_ معلومات الشركة
_ اسم التطبيق / المنصة: IAM Smart Store
_ المالك والمشغّل: IAM SOFTWARE PUBLISHING - L.L.C - S.P.S
_ الدولة / الإمارة: الإمارات العربية المتحدة – أبوظبي
_ رقم السجل التجاري: CN-6154365
_ البريد الإلكتروني الرسمي: iamsoftwarepublishing@gmail.com

١/ نطاق التطبيق والموافقة
_ باستخدامك للتطبيق أو إنشاء حساب أو تصفح المنتجات أو تقديم أي طلب، فإنك تقر بأنك قرأت هذه الشروط والأحكام وفهمتها ووافقت عليها بالكامل.
_ إذا كنت لا توافق على أي بند، يجب عليك التوقف فورًا عن استخدام التطبيق.

2/ التعريفات
_ التطبيق / المنصة: تطبيق IAM Smart Store.
_ الشركة: IAM SOFTWARE PUBLISHING - L.L.C - S.P.S.
_ المستخدم / العميل / المستهلك: كل من يستخدم التطبيق أو يشتري أو يقدّم طلبًا.
_ المنتجات: جميع السلع والأجهزة المعروضة والمملوكة للشركة.
_ الاشتراك: عضوية مدفوعة تمنح مزايا تسويقية مثل الخصومات والعروض، ولا تُعد جزءًا من ثمن أي منتج.
_ الشراء النقدي: دفع كامل ثمن المنتج دفعة واحدة.
_ طلب الشراء المرن: طلب غير ملزم يقدّمه المشترك لدراسة شراء لاحق خارج التطبيق بموجب عقد مستقل.

3/ الطبيعة القانونية للتطبيق
_ التطبيق منصة تجارة إلكترونية لعرض وبيع المنتجات.
_ لا يقدّم التطبيق أو الشركة تمويلاً أو تقسيطًا أو BNPL أو قروضًا أو أي خدمات ائتمانية أو مصرفية.
_ جميع عمليات الشراء داخل التطبيق نقدية وبالسداد الكامل فقط. أي ترتيبات خاصة تتم خارج التطبيق بعقد مستقل.

4/ طرق الشراء المعتمدة
4-1) الشراء النقدي بدون اشتراك
_ يُسمح للمستخدم بشراء أي منتج بالسعر الكامل والدفع فورًا. لا تُمنح خصومات في هذه الحالة.
4-2) الشراء النقدي باشتراك وخصومات
_ يحق للمشتركين الحصول على خصومات، لكن جميع المدفوعات تبقى نقدية وكاملة.
_ الاشتراك لا يُعد دفعة مقدمة ولا تمويلاً، ولا يُعتبر جزءًا من ثمن أي منتج.
4-3) طلب الشراء المرن (للمشتركين فقط)
_ الخدمة متاحة فقط للمشتركين. الطلب غير ملزم ولا يُعتبر عقدًا. تقديم الطلب لا ينشئ أي التزام على الشركة.
_ الشركة لا تضمن الموافقة على أي طلب وتحتفظ بحقها في رفض أي طلب دون إبداء أسباب.
_ في حال الموافقة، تتم الإجراءات خارج التطبيق بعقد مستقل. لا تمويل – لا تقسيط – لا BNPL.

5/ الحسابات والاستخدام
_ يجب على المستخدم استخدام التطبيق استخدامًا قانونيًا والحفاظ على سرية بيانات حسابه.

6/ الأسعار والفواتير والضرائب
_ الأسعار المعروضة سارية وقت الطلب فقط.
_ تحتفظ الشركة بحقها في تعديل الأسعار قبل تأكيد الطلب.
_ تصدر الفواتير وفق القوانين المعمول بها في دولة الإمارات العربية المتحدة.

7/ حماية المستهلك
_ تلتزم الشركة بقوانين حماية المستهلك في دولة الإمارات العربية المتحدة.
_ يحق للمستهلك الحصول على منتج مطابق للوصف، وخالٍ من العيوب الجوهرية، ومشمول بالضمان عند توفره.

8/ سياسة الإرجاع والاستبدال
_ مدة الإرجاع: 14 يومًا من تاريخ الاستلام.
_ يجب أن يكون المنتج غير مستخدم وبحالته الأصلية وبعبوته الأصلية. الاشتراكات غير قابلة للاسترجاع بعد التفعيل.
_ يتم استرداد المبلغ (إن استحق) خلال مدة معقولة ووفق الإجراءات المعتمدة.

9/ التوصيل والعنوان
_ المستخدم مسؤول عن صحة عنوان التسليم.
_ تبدأ مدة الإرجاع من تاريخ الاستلام المثبت في نظام التوصيل أو شركة الشحن.

10/ الضمان وخدمات ما بعد البيع
_ يُطبق الضمان وفق شروط الشركة أو الشركة المصنعة.
_ لا يشمل الضمان الأعطال الناتجة عن سوء الاستخدام أو الإهمال أو الكسر أو التعديل غير المعتمد.

11/ الشكاوى وخدمة العملاء
_ يتم تقديم الشكاوى عبر البريد الإلكتروني الرسمي: iamsoftwarepublishing@gmail.com
_ تلتزم الشركة بالرد خلال مدة زمنية معقولة.

12/ الخصوصية وحماية البيانات
_ تلتزم الشركة بحماية بيانات المستخدمين وفق القوانين الإماراتية.
_ تُستخدم البيانات فقط للأغراض التشغيلية والقانونية والتنظيمية.

13/ الأمن السيبراني
_ يُمنع أي استخدام غير مشروع للتطبيق أو محاولة اختراق أو إساءة استخدام.
_ تحتفظ الشركة بحق اتخاذ الإجراءات القانونية ضد أي مخالف.

14/ حدود المسؤولية
_ يُقدَّم التطبيق “كما هو”.
_ لا تتحمل الشركة أي مسؤولية عن الأضرار غير المباشرة أو التبعية أو الخاصة ضمن الحدود التي يسمح بها القانون.

15/ الملكية الفكرية
_ جميع الحقوق المتعلقة بالتطبيق والعلامة التجارية والمحتوى مملوكة للشركة أو مرخّصة لها.
_ لا يجوز نسخ أو إعادة استخدام أي جزء دون موافقة خطية مسبقة.

16/ تعديل الشروط
_ يحق للشركة تعديل الشروط في أي وقت.
_ يُعد استمرار الاستخدام موافقة على التعديلات.

17/ القانون والاختصاص القضائي
_ تخضع هذه الشروط لقوانين دولة الإمارات العربية المتحدة.
_ تختص المحاكم الإماراتية وحدها بالنظر في أي نزاع يتعلق بها.

18/ أحكام عامة
_ بطلان أي بند لا يؤثر على باقي البنود.
_ العناوين وضعت للتسهيل فقط ولا تؤثر على التفسير القانوني.

19/ الأخطاء التقنية وأخطاء التسعير
_ تحتفظ الشركة بحق إلغاء أو رفض أي طلب في حال وجود خطأ تقني أو سعري أو خلل في الدفع.
_ لا تتحمل الشركة التزامًا بتنفيذ أي طلب ناتج عن خطأ واضح أو غير مقصود.

20/ الحق في رفض الخدمة أو إيقاف الحساب
_ تحتفظ الشركة بحقها في رفض الخدمة أو تعليق أو حذف الحساب في حال إساءة الاستخدام أو النشاط غير القانوني.

21/ المحتوى التسويقي والصور التوضيحية
_ جميع الصور والنصوص لأغراض العرض والتسويق فقط. قد تختلف المواصفات الفعلية اختلافًا طفيفًا.

22/ عدم اعتبار الإعلانات التزامًا تعاقديًا
_ لا يُعد أي محتوى ترويجي داخل التطبيق التزامًا على الشركة إلا بعد تأكيد الطلب رسميًا.

23/ القوة القاهرة
_ لا تتحمل الشركة مسؤولية عن التأخير أو الإخفاق الناتج عن ظروف خارجة عن إرادتها مثل الكوارث الطبيعية أو القرارات الحكومية أو الأعطال العامة.

24/ حدود إضافية للمسؤولية
_ لا تتحمل الشركة مسؤولية فقدان الأرباح أو البيانات أو أي أضرار غير مباشرة.

25/ العلاقة القانونية
_ استخدام التطبيق لا ينشئ علاقة شراكة أو وكالة أو تمثيل قانوني بين المستخدم والشركة.

26/ اللغة المعتمدة
_ في حال وجود تعارض بين النص العربي والإنجليزي، يُعتد بالنص العربي.

27/ الإخطارات والمراسلات الرسمية
_ تُعد المراسلات عبر البريد الإلكتروني الرسمي وسيلة إخطار قانونية معتمدة بين الشركة والمستخدم.

نص الموافقة الرسمية
_ بالضغط على “موافق”، فإنك تقر بأنك قرأت هذه الشروط والأحكام وفهمت مضمونها ووافقت عليها دون أي قيد أو شرط أو تحفظ.''',
    },
    'termsAndConditionsStatic': {
      AppLanguage.en: '''Terms and Conditions for the IAM Application

Last updated: 20 / 12 / 2025

Welcome to the IAM application, a specialized application for electronics commerce within the United Arab Emirates. By using the application or registering in it, you acknowledge and agree to be bound by the following terms and conditions in full. If you do not agree, please do not use the application.

---

1. Definitions

Application: The IAM application in all its versions and services.

Company: The entity that owns and operates the IAM application.

User / Customer: Any person who creates an account or uses the application.

Products: All electronic goods offered for sale through the application.

Cash Payment: Full payment of the product price in one single payment.

Installment Payment: Purchase of the product at a specified total price to be paid in installments, without this being considered financing or a loan.

Subscription: An amount paid in advance in return for enabling application to the installment system.

---

2. Scope of the Application

The application is an e-commerce platform for selling electronic products.

Sales are made either in cash or in installments according to the approved terms.

The application is not a financing entity, a bank, or a credit company.

---

3. Account and Registration

All provided data must be accurate and up to date.

The application reserves the right to suspend or cancel any account in case of incorrect data or breach of terms.

---

4. Subscription System

Payment of a subscription fee in advance is required to apply for purchase under the installment system.

Subscription fees are non-refundable under any circumstances.

Payment of the subscription does not necessarily mean approval of the installment request.

---

5. Installment System

Installments are only available after the request has been reviewed and approved by the application management.

The application reserves the right to accept or reject an installment request without stating reasons.

In case of rejection, the customer has no right to claim a refund of the subscription fee.

The installment price is a fixed total price determined in advance and is not considered interest or financing.

---

6. Payment and Installments

The customer is obliged to pay the installments on their due dates.''',
      AppLanguage.ar: '''شروط والأحكام لتطبيق IAM

آخر تحديث: 20 / 12/ 2025

مرحبًا بك في تطبيق IAM، وهو تطبيق متخصص في تجارة الإلكترونيات داخل دولة الإمارات العربية المتحدة. باستخدامك للتطبيق أو تسجيلك فيه، فإنك تقرّ وتوافق على الالتزام بالشروط والأحكام التالية كاملةً. في حال عدم موافقتك، يُرجى عدم استخدام التطبيق.

---

1. التعريفات

التطبيق: تطبيق IAM بجميع نسخه وخدماته.

الشركة: الجهة المالكة والمشغلة لتطبيق IAM.

المستخدم / العميل: أي شخص يقوم بإنشاء حساب أو استخدام التطبيق.

المنتجات: جميع السلع الإلكترونية المعروضة للبيع عبر التطبيق.

الدفع النقدي: الدفع الكامل لقيمة المنتج دفعة واحدة.

الدفع بالتقسيط: شراء المنتج بسعر إجمالي محدد يُسدَّد على أقساط دون اعتبار ذلك تمويلًا أو قرضًا.

الاشتراك: مبلغ يُدفع مقدمًا مقابل إتاحة التقديم على نظام التقسيط.

---

2. نطاق عمل التطبيق

التطبيق منصة تجارة إلكترونية لبيع المنتجات الإلكترونية.

يتم البيع إما نقدًا أو بالتقسيط حسب الشروط المعتمدة.

التطبيق ليس جهة تمويل ولا بنكًا ولا شركة ائتمان.

---

3. الحساب والتسجيل

يجب أن تكون جميع البيانات المقدمة صحيحة وحديثة.

يحق للتطبيق تعليق أو إلغاء أي حساب في حال تقديم بيانات غير صحيحة أو مخالفة الشروط.

---

4. نظام الاشتراك

يشترط دفع رسوم اشتراك مقدّمة للتقدم بطلب الشراء بنظام التقسيط.

رسوم الاشتراك غير قابلة للاسترداد نهائيًا في جميع الحالات.

دفع الاشتراك لا يعني بالضرورة الموافقة على طلب التقسيط.

---

5. نظام التقسيط

التقسيط متاح فقط بعد دراسة الطلب والموافقة عليه من قبل إدارة التطبيق.

يحق للتطبيق قبول أو رفض طلب التقسيط دون إبداء أسباب.

في حال رفض الطلب، لا يحق للعميل المطالبة باسترداد رسوم الاشتراك.

سعر التقسيط هو سعر إجمالي ثابت ومحدد مسبقًا ولا يُعد فائدة أو تمويلًا.

---

6. الدفع والأقساط

يلتزم العميل بسداد الأقساط في مواعيدها المحددة.''',
    },
  };
}
