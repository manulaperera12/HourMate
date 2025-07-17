import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase({required this.repository});

  Future<void> call(AppSettings settings) async {
    await repository.saveSettings(settings);
  }
}
