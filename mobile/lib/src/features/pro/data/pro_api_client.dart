import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';

final proApiClientProvider = Provider<ProApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return ProApiClient(dio, config.apiBaseUrl);
});

class ProStatusModel {
  final bool isPro;
  final String? planType;
  final int? durationDays;
  final int? amount;
  final List<String> benefits;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? orderCode;

  const ProStatusModel({
    required this.isPro,
    this.planType,
    this.durationDays,
    this.amount,
    this.benefits = const [],
    this.startDate,
    this.endDate,
    this.orderCode,
  });

  factory ProStatusModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return ProStatusModel(
      isPro: data['isPro'] == true,
      planType: data['planType']?.toString(),
      durationDays: data['durationDays'] is num
          ? (data['durationDays'] as num).toInt()
          : null,
      amount: data['amount'] is num ? (data['amount'] as num).toInt() : null,
      benefits: (data['benefits'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      startDate: data['startDate'] != null
          ? DateTime.tryParse(data['startDate'].toString())
          : null,
      endDate: data['endDate'] != null
          ? DateTime.tryParse(data['endDate'].toString())
          : null,
      orderCode:
          data['orderCode'] is num ? (data['orderCode'] as num).toInt() : null,
    );
  }
}

class ProPlanModel {
  final String planType;
  final String? label;
  final int amount;
  final int durationDays;
  final List<String> benefits;

  const ProPlanModel({
    required this.planType,
    this.label,
    required this.amount,
    required this.durationDays,
    this.benefits = const [],
  });

  factory ProPlanModel.fromJson(Map<String, dynamic> json) {
    return ProPlanModel(
      planType: json['planType']?.toString() ?? 'monthly',
      label: json['label']?.toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      benefits: (json['benefits'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}

class ProCheckoutModel {
  final int orderCode;
  final String? planType;
  final int? durationDays;
  final int amount;
  final String checkoutUrl;
  final String? qrCode;

  const ProCheckoutModel({
    required this.orderCode,
    this.planType,
    this.durationDays,
    required this.amount,
    required this.checkoutUrl,
    this.qrCode,
  });

  factory ProCheckoutModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return ProCheckoutModel(
      orderCode: (data['orderCode'] as num).toInt(),
      planType: data['planType']?.toString(),
      durationDays: data['durationDays'] is num
          ? (data['durationDays'] as num).toInt()
          : null,
      amount: (data['amount'] as num).toInt(),
      checkoutUrl: data['checkoutUrl']?.toString() ?? '',
      qrCode: data['qrCode']?.toString(),
    );
  }
}

class PayOSUrlsModel {
  final String returnUrl;
  final String cancelUrl;

  const PayOSUrlsModel({
    required this.returnUrl,
    required this.cancelUrl,
  });

  factory PayOSUrlsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return PayOSUrlsModel(
      returnUrl: data['returnUrl']?.toString() ?? '',
      cancelUrl: data['cancelUrl']?.toString() ?? '',
    );
  }
}

class ProApiClient {
  final Dio _dio;
  final String _baseUrl;

  ProApiClient(this._dio, this._baseUrl);

  Future<ProStatusModel> getStatus() async {
    final res = await _dio.get('$_baseUrl/api/payments/pro/status');
    return ProStatusModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ProPlanModel>> getPlans() async {
    final res = await _dio.get('$_baseUrl/api/payments/pro/plans');
    final data = (res.data as Map<String, dynamic>)['data'];
    final rawPlans = data is Map<String, dynamic> ? data['plans'] : null;

    if (rawPlans is! List) {
      return const [];
    }

    return rawPlans
        .whereType<Map>()
        .map((e) => ProPlanModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ProCheckoutModel> createCheckout({
    String? planType,
    int? amount,
  }) async {
    final payload = <String, dynamic>{};
    if (planType != null && planType.isNotEmpty) {
      payload['planType'] = planType;
    }
    if (amount != null) {
      payload['amount'] = amount;
    }

    final res = await _dio.post(
      '$_baseUrl/api/payments/pro/checkout',
      data: payload,
    );

    return ProCheckoutModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PayOSUrlsModel> getPayOSUrls() async {
    final res = await _dio.get('$_baseUrl/api/payments/payos/urls');
    return PayOSUrlsModel.fromJson(res.data as Map<String, dynamic>);
  }
}
