import 'package:ui_demo_app/bank_card_details_page/card_details_entity.dart';
import 'package:ui_demo_app/bank_card_details_page/card_transaction_entity.dart';

const cards = <CardDetail>[
  CardDetail(
    cardNumber: "6456 7104 8655 0127",
    expiryDate: "02/22",
    cvcCode: 486,
  ),
  CardDetail(
    cardNumber: "4589 1547 8655 0127",
    expiryDate: "05/21",
    cvcCode: 786,
  ),
  CardDetail(
    cardNumber: "1745 7104 9655 0124",
    expiryDate: "02/26",
    cvcCode: 132,
  ),
];

const cardTransactions = <CardTransaction>[
  CardTransaction(
    typeDescription: "Electronics",
    companyName: "Apple Store",
    amount: -799.99,
    assetName: "apple_logo.svg",
    assetType: AssetType.svg,
  ),
  CardTransaction(
    typeDescription: "Cafe and Restruant",
    companyName: "Dominos Pizza",
    amount: -40.50,
    assetName: "dominos_logo.png",
    assetType: AssetType.png,
  ),
  CardTransaction(
    typeDescription: "Direct Bank Transfer",
    companyName: "5315********3205",
    amount: 200.05,
    assetName: "bank_icon.png",
    assetType: AssetType.png,
  ),
  CardTransaction(
    typeDescription: "Cafe and Restruant",
    companyName: "Starbucks",
    amount: -10.25,
    assetName: "startbucks_logo.svg",
    assetType: AssetType.svg,
  ),
  CardTransaction(
    typeDescription: "Online Purchase",
    companyName: "Spotify Premium",
    amount: -12.00,
    assetName: "spotify_logo.svg",
    assetType: AssetType.svg,
  ),
  CardTransaction(
    typeDescription: "Online Purchase",
    companyName: "Dribble Subscription",
    amount: -60.00,
    assetName: "dribble_logo.svg",
    assetType: AssetType.svg,
  ),
  CardTransaction(
    typeDescription: "Online Purchase",
    companyName: "Amazon Return",
    amount: 200.50,
    assetName: "amazon_logo.svg",
    assetType: AssetType.svg,
  ),
  CardTransaction(
    typeDescription: "Direct Bank Transfer",
    companyName: "5315********3205",
    amount: -800.00,
    assetName: "bank_icon.png",
    assetType: AssetType.png,
  ),
];
