import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable, IconData;

//only adding things to make the ui
@immutable
class CardTransaction extends Equatable {
  final String companyName;
  final String typeDescription;
  final String assetName;
  final double amount; //up to 2 decimal point
  final AssetType assetType;

  const CardTransaction(
      {required this.typeDescription,
      required this.companyName,
      required this.amount,
      required this.assetName,
      required this.assetType});

  @override
  List<Object?> get props => [companyName, typeDescription, amount];
}

enum AssetType { svg, png, iconData }
