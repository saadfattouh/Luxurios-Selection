import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/environment.dart';
import 'design/tokens.dart';
import 'features/exhibition/data/exhibition_repository.dart';
import 'features/exhibition/presentation/exhibition_view_model.dart';
import 'features/exhibition/presentation/entrance_view.dart';
import 'features/exhibition/presentation/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CollectorApp(
      repository: ApiExhibitionRepository(
        ApiClient(http.Client(), Environment.apiUri),
      ),
    ),
  );
}

class CollectorApp extends StatelessWidget {
  const CollectorApp({super.key, required this.repository});
  final ExhibitionRepository repository;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => ExhibitionViewModel(repository)..load(),
    child: MaterialApp(
      title: 'Luxurious Selection',
      debugShowCheckedModeBanner: false,
      theme: ExhibitionTokens.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final home = settings.name == '/exhibition';
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: ExhibitionTokens.transition,
          reverseTransitionDuration: ExhibitionTokens.transition,
          pageBuilder: (context, animation, secondaryAnimation) => HeroMode(
            enabled: !MediaQuery.disableAnimationsOf(context),
            child: home ? const HomeView() : const EntranceView(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (MediaQuery.disableAnimationsOf(context)) return child;
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: ExhibitionTokens.curve,
              ),
              child: child,
            );
          },
        );
      },
    ),
  );
}
