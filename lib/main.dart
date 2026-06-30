import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/convention_models.dart';
import 'services/auth_view_model.dart';
import 'services/network_monitor.dart';
import 'widgets/shared_components.dart';
import 'views/home_view.dart';
import 'views/schedule_view.dart';
import 'views/map_view.dart';
import 'views/photos_view.dart';
import 'views/info_view.dart';

void main() {
  runApp(const HAAConventionApp());
}

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  int _selectedTab = 0;
  InfoAccountSection? _moreSectionRequest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          HomeView(
            onNavigateTab: (tab) => setState(() => _selectedTab = tab),
            onNavigateMore: (section) {
              setState(() {
                _moreSectionRequest = section;
                _selectedTab = 4;
              });
            },
          ),
          const ScheduleView(),
          const MapView(),
          PhotosView(
            onNavigateTab: (tab) => setState(() => _selectedTab = tab),
            onNavigateMore: (section) {
              setState(() {
                _moreSectionRequest = section;
                _selectedTab = 4;
              });
            },
          ),
          InfoAccountView(
            moreSectionRequest: _moreSectionRequest,
            onSectionHandled: () => _moreSectionRequest = null,
          ),
        ],
      ),
      bottomNavigationBar: HAATabBar(
        selectedTab: _selectedTab,
        onTabSelected: (i) => setState(() => _selectedTab = i),
      ),
    );
  }
}

class HAAConventionApp extends StatelessWidget {
  const HAAConventionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => NetworkMonitor()),
      ],
      child: MaterialApp(
        title: 'HAA Convention 2026',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFDFAF6),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC8530A)),
          useMaterial3: true,
        ),
        home: const ContentView(),
      ),
    );
  }
}
