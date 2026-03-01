import 'package:get/get.dart';

import '../controllers/bike_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/bike_repository.dart';
import '../repositories/fuel_repository.dart';
import '../repositories/maintenance_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/backup_service.dart';
import '../services/csv_export_service.dart';
import '../services/local_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BikeRepository(Get.find<LocalStorageService>()), fenix: true);
    Get.lazyPut(() => FuelRepository(Get.find<LocalStorageService>()), fenix: true);
    Get.lazyPut(
      () => MaintenanceRepository(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SettingsRepository(Get.find<LocalStorageService>()),
      fenix: true,
    );

    Get.lazyPut(
      () => BackupService(Get.find<LocalStorageService>()),
      fenix: true,
    );
    Get.lazyPut(() => CsvExportService(), fenix: true);

    Get.put(SettingsController(Get.find<SettingsRepository>()), permanent: true);
    Get.put(
      BikeController(Get.find<BikeRepository>(), Get.find<SettingsController>()),
      permanent: true,
    );
    Get.put(
      FuelController(
        Get.find<FuelRepository>(),
        Get.find<BikeController>(),
        Get.find<SettingsController>(),
      ),
      permanent: true,
    );
    Get.put(
      MaintenanceController(
        Get.find<MaintenanceRepository>(),
        Get.find<BikeController>(),
      ),
      permanent: true,
    );
    Get.put(DashboardController(Get.find<FuelController>()), permanent: true);
  }
}
