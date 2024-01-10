import 'package:json_annotation/json_annotation.dart';

part 'verification_state_model.g.dart';

@JsonSerializable()
class VerificationStateModel {
  bool isMessageSended;
  bool isCodeSended;
  String? phoneNumber;
  String? codeToken;
  DateTime? expireAt;
  int? code;

  VerificationStateModel({
    required this.isMessageSended,
    required this.isCodeSended,
    this.phoneNumber,
    this.codeToken,
    this.expireAt,
    this.code,
  });

  VerificationStateModel copyWith({
    bool? isMessageSended,
    bool? isCodeSended,
    String? phoneNumber,
    String? codeToken,
    DateTime? expireAt,
    int? code,
  }) =>
      VerificationStateModel(
        isMessageSended: isMessageSended ?? this.isMessageSended,
        isCodeSended: isCodeSended ?? this.isCodeSended,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        codeToken: codeToken ?? this.codeToken,
        expireAt: expireAt ?? this.expireAt,
        code: code ?? this.code,
      );

  factory VerificationStateModel.fromJson(Map<String, dynamic> json) =>
      _$VerificationStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationStateModelToJson(this);
}
