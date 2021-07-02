import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
class CardDetail extends Equatable {
  final String cardNumber;
  final String expiryDate;
  final int cvcCode;

  const CardDetail(
      {required this.cvcCode,
      required this.expiryDate,
      required this.cardNumber});

  @override
  List<Object?> get props => [cardNumber, expiryDate, cvcCode];
}
