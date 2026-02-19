import 'package:flutter/material.dart';

IconData habitIconData(String name) => switch (name) {
      'yoga' => Icons.self_improvement,
      'water' => Icons.water_drop,
      'book' => Icons.menu_book,
      'gym' => Icons.fitness_center,
      'meditation' => Icons.spa,
      'walk' => Icons.directions_walk,
      'sleep' => Icons.bedtime,
      'nutrition' => Icons.restaurant,
      _ => Icons.check_circle_outline,
    };