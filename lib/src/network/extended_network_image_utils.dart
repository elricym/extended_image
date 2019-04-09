import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:extended_image/src/network/extended_network_image_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const String CacheImageFolderName = "cacheimage";

String keyToMd5(String key) => md5.convert(utf8.encode(key)).toString();

/// Clear the disk cache directory then return if it succeed.
///  <param name="duration">timespan to compute whether file has expired or not</param>
Future<bool> clearDiskCachedImages({Duration duration}) async {
  try {
    Directory _cacheImagesDirectory = Directory(
        join((await getTemporaryDirectory()).path, CacheImageFolderName));
    if (_cacheImagesDirectory.existsSync()) {
      if (duration == null) {
        _cacheImagesDirectory.deleteSync(recursive: true);
      } else {
        var now = DateTime.now();
        for (var file in _cacheImagesDirectory.listSync()) {
          FileStat fs = file.statSync();
          if (now.subtract(duration).isAfter(fs.changed)) {
            //print("remove expired cached image");
            file.deleteSync(recursive: true);
          }
        }
      }
    }
  } catch (_) {
    return false;
  }
  return true;
}

List<ExtendedNetworkImageProvider> userCancelCache =
    List<ExtendedNetworkImageProvider>();
