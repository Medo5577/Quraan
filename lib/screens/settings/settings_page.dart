import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    'Dark',
                    'dark',
                    provider.settings.theme,
                  ),
                  _buildThemeOption(
                    context,
                    'Light',
                    'light',
                    provider.settings.theme,
                  ),
                  _buildThemeOption(
                    context,
                    'Sepia',
                    'sepia',
                    provider.settings.theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Display Mode Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Display Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDisplayModeOption(
                    context,
                    'List (Scroll)',
                    'list',
                    provider.settings.displayMode,
                  ),
                  _buildDisplayModeOption(
                    context,
                    'Compact View',
                    'compact',
                    provider.settings.displayMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Font Size Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Font Size',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${provider.settings.fontSize.round()}px',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: provider.settings.fontSize,
                    min: 16,
                    max: 40,
                    divisions: 24,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white24,
                    onChanged: (value) => provider.updateFontSize(value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Arabic Font Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arabic Font',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFontOption(
                    context,
                    'Noto Naskh',
                    'naskh',
                    provider.settings.arabicFont,
                  ),
                  _buildFontOption(
                    context,
                    'Amiri',
                    'amiri',
                    provider.settings.arabicFont,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reciter Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reciter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: provider.settings.reciterId,
                        isExpanded: true,
                        dropdownColor: AppColors.background,
                        style: const TextStyle(color: Colors.white),
                        items: provider.availableReciters.map((reciter) {
                          return DropdownMenuItem(
                            value: reciter.id,
                            child: Text(reciter.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) provider.updateReciter(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Display Options Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Display Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchOption(
                    context,
                    'Show Translation',
                    provider.settings.showTranslation,
                    (value) => provider.updateShowTranslation(value),
                  ),
                  _buildSwitchOption(
                    context,
                    'Show Tafsir',
                    provider.settings.showTafsir,
                    (value) => provider.updateShowTafsir(value),
                  ),
                  _buildSwitchOption(
                    context,
                    'Enhanced Audio Sync (Experimental)',
                    provider.settings.audioSync,
                    (value) {
                      provider.settings = provider.settings.copyWith(
                        audioSync: value,
                      );
                      provider.saveSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Translations Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select translations to download and display',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children: provider.availableTranslations.map((
                          translation,
                        ) {
                          final isSelected = provider
                              .settings
                              .selectedTranslations
                              .contains(translation.identifier);
                          return CheckboxListTile(
                            title: Text(
                              '${translation.englishName} (${translation.language})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: isSelected,
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            onChanged: (value) {
                              final List<String> updated = List.from(
                                provider.settings.selectedTranslations,
                              );
                              if (value == true) {
                                updated.add(translation.identifier);
                              } else {
                                updated.remove(translation.identifier);
                              }
                              provider.updateSelectedTranslations(updated);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tafsirs Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tafsirs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select tafsirs to download and display',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children: provider.availableTafsirs.map((tafsir) {
                          final isSelected = provider.settings.selectedTafsirs
                              .contains(tafsir.identifier);
                          return CheckboxListTile(
                            title: Text(
                              '${tafsir.name} (${tafsir.language})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: isSelected,
                            activeColor: AppColors.primary,
                            checkColor: Colors.white,
                            onChanged: (value) {
                              final List<String> updated = List.from(
                                provider.settings.selectedTafsirs,
                              );
                              if (value == true) {
                                updated.add(tafsir.identifier);
                              } else {
                                updated.remove(tafsir.identifier);
                              }
                              provider.updateSelectedTafsirs(updated);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Offline Mode Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_off, color: AppColors.warning, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Offline Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Download content for offline access',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  // Download Text Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha((255 * 0.2).round()),
                          AppColors.secondary.withAlpha((255 * 0.1).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha((255 * 0.5).round()),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          provider.offlineStatus.textDownloaded
                              ? Icons.check_circle
                              : Icons.download,
                          color: provider.offlineStatus.textDownloaded
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.offlineStatus.textDownloaded
                                    ? 'Text Downloaded'
                                    : 'Download Text & Translations',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!provider.offlineStatus.textDownloaded)
                                Text(
                                  '(${provider.offlineDbSize.toStringAsFixed(1)} MB)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (provider.downloadProgress.active)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              value: provider.downloadProgress.totalItems > 0
                                  ? provider.downloadProgress.downloadedItems /
                                      provider.downloadProgress.totalItems
                                  : null,
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(
                              provider.offlineStatus.textDownloaded
                                  ? Icons.refresh
                                  : Icons.download,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              if (!provider.offlineStatus.textDownloaded) {
                                provider.startTextDownload();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Manage Audio (Disabled for now)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.05).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withAlpha((255 * 0.1).round()),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.headphones,
                          color: Colors.white.withAlpha((255 * 0.3).round()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Audio',
                                style: TextStyle(
                                  color: Colors.white.withAlpha((255 * 0.3).round()),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '(${provider.audioDbSize.toStringAsFixed(1)} MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha((255 * 0.2).round()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.lock_outline,
                          color: Colors.white.withAlpha((255 * 0.2).round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Audio offline storage not supported yet.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha((255 * 0.3).round()),
                    ),
                  ),
                  if (provider.offlineStatus.textDownloaded) ...[
                    const SizedBox(height: 16),
                    // Clear Offline Data
                    TextButton.icon(
                      onPressed: () => _showClearOfflineDataDialog(context, provider),
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      label: const Text(
                        'Clear Offline Data',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                  // Offline Indicator
                  if (provider.isOffline)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha((255 * 0.2).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withAlpha((255 * 0.5).round()),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You are offline',
                            style: TextStyle(
                              color: AppColors.warning.withAlpha((255 * 0.8).round()),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Language Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    'العربية',
                    'ar',
                    provider.currentLang,
                  ),
                  _buildLanguageOption(
                    context,
                    'English',
                    'en',
                    provider.currentLang,
                  ),
                  _buildLanguageOption(
                    context,
                    'Türkçe',
                    'tr',
                    provider.currentLang,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    String value,
    String currentTheme,
  ) {
    final isSelected = currentTheme == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.white54),
      onTap: () {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.updateTheme(value);
      },
    );
  }

  Widget _buildDisplayModeOption(
    BuildContext context,
    String label,
    String value,
    String currentMode,
  ) {
    final isSelected = currentMode == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.white54),
      onTap: () {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.updateDisplayMode(value);
      },
    );
  }

  Widget _buildFontOption(
    BuildContext context,
    String label,
    String value,
    String currentFont,
  ) {
    final isSelected = currentFont == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.white54),
      onTap: () {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.updateArabicFont(value);
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String value,
    String currentLang,
  ) {
    final isSelected = currentLang == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.white54),
      onTap: () {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.updateLanguage(value);
      },
    );
  }

  Widget _buildSwitchOption(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  void _showClearOfflineDataDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Downloaded Data?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove all offline content. You will need to download them again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearOfflineData();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
