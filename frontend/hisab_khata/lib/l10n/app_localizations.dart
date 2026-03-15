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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
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

  /// No description provided for @itemDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Rice, Dal, Groceries'**
  String get itemDescriptionHint;

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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get comingSoon;

  /// No description provided for @connectionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Connection Placeholder'**
  String get connectionPlaceholder;

  /// No description provided for @connectionPlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your pending and accepted connection requests.'**
  String get connectionPlaceholderDescription;

  /// No description provided for @analyticsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsPlaceholder;

  /// No description provided for @analyticsPlaceholderDescriptionBusiness.
  ///
  /// In en, this message translates to:
  /// **'Track your sales patterns and business insights.'**
  String get analyticsPlaceholderDescriptionBusiness;

  /// No description provided for @analyticsPlaceholderDescriptionCustomer.
  ///
  /// In en, this message translates to:
  /// **'Track your spending patterns and financial insights.'**
  String get analyticsPlaceholderDescriptionCustomer;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Title'**
  String get itemTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @createSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Support Ticket'**
  String get createSupportTicket;

  /// No description provided for @ticketCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully!'**
  String get ticketCreatedSuccessfully;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @accountIssue.
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get accountIssue;

  /// No description provided for @appIssue.
  ///
  /// In en, this message translates to:
  /// **'App Issue'**
  String get appIssue;

  /// No description provided for @systemIssue.
  ///
  /// In en, this message translates to:
  /// **'System Issue'**
  String get systemIssue;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @byaparAI.
  ///
  /// In en, this message translates to:
  /// **'Byapar d-AI'**
  String get byaparAI;

  /// No description provided for @addConnection.
  ///
  /// In en, this message translates to:
  /// **'Add Connection'**
  String get addConnection;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @newImage.
  ///
  /// In en, this message translates to:
  /// **'New Image'**
  String get newImage;

  /// No description provided for @deleteConnection.
  ///
  /// In en, this message translates to:
  /// **'Delete Connection?'**
  String get deleteConnection;

  /// No description provided for @deleteConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your connection with {name}?'**
  String deleteConnectionMessage(String name);

  /// No description provided for @pendingDue.
  ///
  /// In en, this message translates to:
  /// **'Pending due: Rs. {amount}'**
  String pendingDue(String amount);

  /// No description provided for @settleBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Please settle all pending dues before deleting this connection.'**
  String get settleBeforeDelete;

  /// No description provided for @noPendingDues.
  ///
  /// In en, this message translates to:
  /// **'No pending dues'**
  String get noPendingDues;

  /// No description provided for @bulkRequestResults.
  ///
  /// In en, this message translates to:
  /// **'Bulk Request Results'**
  String get bulkRequestResults;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @mySupportTickets.
  ///
  /// In en, this message translates to:
  /// **'My Support Tickets'**
  String get mySupportTickets;

  /// No description provided for @setLimit.
  ///
  /// In en, this message translates to:
  /// **'Set Limit'**
  String get setLimit;

  /// No description provided for @removeLimit.
  ///
  /// In en, this message translates to:
  /// **'Remove Limit'**
  String get removeLimit;

  /// No description provided for @noTransactionData.
  ///
  /// In en, this message translates to:
  /// **'No transaction data available'**
  String get noTransactionData;

  /// No description provided for @setMonthlyLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit to track your budget'**
  String get setMonthlyLimitMessage;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of your issue'**
  String get subjectHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ticketDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide detailed information about your issue'**
  String get ticketDescriptionHint;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// No description provided for @subjectMinLength.
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 5 characters'**
  String get subjectMinLength;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @descriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get descriptionMinLength;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @businessesNearMe.
  ///
  /// In en, this message translates to:
  /// **'Businesses Near Me'**
  String get businessesNearMe;

  /// No description provided for @viewBusinessesOnMap.
  ///
  /// In en, this message translates to:
  /// **'View businesses on map'**
  String get viewBusinessesOnMap;

  /// No description provided for @talkToByaparAI.
  ///
  /// In en, this message translates to:
  /// **'Talk to Byapar d-AI'**
  String get talkToByaparAI;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get aiAssistant;

  /// No description provided for @aiBusinessAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI business assistant'**
  String get aiBusinessAssistant;

  /// No description provided for @shopLocation.
  ///
  /// In en, this message translates to:
  /// **'Shop Location'**
  String get shopLocation;

  /// No description provided for @locationSet.
  ///
  /// In en, this message translates to:
  /// **'Location set'**
  String get locationSet;

  /// No description provided for @pinYourShop.
  ///
  /// In en, this message translates to:
  /// **'Pin your shop'**
  String get pinYourShop;

  /// No description provided for @esewaAccount.
  ///
  /// In en, this message translates to:
  /// **'eSewa Account'**
  String get esewaAccount;

  /// No description provided for @manageLinkedEsewa.
  ///
  /// In en, this message translates to:
  /// **'Manage linked eSewa'**
  String get manageLinkedEsewa;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @requestVerification.
  ///
  /// In en, this message translates to:
  /// **'Request Verification'**
  String get requestVerification;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @transactionActivity.
  ///
  /// In en, this message translates to:
  /// **'Transaction Activity'**
  String get transactionActivity;

  /// No description provided for @noTransactionActivity.
  ///
  /// In en, this message translates to:
  /// **'No transaction activity yet'**
  String get noTransactionActivity;

  /// No description provided for @noTransactionActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your recent transactions will appear here'**
  String get noTransactionActivitySubtitle;

  /// No description provided for @transactionSingular.
  ///
  /// In en, this message translates to:
  /// **'transaction'**
  String get transactionSingular;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @asBusiness.
  ///
  /// In en, this message translates to:
  /// **'As Business'**
  String get asBusiness;

  /// No description provided for @asCustomer.
  ///
  /// In en, this message translates to:
  /// **'As Customer'**
  String get asCustomer;

  /// No description provided for @pleaseWaitBeforeResending.
  ///
  /// In en, this message translates to:
  /// **'Please wait {time} before resending'**
  String pleaseWaitBeforeResending(String time);

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get failedToResendOtp;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @clearDueCash.
  ///
  /// In en, this message translates to:
  /// **'Clear Due (Cash)'**
  String get clearDueCash;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @noPendingDuesToClear.
  ///
  /// In en, this message translates to:
  /// **'No pending dues to clear'**
  String get noPendingDuesToClear;

  /// No description provided for @pendingRs.
  ///
  /// In en, this message translates to:
  /// **'Pending: Rs. {amount}'**
  String pendingRs(String amount);

  /// No description provided for @recordCashPayment.
  ///
  /// In en, this message translates to:
  /// **'Record cash payment received from {name}'**
  String recordCashPayment(String name);

  /// No description provided for @amountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount Received'**
  String get amountReceived;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHintCashReceived.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cash received'**
  String get noteHintCashReceived;

  /// No description provided for @cashPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash payment received'**
  String get cashPaymentReceived;

  /// No description provided for @clearDue.
  ///
  /// In en, this message translates to:
  /// **'Clear Due'**
  String get clearDue;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @unableToOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Unable to open chat. Please try again.'**
  String get unableToOpenChat;

  /// No description provided for @updateEsewaAccount.
  ///
  /// In en, this message translates to:
  /// **'Update eSewa Account'**
  String get updateEsewaAccount;

  /// No description provided for @linkEsewaAccount.
  ///
  /// In en, this message translates to:
  /// **'Link eSewa Account'**
  String get linkEsewaAccount;

  /// No description provided for @esewaIdLabel.
  ///
  /// In en, this message translates to:
  /// **'eSewa ID (Phone Number)'**
  String get esewaIdLabel;

  /// No description provided for @esewaIdHint.
  ///
  /// In en, this message translates to:
  /// **'98XXXXXXXX'**
  String get esewaIdHint;

  /// No description provided for @pleaseEnterEsewaId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your eSewa ID'**
  String get pleaseEnterEsewaId;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @accountHolderHint.
  ///
  /// In en, this message translates to:
  /// **'Name on your eSewa account'**
  String get accountHolderHint;

  /// No description provided for @pleaseEnterAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the account holder name'**
  String get pleaseEnterAccountHolderName;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @unlinkEsewa.
  ///
  /// In en, this message translates to:
  /// **'Unlink eSewa'**
  String get unlinkEsewa;

  /// No description provided for @unlinkEsewaConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink your eSewa account? Customers will no longer be able to pay via eSewa.'**
  String get unlinkEsewaConfirmation;

  /// No description provided for @esewaPayment.
  ///
  /// In en, this message translates to:
  /// **'eSewa Payment'**
  String get esewaPayment;

  /// No description provided for @accountLinked.
  ///
  /// In en, this message translates to:
  /// **'Your account is linked'**
  String get accountLinked;

  /// No description provided for @esewaLinkedDescription.
  ///
  /// In en, this message translates to:
  /// **'Customers can now pay their dues via eSewa directly to your account.'**
  String get esewaLinkedDescription;

  /// No description provided for @esewaUnlinkedDescription.
  ///
  /// In en, this message translates to:
  /// **'Link your eSewa account so customers can pay their dues digitally.'**
  String get esewaUnlinkedDescription;

  /// No description provided for @enterEsewaDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your eSewa account details'**
  String get enterEsewaDetails;

  /// No description provided for @esewaIdMustBe10Digits.
  ///
  /// In en, this message translates to:
  /// **'eSewa ID must be 10 digits'**
  String get esewaIdMustBe10Digits;

  /// No description provided for @esewaIdMustStartWith9.
  ///
  /// In en, this message translates to:
  /// **'eSewa ID must start with 9'**
  String get esewaIdMustStartWith9;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @linkedAccount.
  ///
  /// In en, this message translates to:
  /// **'Linked Account'**
  String get linkedAccount;

  /// No description provided for @voiceInputAdded.
  ///
  /// In en, this message translates to:
  /// **'Voice input added: Rs. {amount}'**
  String voiceInputAdded(String amount);

  /// No description provided for @imageProcessed.
  ///
  /// In en, this message translates to:
  /// **'Image processed: Rs. {amount}'**
  String imageProcessed(String amount);

  /// No description provided for @rsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rs. '**
  String get rsPrefix;

  /// No description provided for @pleaseEnterItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter item title'**
  String get pleaseEnterItemTitle;

  /// No description provided for @speechRecognitionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available on this device'**
  String get speechRecognitionNotAvailable;

  /// No description provided for @failedToInitialize.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize: {error}'**
  String failedToInitialize(String error);

  /// No description provided for @voiceTransaction.
  ///
  /// In en, this message translates to:
  /// **'Voice Transaction'**
  String get voiceTransaction;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @tapMicToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap mic to speak'**
  String get tapMicToSpeak;

  /// No description provided for @trySaying.
  ///
  /// In en, this message translates to:
  /// **'Try saying: \"Add 200 rs for chocolate\"'**
  String get trySaying;

  /// No description provided for @youSaid.
  ///
  /// In en, this message translates to:
  /// **'You said:'**
  String get youSaid;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @noTextFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'No text found in image. Please try another image.'**
  String get noTextFoundInImage;

  /// No description provided for @couldNotExtractDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not extract transaction details. Please edit manually.'**
  String get couldNotExtractDetails;

  /// No description provided for @errorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Error processing image: {error}'**
  String errorProcessingImage(String error);

  /// No description provided for @imageTransaction.
  ///
  /// In en, this message translates to:
  /// **'Image Transaction'**
  String get imageTransaction;

  /// No description provided for @extractDetailsFromReceipt.
  ///
  /// In en, this message translates to:
  /// **'Extract details from receipt'**
  String get extractDetailsFromReceipt;

  /// No description provided for @extractingText.
  ///
  /// In en, this message translates to:
  /// **'Extracting text from image...'**
  String get extractingText;

  /// No description provided for @analyzingWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyzing transaction with AI...'**
  String get analyzingWithAI;

  /// No description provided for @extractedText.
  ///
  /// In en, this message translates to:
  /// **'Extracted Text:'**
  String get extractedText;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get filterTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @transactionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsWillAppearHere;

  /// No description provided for @addTransactionsForCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add transactions for this customer'**
  String get addTransactionsForCustomer;

  /// No description provided for @purchaseFromBusiness.
  ///
  /// In en, this message translates to:
  /// **'Purchase from business'**
  String get purchaseFromBusiness;

  /// No description provided for @paymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment made'**
  String get paymentMade;

  /// No description provided for @creditReceived.
  ///
  /// In en, this message translates to:
  /// **'Credit received'**
  String get creditReceived;

  /// No description provided for @refundReceived.
  ///
  /// In en, this message translates to:
  /// **'Refund received'**
  String get refundReceived;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @saleToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Sale to customer'**
  String get saleToCustomer;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// No description provided for @creditGiven.
  ///
  /// In en, this message translates to:
  /// **'Credit given'**
  String get creditGiven;

  /// No description provided for @refundGiven.
  ///
  /// In en, this message translates to:
  /// **'Refund given'**
  String get refundGiven;

  /// No description provided for @allDuesCleared.
  ///
  /// In en, this message translates to:
  /// **'All dues cleared!'**
  String get allDuesCleared;

  /// No description provided for @almostAllDuesPaid.
  ///
  /// In en, this message translates to:
  /// **'Great! Almost all dues paid'**
  String get almostAllDuesPaid;

  /// No description provided for @considerClearingDues.
  ///
  /// In en, this message translates to:
  /// **'Consider clearing pending dues'**
  String get considerClearingDues;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance pending'**
  String get outstandingBalance;

  /// No description provided for @allPaymentsCollected.
  ///
  /// In en, this message translates to:
  /// **'All payments collected'**
  String get allPaymentsCollected;

  /// No description provided for @goodCollectionRate.
  ///
  /// In en, this message translates to:
  /// **'Good collection rate'**
  String get goodCollectionRate;

  /// No description provided for @moderateCollection.
  ///
  /// In en, this message translates to:
  /// **'Moderate collection'**
  String get moderateCollection;

  /// No description provided for @pendingCollection.
  ///
  /// In en, this message translates to:
  /// **'Pending collection'**
  String get pendingCollection;

  /// No description provided for @payDueViaEsewa.
  ///
  /// In en, this message translates to:
  /// **'Pay Due via eSewa'**
  String get payDueViaEsewa;

  /// No description provided for @dueRs.
  ///
  /// In en, this message translates to:
  /// **'Due: Rs. {amount}'**
  String dueRs(String amount);

  /// No description provided for @businessNotLinkedEsewa.
  ///
  /// In en, this message translates to:
  /// **'This business has not linked their eSewa account yet. Please use cash payment instead.'**
  String get businessNotLinkedEsewa;

  /// No description provided for @payWithEsewa.
  ///
  /// In en, this message translates to:
  /// **'Pay with eSewa'**
  String get payWithEsewa;

  /// No description provided for @esewaPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'eSewa payment failed: {error}'**
  String esewaPaymentFailed(String error);

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment was cancelled'**
  String get paymentCancelled;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this connection request?'**
  String get cancelRequestConfirmation;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @noReceivedRequests.
  ///
  /// In en, this message translates to:
  /// **'No Received Requests'**
  String get noReceivedRequests;

  /// No description provided for @whenSomeoneSendsRequest.
  ///
  /// In en, this message translates to:
  /// **'When someone sends you a connection request, it will appear here.'**
  String get whenSomeoneSendsRequest;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @pastRequests.
  ///
  /// In en, this message translates to:
  /// **'Past Requests'**
  String get pastRequests;

  /// No description provided for @awaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Response'**
  String get awaitingResponse;

  /// No description provided for @noSentRequests.
  ///
  /// In en, this message translates to:
  /// **'No Sent Requests'**
  String get noSentRequests;

  /// No description provided for @sentRequestsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Connection requests you send will appear here.'**
  String get sentRequestsWillAppear;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @addMultipleCustomers.
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Customers'**
  String get addMultipleCustomers;

  /// No description provided for @addMultipleBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Businesses'**
  String get addMultipleBusinesses;

  /// No description provided for @addMultipleConnections.
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Connections'**
  String get addMultipleConnections;

  /// No description provided for @pleaseSelectAtLeastOneUser.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one user to send connection requests.'**
  String get pleaseSelectAtLeastOneUser;

  /// No description provided for @searchByNameEmailPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, or phone...'**
  String get searchByNameEmailPhone;

  /// No description provided for @usersSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} user(s) selected'**
  String usersSelected(String count);

  /// No description provided for @usersAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} user(s) available'**
  String usersAvailable(String count);

  /// No description provided for @noUsersFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{query}\"'**
  String noUsersFoundFor(String query);

  /// No description provided for @noUsersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No users available'**
  String get noUsersAvailable;

  /// No description provided for @sendRequests.
  ///
  /// In en, this message translates to:
  /// **'Send Requests ({count})'**
  String sendRequests(String count);

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @addBusiness.
  ///
  /// In en, this message translates to:
  /// **'Add Business'**
  String get addBusiness;

  /// No description provided for @addMultipleConnectionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Connections'**
  String get addMultipleConnectionsTooltip;

  /// No description provided for @failedToLoadConnectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load connection requests'**
  String get failedToLoadConnectionRequests;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your\nconnected users'**
  String get startConversation;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @unableToLoadChat.
  ///
  /// In en, this message translates to:
  /// **'Unable to load chat'**
  String get unableToLoadChat;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get youPrefix;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get reconnecting;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @favoriteBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Favorite Businesses ({count})'**
  String favoriteBusinesses(String count);

  /// No description provided for @favoritedOn.
  ///
  /// In en, this message translates to:
  /// **'Favorited on {date}'**
  String favoritedOn(String date);

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Business Overview'**
  String get businessOverview;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @revenueAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Revenue Analytics'**
  String get revenueAnalytics;

  /// No description provided for @noFavoriteCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorite Customers Yet'**
  String get noFavoriteCustomersYet;

  /// No description provided for @customersWhoFavorite.
  ///
  /// In en, this message translates to:
  /// **'Customers who favorite your business will appear here'**
  String get customersWhoFavorite;

  /// No description provided for @favoriteCustomers.
  ///
  /// In en, this message translates to:
  /// **'Favorite Customers'**
  String get favoriteCustomers;

  /// No description provided for @setMonthlyLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Limit'**
  String get setMonthlyLimitTitle;

  /// No description provided for @setMonthlyLimitDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly spending limit to track your budget'**
  String get setMonthlyLimitDescription;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @enterAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountHint;

  /// No description provided for @paidVsToPay.
  ///
  /// In en, this message translates to:
  /// **'Paid vs To Pay'**
  String get paidVsToPay;

  /// No description provided for @monthlySpending.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending - {month}'**
  String monthlySpending(String month);

  /// No description provided for @setMonthlyLimitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Limit'**
  String get setMonthlyLimitTooltip;

  /// No description provided for @totalSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpentLabel;

  /// No description provided for @monthlyLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimitLabel;

  /// No description provided for @overBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'Over budget by Rs. {amount}'**
  String overBudgetBy(String amount);

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining: Rs. {amount}'**
  String remainingBudget(String amount);

  /// No description provided for @monthlyTransactionTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Transaction Trend'**
  String get monthlyTransactionTrend;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(String count);

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(String count);

  /// No description provided for @rsAmount.
  ///
  /// In en, this message translates to:
  /// **'Rs. {amount}'**
  String rsAmount(String amount);

  /// No description provided for @markAllSeen.
  ///
  /// In en, this message translates to:
  /// **'Mark all seen'**
  String get markAllSeen;

  /// No description provided for @notificationMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Notification marked as read'**
  String get notificationMarkedAsRead;

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @notificationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted successfully'**
  String get notificationDeletedSuccessfully;

  /// No description provided for @allReadNotificationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All read notifications deleted'**
  String get allReadNotificationsDeleted;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @adminResponse.
  ///
  /// In en, this message translates to:
  /// **'Admin Response'**
  String get adminResponse;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @noTicketsYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get noTicketsYet;

  /// No description provided for @createFirstTicket.
  ///
  /// In en, this message translates to:
  /// **'Create your first support ticket'**
  String get createFirstTicket;

  /// No description provided for @connectionRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Connection request sent!'**
  String get connectionRequestSent;

  /// No description provided for @sendConnectionRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Connection Request'**
  String get sendConnectionRequest;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @submitVerificationRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification Request'**
  String get submitVerificationRequest;

  /// No description provided for @pleaseSelectDocumentImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a document image'**
  String get pleaseSelectDocumentImage;

  /// No description provided for @submitBusinessDocuments.
  ///
  /// In en, this message translates to:
  /// **'Submit your business documents to get verified. This helps build trust with your customers.'**
  String get submitBusinessDocuments;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @additionalNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Note (Optional)'**
  String get additionalNoteOptional;

  /// No description provided for @addAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Add any additional information about your business...'**
  String get addAdditionalInfo;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @submitNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit New Request'**
  String get submitNewRequest;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @failedToGetCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location'**
  String get failedToGetCurrentLocation;

  /// No description provided for @pleaseSelectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Please tap on the map to select a location'**
  String get pleaseSelectLocationOnMap;

  /// No description provided for @searchLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocationHint;

  /// No description provided for @enterShopAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter shop address (optional)'**
  String get enterShopAddress;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordHint;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHint;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @differentFromCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Different from current password'**
  String get differentFromCurrentPassword;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @giveToTakeRatioGood.
  ///
  /// In en, this message translates to:
  /// **'Your Give is to Take Ratio Looks Good'**
  String get giveToTakeRatioGood;

  /// No description provided for @needToGiveMore.
  ///
  /// In en, this message translates to:
  /// **'You Need to Give More Than Take'**
  String get needToGiveMore;

  /// No description provided for @giveAndTakeBalanced.
  ///
  /// In en, this message translates to:
  /// **'Your Give and Take is Balanced'**
  String get giveAndTakeBalanced;

  /// No description provided for @toGive.
  ///
  /// In en, this message translates to:
  /// **'To Give'**
  String get toGive;

  /// No description provided for @toTake.
  ///
  /// In en, this message translates to:
  /// **'To Take'**
  String get toTake;

  /// No description provided for @noConnectedBusinesses.
  ///
  /// In en, this message translates to:
  /// **'No connected businesses yet'**
  String get noConnectedBusinesses;

  /// No description provided for @noConnectedCustomers.
  ///
  /// In en, this message translates to:
  /// **'No connected customers yet'**
  String get noConnectedCustomers;

  /// No description provided for @connectWithBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Connect with businesses to start tracking your transactions'**
  String get connectWithBusinesses;

  /// No description provided for @connectWithCustomers.
  ///
  /// In en, this message translates to:
  /// **'Connect with customers to manage their accounts'**
  String get connectWithCustomers;

  /// No description provided for @failedToLoadConnections.
  ///
  /// In en, this message translates to:
  /// **'Failed to load connections'**
  String get failedToLoadConnections;

  /// No description provided for @connectedBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Connected Businesses'**
  String get connectedBusinesses;

  /// No description provided for @connectedCustomers.
  ///
  /// In en, this message translates to:
  /// **'Connected Customers'**
  String get connectedCustomers;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @gettingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// No description provided for @noBusinessesWithLocation.
  ///
  /// In en, this message translates to:
  /// **'No businesses with location found'**
  String get noBusinessesWithLocation;

  /// No description provided for @businessVerification.
  ///
  /// In en, this message translates to:
  /// **'Business Verification'**
  String get businessVerification;

  /// No description provided for @businessRegistration.
  ///
  /// In en, this message translates to:
  /// **'Business Registration'**
  String get businessRegistration;

  /// No description provided for @panCard.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get panCard;

  /// No description provided for @vatCertificate.
  ///
  /// In en, this message translates to:
  /// **'VAT Certificate'**
  String get vatCertificate;

  /// No description provided for @tradeLicense.
  ///
  /// In en, this message translates to:
  /// **'Trade License'**
  String get tradeLicense;

  /// No description provided for @documentSelected.
  ///
  /// In en, this message translates to:
  /// **'Document selected'**
  String get documentSelected;

  /// No description provided for @tapToUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload document image'**
  String get tapToUploadDocument;

  /// No description provided for @takePhotoOrChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get takePhotoOrChooseFromGallery;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @verificationBeingReviewed.
  ///
  /// In en, this message translates to:
  /// **'Your verification request is being reviewed by our admin team.'**
  String get verificationBeingReviewed;

  /// No description provided for @notVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerifiedTitle;

  /// No description provided for @businessVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your business has been verified successfully.'**
  String get businessVerifiedSuccessfully;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @latestRequest.
  ///
  /// In en, this message translates to:
  /// **'Latest Request'**
  String get latestRequest;

  /// No description provided for @adminRemarks.
  ///
  /// In en, this message translates to:
  /// **'Admin Remarks'**
  String get adminRemarks;

  /// No description provided for @setShopLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Shop Location'**
  String get setShopLocation;

  /// No description provided for @tapOnMapToPinLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to pin your shop location'**
  String get tapOnMapToPinLocation;

  /// No description provided for @locationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String locationCoordinates(String lat, String lng);

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Request Pending'**
  String get requestPending;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String distanceKm(String distance);

  /// No description provided for @yourDue.
  ///
  /// In en, this message translates to:
  /// **'Your Due'**
  String get yourDue;

  /// No description provided for @toReceive.
  ///
  /// In en, this message translates to:
  /// **'To Receive'**
  String get toReceive;

  /// No description provided for @youPaid.
  ///
  /// In en, this message translates to:
  /// **'You Paid'**
  String get youPaid;

  /// No description provided for @isTyping.
  ///
  /// In en, this message translates to:
  /// **'{userName} is typing...'**
  String isTyping(String userName);

  /// No description provided for @transactionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Transaction Calendar'**
  String get transactionCalendar;

  /// No description provided for @noTransactionsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No transactions on this date'**
  String get noTransactionsOnDate;

  /// No description provided for @daysWithTransactions.
  ///
  /// In en, this message translates to:
  /// **'days with transactions'**
  String get daysWithTransactions;

  /// No description provided for @transactionsOnDate.
  ///
  /// In en, this message translates to:
  /// **'Transactions on {date}'**
  String transactionsOnDate(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
