import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String image;
  final Color primaryColor;
  final Color secondaryColor;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.image,
    required this.primaryColor,
    required this.secondaryColor,
  });
}