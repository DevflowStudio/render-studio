import 'package:firebase_analytics/firebase_analytics.dart';
import '../rehmat.dart';

late Analytics analytics;

class Analytics {

  final FirebaseAnalytics firebase;
  Analytics(this.firebase);
  
  static Future<Analytics> get instance async {
    FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
    Analytics analytics = Analytics(firebaseAnalytics);
    await analytics.logAppOpen();
    return analytics;
  }

  /// Logs a custom Flutter Analytics event with the given [name] and event [parameters].
  Future<void> logEvent(String name, {
    Map<String, dynamic>? parameters,
    AnalyticsCallOptions? callOptions
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logEvent(name: name, parameters: parameters, callOptions: callOptions);
  }

  Future<void> logAdvertisement({
    String? adFormat,
    String? source,
    String? unit,
    String? currency,
    dynamic value,
    AnalyticsCallOptions? options
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logAdImpression(
      adFormat: adFormat,
      value: value,
      adPlatform: device.os,
      adSource: source,
      adUnitName: unit,
      currency: currency,
      callOptions: options
    );
  }

  Future<void> logAppOpen() async {
    await firebase.logAppOpen();
  }

  Future<void> logError({
    double? value,
    String? coupon,
    AnalyticsCallOptions? options,
    List<AnalyticsEventItem>? items,
    String currency = 'USD',
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logBeginCheckout(
      value: value,
      currency: currency,
      coupon: coupon,
      items: items,
      callOptions: options
    );
  }

  Future<void> logSearch({
    required String query
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logSearch(
      searchTerm: query,
    );
  }

  Future<void> logLogin({
    String? method
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logLogin(
      loginMethod: method
    );
  }

  Future<void> logPurchase({
    String? id,
    String? affiliation,
    double? value,
    double? tax,
    double? shipping,
    List<AnalyticsEventItem>? items,
    String? coupon,
    String? currency,
  }) async {
    // if (!preferences.allowAnalytics) return;
    await firebase.logPurchase(
      affiliation: affiliation,
      coupon: coupon,
      currency: currency,
      items: items,
      transactionId: id,
      value: value,
      shipping: shipping,
      tax: tax
    );
  }

  Future<void> logRefund({
    String? id,
    String? affiliation,
    double? value,
    double? tax,
    double? shipping,
    List<AnalyticsEventItem>? items,
    String? coupon,
    String? currency,
  }) async {
    // if (!preferences.allowAnalytics) return;
    await firebase.logRefund(
      affiliation: affiliation,
      coupon: coupon,
      currency: currency,
      items: items,
      transactionId: id,
      value: value,
      shipping: shipping,
      tax: tax,
    );
  }

  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  Future<void> logSignUp({
    required String method
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.logSignUp(
      signUpMethod: method,
    );
  }

  Future<void> logNavigation({
    required String route
  }) async {
    if (!preferences.allowAnalytics) return;
    await firebase.setCurrentScreen(screenName: route);
  }

  Future<void> setUser(String id) async {
    await firebase.setUserId(
      id: id
    );
  }

  Future<void> setProperty({
    required String name,
    required String value
  }) async {
    await firebase.setUserProperty(
      name: name,
      value: value
    );
  }

}