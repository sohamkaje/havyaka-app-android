import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/convention_models.dart';

class PhotosAPIError implements Exception {
  PhotosAPIError(this.message);
  final String message;
  @override
  String toString() => message;
}

class PhotosAPI {
  static const baseURL = 'https://havyak.org/api/photos.php';

  static Future<List<ConventionPhoto>> fetchGallery() async {
    final envelope = await _postJson({'action': 'list'});
    if (envelope['success'] != true) {
      throw PhotosAPIError(envelope['error'] as String? ?? 'Could not load gallery.');
    }
    final photos = envelope['photos'] as List<dynamic>? ?? [];
    return photos
        .map((p) => _photoFromApi(p as Map<String, dynamic>))
        .toList();
  }

  static Future<ConventionPhoto> upload({
    required List<int> fileData,
    required String fileName,
    required String mimeType,
    required PhotoMediaType mediaType,
    required String caption,
    required String day,
    required PhotoEventTag eventTag,
    required String uploadedBy,
    required String uploaderEmail,
  }) async {
    final sizeError = PhotosLimits.validateFileSize(fileData.length);
    if (sizeError != null) throw PhotosAPIError(sizeError);

    final boundary = 'Boundary-${DateTime.now().millisecondsSinceEpoch}';
    final body = <int>[];

    void appendField(String name, String value) {
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(utf8.encode('Content-Disposition: form-data; name="$name"\r\n\r\n'));
      body.addAll(utf8.encode('$value\r\n'));
    }

    appendField('action', 'upload');
    appendField('caption', caption);
    appendField('day', day);
    appendField('eventTag', eventTag.label);
    appendField('uploadedBy', uploadedBy);
    appendField('uploaderEmail', uploaderEmail);
    appendField('mediaType', mediaType.name);

    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode(
        'Content-Disposition: form-data; name="file"; filename="$fileName"\r\n'));
    body.addAll(utf8.encode('Content-Type: $mimeType\r\n\r\n'));
    body.addAll(fileData);
    body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final response = await http.post(
      Uri.parse(baseURL),
      headers: {'Content-Type': 'multipart/form-data; boundary=$boundary'},
      body: body,
    );

    final envelope = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 &&
        envelope['success'] == true &&
        envelope['photo'] != null) {
      return _photoFromApi(envelope['photo'] as Map<String, dynamic>);
    }
    throw PhotosAPIError(envelope['error'] as String? ?? 'Upload failed.');
  }

  static Future<void> delete({
    required String photoId,
    required String uploaderEmail,
  }) async {
    final envelope = await _postJson({
      'action': 'delete',
      'id': photoId,
      'uploaderEmail': uploaderEmail,
    });
    if (envelope['success'] != true) {
      throw PhotosAPIError(envelope['error'] as String? ?? 'Could not delete photo.');
    }
  }

  static ConventionPhoto _photoFromApi(Map<String, dynamic> p) {
    final mediaTypeStr = p['mediaType'] as String? ?? 'image';
    return ConventionPhoto(
      id: p['id'] as String? ?? '',
      mediaURL: p['mediaURL'] as String?,
      caption: p['caption'] as String? ?? '',
      uploadedBy: p['uploadedBy'] as String? ?? '',
      uploaderEmail: p['uploaderEmail'] as String? ?? '',
      day: p['day'] as String? ?? '',
      eventTag: PhotoEventTag.fromString(p['eventTag'] as String? ?? 'General'),
      mediaType: mediaTypeStr == 'video' ? PhotoMediaType.video : PhotoMediaType.image,
    );
  }

  static Future<Map<String, dynamic>> _postJson(Map<String, String> body) async {
    final response = await http.post(
      Uri.parse(baseURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
