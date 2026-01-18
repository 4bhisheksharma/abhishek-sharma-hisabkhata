import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hisab Khata'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @payDue.
  ///
  /// In en, this message translates to:
  /// **'Pay Due'**
  String get payDue;

  /// No description provided for @recentBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Recent Businesses'**
  String get recentBusinesses;

  /// No description provided for @recentCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recent Customers'**
  String get recentCustomers;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Image Source'**
  String get chooseImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Digital खाता'**
  String get tagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @emailHintText.
  ///
  /// In en, this message translates to:
  /// **'ramdai@gmail.com'**
  String get emailHintText;

  /// No description provided for @passwordHintText.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHintText;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'The OTP you entered is invalid'**
  String get invalidOtp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @enterAllSixDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get enterAllSixDigits;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendOtpAfter.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP After'**
  String get resendOtpAfter;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'Which is sent to your Mail'**
  String get otpSent;

  /// No description provided for @continueProcess.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueProcess;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullNameHintText.
  ///
  /// In en, this message translates to:
  /// **'RamKumar'**
  String get fullNameHintText;

  /// No description provided for @businessNameHintText.
  ///
  /// In en, this message translates to:
  /// **'Ramdai Ko Dokan'**
  String get businessNameHintText;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @mobileNumberHintText.
  ///
  /// In en, this message translates to:
  /// **'+977 9800000000'**
  String get mobileNumberHintText;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get enterMobileNumber;

  /// No description provided for @confirmPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordText;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to\n'**
  String get agreeToTerms;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy.'**
  String get privacyPolicy;

  /// No description provided for @enterValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get enterValidMobileNumber;

  /// No description provided for @serverFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Server failure'**
  String get serverFailureMessage;

  /// No description provided for @cacheFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Cache failure'**
  String get cacheFailureMessage;

  /// No description provided for @internetFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get internetFailureMessage;

  /// No description provided for @somethingWentWrongFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!!'**
  String get somethingWentWrongFailureMessage;

  /// No description provided for @emailOrUserNameEmptyErrorText.
  ///
  /// In en, this message translates to:
  /// **'Email or Mobile No is required'**
  String get emailOrUserNameEmptyErrorText;

  /// No description provided for @passwordEmptyErrorText.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordEmptyErrorText;

  /// No description provided for @pinEmptyErrorText.
  ///
  /// In en, this message translates to:
  /// **'Pin is required'**
  String get pinEmptyErrorText;

  /// No description provided for @confirmPasswordNotMatchErrorText.
  ///
  /// In en, this message translates to:
  /// **'Confirm password does not match'**
  String get confirmPasswordNotMatchErrorText;

  /// No description provided for @invalidEmailErrorText.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailErrorText;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @switchToHybrid.
  ///
  /// In en, this message translates to:
  /// **'Switch To Hybrid'**
  String get switchToHybrid;

  /// No description provided for @raiseATicket.
  ///
  /// In en, this message translates to:
  /// **'Raise A Ticket'**
  String get raiseATicket;

  /// No description provided for @verifiedBusiness.
  ///
  /// In en, this message translates to:
  /// **'Verified Business'**
  String get verifiedBusiness;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @viewAllPastTransactions.
  ///
  /// In en, this message translates to:
  /// **'View all your past transactions and payments.'**
  String get viewAllPastTransactions;

  /// No description provided for @viewAllPastTransactionsBusiness.
  ///
  /// In en, this message translates to:
  /// **'View all your past transactions and received payments.'**
  String get viewAllPastTransactionsBusiness;

  /// No description provided for @totalShops.
  ///
  /// In en, this message translates to:
  /// **'Total Shops'**
  String get totalShops;

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @nepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get nepali;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// No description provided for @recentlyAddedBusiness.
  ///
  /// In en, this message translates to:
  /// **'Recently Added Business'**
  String get recentlyAddedBusiness;

  /// No description provided for @noBusinessesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No businesses added yet'**
  String get noBusinessesAddedYet;

  /// No description provided for @recentlyAddedCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recently Added Customers'**
  String get recentlyAddedCustomers;

  /// No description provided for @noCustomersAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No customers added yet'**
  String get noCustomersAddedYet;

  /// No description provided for @transactionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAddedSuccessfully;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPendingDuesToPay.
  ///
  /// In en, this message translates to:
  /// **'No pending dues to pay!'**
  String get noPendingDuesToPay;

  /// No description provided for @payFull.
  ///
  /// In en, this message translates to:
  /// **'Pay Full'**
  String get payFull;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @amountCannotExceedDueAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed due amount'**
  String get amountCannotExceedDueAmount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @connectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Connection Requests'**
  String get connectionRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @ownerFullName.
  ///
  /// In en, this message translates to:
  /// **'Owner Full Name'**
  String get ownerFullName;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Rice, Dal, Groceries'**
  String get descriptionHint;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Message'**
  String get messageHint;

  /// No description provided for @transactionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Payment for January'**
  String get transactionNoteHint;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneHint;

  /// No description provided for @businessNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name'**
  String get businessNameHint;

  /// No description provided for @ownerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter owner full name'**
  String get ownerNameHint;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneNumberHint;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'demo@gmail.com'**
  String get emailExample;

  /// No description provided for @noRouteDefined.
  ///
  /// In en, this message translates to:
  /// **'No route defined for'**
  String get noRouteDefined;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterYourName;

  /// No description provided for @enterBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your business name'**
  String get enterBusinessName;

  /// No description provided for @enterOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter owner name'**
  String get enterOwnerName;

  /// No description provided for @enterAnEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get enterAnEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ne': return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
