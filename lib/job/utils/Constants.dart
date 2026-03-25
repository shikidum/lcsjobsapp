import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const mAppName = 'Travi Cabs';
var errorThisFieldRequired = 'This field is required';

const googleMapAPIKey = 'AIzaSyDZdjSNbGpB3718LyqjCMHZAoJxKV_UmRA';

const DOMAIN_URL = 'https://travicabs.com'; // Don't add slash at the end of the url

const SUCCESS = 'payment_status_message';
const PRESENT_TOP_UP_AMOUNT_CONST = '10|20|30';

const passwordLengthGlobal = 8;
const defaultRadius = 10.0;
const defaultSmallRadius = 6.0;

const textPrimarySizeGlobal = 16.00;
const textBoldSizeGlobal = 16.00;
const textSecondarySizeGlobal = 14.00;

double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double statisticsItemWidth = 230.0;
double defaultAppButtonElevation = 4.0;

bool enableAppButtonScaleAnimationGlobal = true;
int? appButtonScaleAnimationDurationGlobal;
ShapeBorder? defaultAppButtonShapeBorder;

var customDialogHeight = 140.0;
var customDialogWidth = 220.0;

enum ThemeModes { SystemDefault, Light, Dark }

const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';
const LoginTypeApple = 'apple';

const currencySymbol = '₹';
const currencyNameConst = 'INR';
const defaultCountryCode = '+91';
const digitAfterDecimal = 2;

/// SharedReference keys

const REMEMBER_ME = 'REMEMBER_ME';
const IS_FIRST_TIME = 'IS_FIRST_TIME';
const IS_LOGGED_IN = 'IS_LOGGED_IN';

const ON_RIDE_MODEL = 'ON_RIDE_MODEL';
const IS_TIME2 = 'IS_TIME2';

const USER_ID = 'USER_ID';
const SOURCE_LOCATION = 'SOURCE_LOCATION';
const DESTINATION_LOCATION = 'DESTINATION_LOCATION';
const REFFCODE = 'REFFCODE';
const FIRST_NAME = 'FIRST_NAME';
const LAST_NAME = 'LAST_NAME';
const TOKEN = 'TOKEN';
const USER_EMAIL = 'USER_EMAIL';
const USER_TOKEN = 'USER_TOKEN';
const USER_MOBILE = 'USER_MOBILE';
const SOURCE_REGION = 'SOURCE_REGION';

const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_TYPE = 'USER_TYPE';
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_ADDRESS = 'USER_ADDRESS';
const STATUS = 'STATUS';
const CONTACT_NUMBER = 'CONTACT_NUMBER';
const PLAYER_ID = 'PLAYER_ID';
const UID = 'UID';
const ADDRESS = 'ADDRESS';
const IS_OTP = 'IS_OTP';
const IS_GOOGLE = 'IS_GOOGLE';
const GENDER = 'GENDER';
const IS_ONLINE = 'IS_ONLINE';
const IS_Verified_Driver = 'is_verified_driver';
const PARTNER_ID = 'Partner_id';
const VEHICLE_NO = 'Vehicle_no';
const ADMIN = 'admin';
const DRIVER = 'driver';
const RIDER = 'rider';
const LATITUDE = 'LATITUDE';
const LONGITUDE = 'LONGITUDE';

const DES_LATITUDE = 'DES_LATITUDE';
const DES_LONGITUDE = 'DES_LONGITUDE';

/// Taxi Status
const IN_ACTIVE = 'inactive';
const PENDING = 'pending';
const BANNED = 'banned';
const REJECT = 'reject';

const fixedDecimal = digitAfterDecimal;
const REMAINING_TIME = 'REMAINING_TIME';

const IS_TIME = 'IS_TIME';
/// Wallet keys
const CREDIT = 'credit';
const DEBIT = 'debit';

const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYTM = 'paytm';

const CASH = 'cash';

/// My Rides Status
const UPCOMING = 'upcoming';
const NEW_RIDE_REQUESTED = 'new_ride_requested';
const ACCEPTED = 'accepted';
const ARRIVING = 'arriving';
const ACTIVE = 'active';
const ARRIVED = 'arrived';
const IN_PROGRESS = 'in_progress';
const CANCELED = 'canceled';
const COMPLETED = 'completed';
const AUTO = 'auto';
const COMPLAIN_COMMENT = "complaintcomment";

///FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";
const RIDE_CHAT = "ride_chat";
const RIDE_COLLECTION='rides';
//endregion

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;
const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';
const SELECTED_LANGUAGE_CODE = 'selected_language_code';
const THEME_MODE_INDEX = 'theme_mode_index';
const CHANGE_LANGUAGE = 'CHANGE_LANGUAGE';
const CHANGE_MONEY = 'CHANGE_MONEY';
const LOGIN_TYPE = 'login_type';

const TEXT = "TEXT";
const IMAGE = "IMAGE";

const VIDEO = "VIDEO";
const AUDIO = "AUDIO";

const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";

const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';
const CASH_WALLET = 'cash_wallet';
const MALE = 'Male';
const FEMALE = 'Female';
const OTHER = 'Other';
const LEFT = 'left';

/// app setting key
const CLOCK = 'clock';
const PRESENT_TOPUP_AMOUNT = 'preset_topup_amount';
const PRESENT_TIP_AMOUNT = 'preset_tip_amount';
const MAX_TIME_FOR_RIDER_MINUTE = 'max_time_for_find_drivers_for_regular_ride_in_minute';
const MAX_TIME_FOR_DRIVER_SECOND = 'ride_accept_decline_duration_for_driver_in_second';
const MIN_AMOUNT_TO_ADD = 'min_amount_to_add';
const MAX_AMOUNT_TO_ADD = 'max_amount_to_add';
const APPLY_ADDITIONAL_FEE = 'apply_additional_fee';
const RIDE_FOR_OTHER = 'RIDE_FOR_OTHER';
//chat
List<String> rtlLanguage = ['ar', 'ur'];

enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('E MMM dd, hh:mm a');
  return formatter.format(dateTime);
}


String formatDuration(int durationInSeconds) {
  Duration duration = Duration(seconds: durationInSeconds);

  // Calculate days, hours, minutes
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);

  // Build the formatted string
  String formattedDuration = '';
  if (days > 0) {
    formattedDuration += '$days day${days != 1 ? 's' : ''} ';
  }
  if (hours > 0 || days > 0) {
    formattedDuration += '$hours hour${hours != 1 ? 's' : ''} ';
  }
  if (minutes > 0 || (hours == 0 && days == 0)) {
    formattedDuration += '$minutes minute${minutes != 1 ? 's' : ''}';
  }

  return formattedDuration.trim();
}

String formatDurationfromMinute(int durationInMinutes) {
  Duration duration = Duration(minutes: durationInMinutes);

  // Calculate days, hours, minutes
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);

  // Build the formatted string
  String formattedDuration = '';
  if (days > 0) {
    formattedDuration += '$days day${days != 1 ? 's' : ''} ';
  }
  if (hours > 0 || days > 0) {
    formattedDuration += '$hours hour${hours != 1 ? 's' : ''} ';
  }
  if (minutes > 0 || (hours == 0 && days == 0)) {
    formattedDuration += '$minutes minute${minutes != 1 ? 's' : ''}';
  }

  return formattedDuration.trim();
}



const PDF_NAME = 'Travinow Service  Private Limited';
const PDF_ADDRESS = 'Purnia, Bihar, India';
const PDF_CONTACT_NUMBER = '+91 7280002666';

var errorSomethingWentWrong = 'Something Went Wrong';