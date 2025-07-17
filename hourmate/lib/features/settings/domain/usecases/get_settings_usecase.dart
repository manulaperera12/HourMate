import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase({required this.repository});

  Future<AppSettings> call() async {
    return await repository.getSettings();
  }
}
