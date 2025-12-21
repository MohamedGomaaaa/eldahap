class TransactionModel {
  final bool success;
  final String message;
  final TransactionResult result;

  TransactionModel({
    required this.success,
    required this.message,
    required this.result,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result: json['result'] != null
          ? TransactionResult.fromJson(json['result'])
          : TransactionResult.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'result': result.toJson(),
  };
}

class TransactionResult {
  final String mode;
  final TransactionSummary summary;
  final List<TransactionData> data;
  final TransactionMeta meta;

  TransactionResult({
    required this.mode,
    required this.summary,
    required this.data,
    required this.meta,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      mode: json['mode'] ?? '',
      summary: json['summary'] != null
          ? TransactionSummary.fromJson(json['summary'])
          : TransactionSummary.empty(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TransactionData.fromJson(e))
          .toList() ??
          [],
      meta: json['meta'] != null
          ? TransactionMeta.fromJson(json['meta'])
          : TransactionMeta.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'summary': summary.toJson(),
    'data': data.map((e) => e.toJson()).toList(),
    'meta': meta.toJson(),
  };

  factory TransactionResult.empty() => TransactionResult(
    mode: '',
    summary: TransactionSummary.empty(),
    data: [],
    meta: TransactionMeta.empty(),
  );
}

class TransactionSummary {
  final num totalCredit;
  final num totalDebit;
  final String lastBalance;
  final int count;

  TransactionSummary({
    required this.totalCredit,
    required this.totalDebit,
    required this.lastBalance,
    required this.count,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalCredit: (json['total_credit'] ?? 0) is num
          ? json['total_credit']
          : num.tryParse(json['total_credit'].toString()) ?? 0,
      totalDebit: (json['total_debit'] ?? 0) is num
          ? json['total_debit']
          : num.tryParse(json['total_debit'].toString()) ?? 0,
      lastBalance: json['last_balance']?.toString() ?? '0.0',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_credit': totalCredit,
    'total_debit': totalDebit,
    'last_balance': lastBalance,
    'count': count,
  };

  factory TransactionSummary.empty() => TransactionSummary(
    totalCredit: 0,
    totalDebit: 0,
    lastBalance: '0.0',
    count: 0,
  );
}

class TransactionData {
  final int id;
  final num credit;
  final num debit;
  final String balance;
  final String type;
  final String amountType;
  final String createdBy;
  final String note;
  final String isApproval;
  final String requestAt;
  final String approveAt;
  final String createdAt;
  final String updatedAt;

  TransactionData({
    required this.id,
    required this.credit,
    required this.debit,
    required this.balance,
    required this.type,
    required this.amountType,
    required this.createdBy,
    required this.note,
    required this.isApproval,
    required this.requestAt,
    required this.approveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    return TransactionData(
      id: json['id'] ?? 0,
      credit: parseNum(json['credit']),
      debit: parseNum(json['debit']),
      balance: json['balance']?.toString() ?? '0.0',
      type: json['type']?.toString() ?? '',
      amountType: json['amount_type']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      isApproval: json['is_approval']?.toString() ?? '',
      requestAt: json['request_at']?.toString() ?? '',
      approveAt: json['approve_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'credit': credit,
    'debit': debit,
    'balance': balance,
    'type': type,
    'amount_type': amountType,
    'created_by': createdBy,
    'note': note,
    'is_approval': isApproval,
    'request_at': requestAt,
    'approve_at': approveAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class TransactionMeta {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int from;
  final int to;
  final int total;

  TransactionMeta({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.total,
  });

  factory TransactionMeta.fromJson(Map<String, dynamic> json) {
    return TransactionMeta(
      currentPage: json['current_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'per_page': perPage,
    'last_page': lastPage,
    'from': from,
    'to': to,
    'total': total,
  };

  factory TransactionMeta.empty() => TransactionMeta(
    currentPage: 0,
    perPage: 0,
    lastPage: 0,
    from: 0,
    to: 0,
    total: 0,
  );
}
