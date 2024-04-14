import 'package:flutter/material.dart';

Future<DateTime?> selectDate(context) async => await showDatePicker(
      context: context,
      locale: const Locale('pl'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
