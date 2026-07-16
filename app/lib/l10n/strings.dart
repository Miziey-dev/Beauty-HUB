/// All user-facing copy lives here so the rest of the app is free of string
/// literals -- English is the only supported locale for v1, but keeping
/// copy in one place is what makes isiZulu etc. a config job later
/// (docs/consumer-flow.md, cross-cutting rules).
class Strings {
  Strings._();

  // Screen 1 -- Location permission
  static const locationExplainer = 'We use your location to find stylists near you.';
  static const useMyLocation = 'Use my location';
  static const enterYourSuburb = 'Enter your suburb';

  // Screen 2 -- Home / Style Feed
  static const showingResultsFurtherOut = 'Showing results a bit further out';
  static const noStylesNearby = 'No styles nearby yet -- check back soon';
  static String priceFrom(String amount) => 'from $amount';

  // Screen 3 -- Style results
  static const filters = 'Filters';
  static const listView = 'List view';
  static const mapView = 'Map view';
  static const noSalonsMatchFilters = 'No salons match these filters yet';
  static const comesToYou = 'Comes to you';
  static const hairIncludedFilter = 'Hair included';
  static const clear = 'Clear';
  static const apply = 'Apply';
  static const any = 'Any';
  static String priceUpTo(int rand) => 'Price up to R$rand';
  static String minimumRating(String label) => 'Minimum rating: $label';
  static const verifiedBadge = 'Verified';
  static const mobileBadge = 'Mobile';
  static const hairIncludedBadge = 'Hair included';
  static const noSalonsOnMap = 'No salons to show on the map';
  static const viewSalon = 'View salon';
  static const sortRecommended = 'Recommended';
  static const sortNearest = 'Nearest';
  static const sortCheapest = 'Cheapest';
  static const sortTopRated = 'Top rated';

  // Screen 4 -- Salon profile
  static String respondsIn(int minutes) => 'Responds in ~${minutes}min';
  static const mobileComesToYou = 'Mobile -- comes to you';
  static const unclaimedSalonNotice = 'Info from public listings -- own this salon? Claim it';
  static const bookNow = 'Book now';
  static const book = 'Book';
  static const contactViaWhatsApp = 'Contact via WhatsApp';
  static const noReviewsYet = 'No reviews yet';

  // Screen 5a -- Service & options
  static const serviceAndOptions = 'Service & options';
  static const hairIncludedInPrice = 'Hair included in this price';
  static const addHair = 'Add hair';
  static String addHairSubtitle(String delta) => '+$delta -- otherwise bring your own';
  static const whereShouldStylistCome = 'Where should the stylist come to?';
  static const atSalon = 'At salon';
  static String atMyPlace(String fee) => 'At my place (+$fee travel fee)';
  static const yourAddress = 'Your address';
  static String total(String amount) => 'Total: $amount';
  static const continueLabel = 'Continue';

  // Screen 5b -- Date & time
  static const dateAndTime = 'Date & time';
  static const closedThisDay = 'Closed this day -- pick another date';
  static String confirmsWithinMinutes(String salonName, int minutes) => '$salonName confirms within ${minutes}min';
  static String confirmsWithinDefault(String salonName) => '$salonName confirms within 2 hours';

  // Screen 5c -- Deposit & confirm
  static const depositAndConfirm = 'Deposit & confirm';
  static const priceRowService = 'Service';
  static const priceRowHair = 'Hair';
  static const priceRowTravelFee = 'Travel fee';
  static const priceRowDepositDueNow = 'Deposit due now';
  static const priceRowBalanceDue = 'Balance due at appointment';
  static const cancellationPolicy =
      'Free cancellation until 48 hrs before; after that the deposit is forfeited.';
  static String payDeposit(String amount) => 'Pay $amount deposit';
  static const paymentFailedDefault = 'Payment failed -- please try again';
  static String bookingCreationFailed(Object error) => 'Something went wrong: $error';

  // Booking success screen
  static const requestSent = 'Request sent!';
  static String bookingReference(String ref) => 'Booking reference: $ref';
  static String confirmationNotice(String salonName) => "You'll get a notification when $salonName confirms.";
  static const addToCalendar = 'Add to calendar';
  static const calendarUnavailable = 'Could not open calendar on this device';
  static const viewMyBookings = 'View my bookings';

  // Auth gate
  static const signInToContinue = 'Sign in to continue';
  static const phoneOtpExplainer = 'Enter your phone number and we will text you a code.';
  static const phoneNumberLabel = 'Phone number';
  static const sendCode = 'Send code';
  static const or = 'or';
  static const continueWithGoogle = 'Continue with Google';
  static String codeSentTo(String phone) => 'Enter the code sent to $phone';
  static const verificationCodeLabel = 'Verification code';
  static const verify = 'Verify';
  static const changeNumber = 'Change number';
  static String sendOtpFailed(Object error) => 'Could not send code: $error';
  static String verifyOtpFailed(Object error) => 'Incorrect code: $error';
  static String googleSignInFailed(Object error) => 'Google sign-in failed: $error';

  // Screen 6 -- My Bookings
  static const myBookings = 'My Bookings';
  static const upcomingTab = 'Upcoming';
  static const pastTab = 'Past';
  static const noUpcomingBookings = 'No upcoming bookings yet';
  static const noPastBookings = 'No past bookings yet';
  static const cancelThisBookingTitle = 'Cancel this booking?';
  static const freeCancellationNotice = 'Free cancellation -- your deposit will be refunded.';
  static const forfeitCancellationNotice =
      "It's within 48 hrs of the appointment, so your deposit will be forfeited.";
  static const keepBooking = 'Keep booking';
  static const cancelBooking = 'Cancel booking';
  static const getDirections = 'Get directions';
  static const cancel = 'Cancel';
  static const youMightAlsoLike = 'You might also like';
  static const bookAgain = 'Book again';
  static const reviewed = 'Reviewed';
  static const leaveAReview = 'Leave a review';
  static const statusAwaitingConfirmation = 'Awaiting confirmation';
  static const statusConfirmed = 'Confirmed';
  static const statusDeclined = 'Declined -- refunded';
  static const statusCancelled = 'Cancelled';
  static const statusCompleted = 'Completed';

  // Screen 7 -- Review flow
  static const leaveAReviewTitle = 'Leave a review';
  static const howWasYourAppointment = 'How was your appointment?';
  static const reviewBodyHint = 'Tell us about it (optional)';
  static const showOffTheResult = 'Show off the result';
  static String photosAdded(int count) => '$count photo(s) added';
  static const submitReview = 'Submit review';
  static String submitReviewFailed(Object error) => 'Could not submit review: $error';

  // Screen 8 -- Profile / Settings
  static const profile = 'Profile';
  static const saved = 'Saved';
  static const nameLabel = 'Name';
  static const savedAddresses = 'Saved addresses';
  static const addAnAddressHint = 'Add an address';
  static const pushNotifications = 'Push notifications';
  static const pushNotificationsSubtitle = 'Booking confirmations and reminders';
  static const favouriteSalons = 'Favourite salons';
  static const noFavouritesYet = 'None yet';
  static const helpAndContact = 'Help & contact';
  static const termsAndConditions = 'Terms & Conditions';
  static const termsPlaceholder = 'Placeholder terms for the MVP.';
  static const close = 'Close';
  static const signOut = 'Sign out';

  // Bottom nav shell
  static const navDiscover = 'Discover';
  static const navBookings = 'Bookings';
  static const navProfile = 'Profile';
}
