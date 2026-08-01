import 'package:flutter/material.dart';
import 'package:tibetan_bible_app/themes/app_font.dart';

void showSettingSheet(
  BuildContext context,
  AppSettings settings,
  void Function(AppSettings newSettings) onSettingsChanged,
) {
  final appSettings = AppSettings.instance;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return AnimatedBuilder(
        animation: appSettings,
        builder: (context, _) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 색 테마
                const Text("Theme", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ToggleButtons(
                  isSelected: [
                    appSettings.themeMode == ThemeMode.system,
                    appSettings.themeMode == ThemeMode.light,
                    appSettings.themeMode == ThemeMode.dark,
                  ],
                  onPressed: (index) {
                    if (index == 0) appSettings.setThemeMode(ThemeMode.system);
                    if (index == 1) appSettings.setThemeMode(ThemeMode.light);
                    if (index == 2) appSettings.setThemeMode(ThemeMode.dark);
                  },
                  borderRadius: BorderRadius.circular(10),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text("System", style: TextStyle(fontSize: 18)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text("Light", style: TextStyle(fontSize: 18)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text("Dark", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 글자 크기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Font size", style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            appSettings.setFontSize(
                              (appSettings.fontSize - 1).clamp(12, 40),
                            );
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          appSettings.fontSize.toInt().toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          onPressed: () {
                            appSettings.setFontSize(
                              (appSettings.fontSize + 1).clamp(12, 40),
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
