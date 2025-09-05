import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  static const String chartImagesBucket = 'chart-images';

  // Upload chart image
  Future<String?> uploadChartImage({
    required String fileName,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to upload files');
      }

      // Create user-specific folder path
      final filePath = '${currentUser.id}/$fileName';

      // Upload file to storage
      await _client.storage.from(chartImagesBucket).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType ?? 'image/png',
              upsert: true, // Allow overwrite
            ),
          );

      // Get public URL (for private buckets, this will be a signed URL)
      final publicUrl =
          _client.storage.from(chartImagesBucket).getPublicUrl(filePath);

      debugPrint('Chart image uploaded successfully: $filePath');
      return publicUrl;
    } catch (error) {
      debugPrint('Upload chart image error: $error');
      return null;
    }
  }

  // Upload from file (mobile/desktop)
  Future<String?> uploadChartImageFromFile({
    required String fileName,
    required String filePath,
    String? contentType,
  }) async {
    try {
      if (kIsWeb) {
        throw Exception('Use uploadChartImage for web platforms');
      }

      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      return await uploadChartImage(
        fileName: fileName,
        fileBytes: fileBytes,
        contentType: contentType,
      );
    } catch (error) {
      debugPrint('Upload from file error: $error');
      return null;
    }
  }

  // Download chart image
  Future<Uint8List?> downloadChartImage(String filePath) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to download files');
      }

      // Only allow users to download their own files
      if (!filePath.startsWith(currentUser.id)) {
        throw Exception('Access denied: Cannot download other users files');
      }

      final response =
          await _client.storage.from(chartImagesBucket).download(filePath);

      debugPrint('Chart image downloaded: $filePath');
      return response;
    } catch (error) {
      debugPrint('Download chart image error: $error');
      return null;
    }
  }

  // Get signed URL for private access
  Future<String?> getSignedUrl(String filePath, {int expiresIn = 3600}) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in');
      }

      // Only allow users to access their own files
      if (!filePath.startsWith(currentUser.id)) {
        throw Exception('Access denied: Cannot access other users files');
      }

      final signedUrl = await _client.storage
          .from(chartImagesBucket)
          .createSignedUrl(filePath, expiresIn);

      return signedUrl;
    } catch (error) {
      debugPrint('Get signed URL error: $error');
      return null;
    }
  }

  // Delete chart image
  Future<bool> deleteChartImage(String filePath) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return false;

      // Only allow users to delete their own files
      if (!filePath.startsWith(currentUser.id)) {
        throw Exception('Access denied: Cannot delete other users files');
      }

      await _client.storage.from(chartImagesBucket).remove([filePath]);

      debugPrint('Chart image deleted: $filePath');
      return true;
    } catch (error) {
      debugPrint('Delete chart image error: $error');
      return false;
    }
  }

  // List user's chart images
  Future<List<FileObject>> listUserChartImages() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return [];

      final response = await _client.storage
          .from(chartImagesBucket)
          .list(path: currentUser.id);

      return response;
    } catch (error) {
      debugPrint('List chart images error: $error');
      return [];
    }
  }

  // Get file info
  Future<FileObject?> getFileInfo(String filePath) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return null;

      // Only allow users to get info for their own files
      if (!filePath.startsWith(currentUser.id)) {
        throw Exception('Access denied: Cannot access other users files');
      }

      final files = await _client.storage
          .from(chartImagesBucket)
          .list(path: filePath.substring(0, filePath.lastIndexOf('/')));

      final fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
      return files.firstWhere(
        (file) => file.name == fileName,
        orElse: () => FileObject(
            name: '',
            id: '',
            updatedAt: '',
            createdAt: '',
            lastAccessedAt: '',
            metadata: {}),
      );
    } catch (error) {
      debugPrint('Get file info error: $error');
      return null;
    }
  }

  // Generate unique filename for charts
  String generateChartFileName(String analysisId, {String extension = 'png'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'chart_${analysisId}_$timestamp.$extension';
  }

  // Generate analysis folder path
  String getAnalysisFolderPath(String analysisId) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return '';
    return '${currentUser.id}/analyses/$analysisId';
  }

  // Upload multiple chart images for an analysis
  Future<List<String>> uploadAnalysisCharts({
    required String analysisId,
    required Map<String, Uint8List> chartImages, // filename -> bytes
  }) async {
    try {
      final uploadedUrls = <String>[];

      for (final entry in chartImages.entries) {
        final fileName = entry.key;
        final fileBytes = entry.value;

        final fullFileName = 'analysis_${analysisId}_$fileName';
        final url = await uploadChartImage(
          fileName: fullFileName,
          fileBytes: fileBytes,
          contentType: 'image/png',
        );

        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      debugPrint(
          'Uploaded ${uploadedUrls.length} chart images for analysis: $analysisId');
      return uploadedUrls;
    } catch (error) {
      debugPrint('Upload analysis charts error: $error');
      return [];
    }
  }
}
