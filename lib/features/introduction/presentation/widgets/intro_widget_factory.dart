import 'package:flutter/material.dart';

import 'intropages/diet_page_content.dart';
import 'intropages/energy_page_content.dart';
import 'intropages/getting_started_page_content.dart';
import 'intropages/introduction_page_content.dart';
import 'intropages/school_page_content.dart';
import 'intropages/sdg_page_content.dart';
import 'intropages/transport_page_content.dart';
import 'intropages/your_concerns_page_content.dart';

typedef WidgetBuilderFunc = Widget Function();

class IntroWidgetFactory {
  static final Map<String, WidgetBuilderFunc> _widgetBuilders = {
    'IntroductionPageContent': () => const IntroductionPageContent(),
    'GettingStartedPageContent': () => const GettingStartedPageContent(),
    'DietPageContent': () => const DietPageContent(),
    'EnergyPageContent': () => const EnergyPageContent(),
    'TransportPageContent': () => const TransportPageContent(),
    'SchoolPageContent': () => const SchoolPageContent(),
    'SDGPageContent': () => const SDGPageContent(),
    'YourConcernsPageContent': () => const YourConcernsPageContent()
  };

  static Widget? createWidget(String? widgetName) {
    if (widgetName == null || !_widgetBuilders.containsKey(widgetName)) {
      return null;
    }
    return _widgetBuilders[widgetName]!();
  }
}