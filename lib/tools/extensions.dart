import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    if (this.year == other.year &&
        this.month == other.month &&
        this.day == other.day) {
      print(
          this.toString() + ' and ' + other.toString() + ' are the same date!');
      return true;
    } else
      return false;
  }

  bool isBeforeDate(DateTime other) {
    return this.year == other.year &&
            this.month == other.month &&
            this.day < other.day ||
        this.year == other.year && this.month < other.month ||
        this.year < other.year;
  }

  bool isAfterDate(DateTime other) {
    return this.year == other.year &&
            this.month == other.month &&
            this.day > other.day ||
        this.year == other.year && this.month > other.month ||
        this.year > other.year;
  }

  formatForUser() {
    DateFormat dateFormat = DateFormat("dd.MM.yyyy");
    return dateFormat.format(this).toString();
  }

  formatForJson() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    return dateFormat.format(this).toString();
  }
}
