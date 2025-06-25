import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/introduction_provider.dart';
import '../widgets/intro_card_widget.dart';
import '../widgets/intro_widget_factory.dart';
import '../../domain/entities/intro_page_entity.dart';
import '../../domain/usecases/get_intro_pages_usecase.dart';

class IntroductionMainScreen extends StatelessWidget {
  const IntroductionMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IntroductionProvider(
        getIntroPagesUseCase: context.read<GetIntroPagesUseCase>(),
      ),
      child: Consumer<IntroductionProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xff040324),
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                onTap: () => provider.nextPage(context),
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: provider.pageController,
                  itemCount: provider.pages.length,
                  itemBuilder: (context, index) {
                    final pageEntity = provider.pages[index];

                    if (pageEntity.type == IntroPageType.gradientCard) {
                      return Center(child: IntroCardWidget(pageData: pageEntity));
                    }

                    if (pageEntity.type == IntroPageType.question) {
                      final contentWidget = IntroWidgetFactory.createWidget(pageEntity.widgetName);
                      return contentWidget ?? const Center(child: Text("Widget not found"));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}