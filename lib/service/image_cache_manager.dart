import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../constants/constants.dart';

class MyImageCacheManager {
  static CacheManager profileCacheManager = CacheManager(
    Config(
      Constants.userImageKey,
      maxNrOfCacheObjects: 20,
      stalePeriod: const Duration(days: 5),
    ),
  );

  static CacheManager generatedImageCacheManager = CacheManager(
    Config(
      Constants.generateImageKeys,
      maxNrOfCacheObjects: 100,
      stalePeriod: const Duration(days: 5),
    ),
  );
}
