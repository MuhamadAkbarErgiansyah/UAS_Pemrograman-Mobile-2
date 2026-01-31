import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Upload product image with optional category folder and custom filename
  Future<String> uploadProductImage(
    String category,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}.jpg';
    final filePath = '$category/$name';

    await _supabase.storage.from('product-images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('product-images').getPublicUrl(filePath);
  }

  /// Upload product image from File (for non-web platforms)
  Future<String> uploadProductImageFile(File file) async {
    return _uploadFile(file, 'product-images');
  }

  Future<String> uploadCategoryImage(File file) async {
    return _uploadFile(file, 'categories');
  }

  Future<String> uploadBannerImage(File file) async {
    return _uploadFile(file, 'banners');
  }

  /// Upload user avatar with bytes (web compatible)
  Future<String> uploadUserAvatarBytes(
    String userId,
    Uint8List bytes, {
    String extension = '.jpg',
  }) async {
    final fileName = '$userId$extension';

    await _supabase.storage.from('user-avatars').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('user-avatars').getPublicUrl(fileName);
  }

  Future<String> uploadUserAvatar(File file, String userId) async {
    final extension = path.extension(file.path);
    final fileName = '$userId$extension';

    await _supabase.storage
        .from('user-avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('user-avatars').getPublicUrl(fileName);
  }

  Future<String> _uploadFile(File file, String bucket) async {
    final extension = path.extension(file.path);
    final fileName = '${_uuid.v4()}$extension';

    await _supabase.storage.from(bucket).upload(fileName, file);

    return _supabase.storage.from(bucket).getPublicUrl(fileName);
  }

  Future<void> deleteFile(String bucket, String fileName) async {
    await _supabase.storage.from(bucket).remove([fileName]);
  }

  String getPublicUrl(String bucket, String fileName) {
    return _supabase.storage.from(bucket).getPublicUrl(fileName);
  }
}
