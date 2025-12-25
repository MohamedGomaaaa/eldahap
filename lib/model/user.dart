class User {
  int? id;
  String? name;
  String? email;
  String? mobile;
  int? isVerified;
  int? publish;
  String? type;
  String? mode;
num? balance;
  String? nationalIdFront;
  String? nationalIdBack;
  bool? nationalIdFrontApproved;
  bool? nationalIdBackApproved;

  User({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.isVerified,
    this.publish,
    this.type,
    this.mode,
    this.balance,
    this.nationalIdFront,
    this.nationalIdBack,
    this.nationalIdFrontApproved,
    this.nationalIdBackApproved,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    isVerified = json['is_verified'];
    publish = json['publish'];
    type = json['type'];
    mode = json['mode'];
    balance = double.tryParse(json['balance']?.toString() ?? "0") ?? 0.0;
    nationalIdFront = json['national_id_front'];
    nationalIdBack = json['national_id_back'];
    nationalIdFrontApproved = json['national_id_front_approved'];
    nationalIdBackApproved = json['national_id_back_approved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['is_verified'] = isVerified;
    data['publish'] = publish;
    data['type'] = type;
    data['mode'] = mode;
    data['balance'] = balance?.toString();
    data['national_id_front'] = nationalIdFront;
    data['national_id_back'] = nationalIdBack;
    data['national_id_front_approved'] = nationalIdFrontApproved;
    data['national_id_back_approved'] = nationalIdBackApproved;
    return data;
  }
}
