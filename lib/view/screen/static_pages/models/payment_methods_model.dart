class PaymentMethodsResponse {
  final bool success;
  final String message;
  final List<PaymentMethod> result;

  PaymentMethodsResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => PaymentMethod.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'result': result.map((e) => e.toJson()).toList(),
    };
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final String value;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.value,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }
}
