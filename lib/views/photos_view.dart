import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/convention_models.dart';
import '../services/auth_view_model.dart';
import '../services/network_monitor.dart';
import '../services/photo_image_processor.dart';
import '../services/photos_api.dart';
import '../theme/design_system.dart';
import '../widgets/shared_components.dart';

class PhotosView extends StatefulWidget {
  const PhotosView({super.key, required this.onNavigateTab, required this.onNavigateMore});
  final ValueChanged<int> onNavigateTab;
  final ValueChanged<InfoAccountSection> onNavigateMore;

  @override
  State<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends State<PhotosView> {
  String selectedDayFilter = 'All';
  PhotoEventTag? selectedEventFilter;
  List<ConventionPhoto> photos = [];
  bool isLoadingGallery = false;
  String? galleryError;

  static const dayFilters = ['All', 'July 2', 'July 3', 'July 4', 'July 5'];

  List<ConventionPhoto> get filteredPhotos {
    return photos.where((p) {
      final dayMatch = selectedDayFilter == 'All' || p.day == selectedDayFilter;
      final eventMatch = selectedEventFilter == null || p.eventTag == selectedEventFilter;
      return dayMatch && eventMatch;
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthViewModel>();
    final network = context.read<NetworkMonitor>();
    if (auth.isLoggedIn && network.isConnected && photos.isEmpty && !isLoadingGallery) {
      _loadGallery();
    }
  }

  Future<void> _loadGallery() async {
    setState(() { isLoadingGallery = true; galleryError = null; });
    try {
      final result = await PhotosAPI.fetchGallery();
      if (mounted) setState(() => photos = result);
    } catch (e) {
      if (mounted) setState(() => galleryError = e.toString());
    }
    if (mounted) setState(() => isLoadingGallery = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final network = context.watch<NetworkMonitor>();

    return Column(
      children: [
        const HAANavBar(title: 'Photos', subtitle: 'Convention memories'),
        if (!network.isConnected)
          const OfflineBanner(message: 'No internet connection. The photo gallery requires service to view and upload.'),
        Expanded(
          child: auth.isLoggedIn
              ? _galleryContent(auth, network)
              : _loginGate(),
        ),
      ],
    );
  }

  Widget _loginGate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 44, color: HAAColors.orange.withValues(alpha: 0.7)),
            const SizedBox(height: 24),
            Text('Sign in to view photos', style: HAAFonts.serif(22, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
            const SizedBox(height: 12),
            Text(
              'The shared convention gallery is available to logged-in attendees only.',
              textAlign: TextAlign.center,
              style: HAAFonts.sans(14).copyWith(color: HAAColors.muted),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => widget.onNavigateMore(InfoAccountSection.account),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(color: HAAColors.orange, borderRadius: BorderRadius.circular(HAARadius.md)),
                child: Text('Go to Account', style: HAAFonts.sans(15, weight: FontWeight.bold).copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _galleryContent(AuthViewModel auth, NetworkMonitor network) {
    return Column(
      children: [
        GestureDetector(
          onTap: network.isConnected ? () => _showUploadSheet(auth) : null,
          child: Opacity(
            opacity: network.isConnected ? 1 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 12),
              color: HAAColors.orangeLight,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: HAAColors.orange.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: HAAColors.orange, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share your convention moments', style: HAAFonts.sans(13, weight: FontWeight.bold).copyWith(color: HAAColors.charcoal)),
                        Text('Photos & videos up to ${PhotosLimits.maxUploadMB} MB', style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle, color: HAAColors.orange, size: 22),
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 8),
          child: Row(
            children: dayFilters.map((day) {
              final selected = selectedDayFilter == day;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => selectedDayFilter = day),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? HAAColors.charcoal : Colors.white,
                      borderRadius: BorderRadius.circular(HAARadius.pill),
                      border: selected ? null : Border.all(color: HAAColors.border, width: 0.5),
                    ),
                    child: Text(day, style: HAAFonts.sans(12, weight: FontWeight.w600).copyWith(color: selected ? HAAColors.gold : HAAColors.muted)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 8),
          child: Row(
            children: [
              _eventFilterChip(null, 'All Events', Icons.photo_library),
              ...PhotoEventTag.values.map((tag) => _eventFilterChip(tag, tag.label, tag.icon)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: HAASpacing.lg, vertical: 8),
          child: Row(
            children: [
              Text('${filteredPhotos.length} item${filteredPhotos.length == 1 ? '' : 's'}', style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
              if (selectedEventFilter != null || selectedDayFilter != 'All')
                Text(' · filtered', style: HAAFonts.sans(12).copyWith(color: HAAColors.orange)),
              const Spacer(),
              GestureDetector(
                onTap: network.isConnected ? () => _showUploadSheet(auth) : null,
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 11, color: HAAColors.orange),
                    Text('Add yours', style: HAAFonts.sans(12, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoadingGallery && photos.isEmpty
              ? const Center(child: CircularProgressIndicator(color: HAAColors.orange))
              : filteredPhotos.isEmpty
                  ? _emptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                      itemCount: filteredPhotos.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _showPhotoDetail(filteredPhotos[i], auth),
                        child: _PhotoTile(photo: filteredPhotos[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _eventFilterChip(PhotoEventTag? tag, String label, IconData icon) {
    final selected = selectedEventFilter == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedEventFilter = tag == selectedEventFilter ? null : tag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? HAAColors.orangeLight : Colors.white,
            borderRadius: BorderRadius.circular(HAARadius.pill),
            border: Border.all(color: selected ? HAAColors.orange.withValues(alpha: 0.4) : HAAColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: selected ? HAAColors.orange : HAAColors.muted),
              const SizedBox(width: 4),
              Text(label, style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: selected ? HAAColors.orange : HAAColors.muted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final message = galleryError ?? (photos.isEmpty
        ? 'No photos yet. Be the first to share a convention memory!'
        : 'No photos match this filter');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 40, color: HAAColors.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: HAAFonts.sans(14).copyWith(color: HAAColors.muted)),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(AuthViewModel auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => _UploadPhotoSheet(
        uploaderName: auth.displayName,
        uploaderEmail: auth.profile.email,
        onUpload: (photo) => setState(() => photos.insert(0, photo)),
      ),
    );
  }

  void _showPhotoDetail(ConventionPhoto photo, AuthViewModel auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HAAColors.cream,
      builder: (ctx) => _PhotoDetailSheet(
        photo: photo,
        currentUserEmail: auth.profile.email,
        onDelete: (id) => setState(() => photos.removeWhere((p) => p.id == id)),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});
  final ConventionPhoto photo;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo.mediaURL != null && !photo.isVideo)
            CachedNetworkImage(imageUrl: photo.mediaURL!, fit: BoxFit.cover)
          else if (photo.isVideo)
            Container(color: Colors.black87, child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 36))
          else
            Container(color: photo.accentColor.withValues(alpha: 0.15), child: Icon(Icons.photo, color: photo.accentColor.withValues(alpha: 0.7), size: 28)),
          if (photo.isVideo)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.videocam, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadPhotoSheet extends StatefulWidget {
  const _UploadPhotoSheet({required this.uploaderName, required this.uploaderEmail, required this.onUpload});
  final String uploaderName;
  final String uploaderEmail;
  final ValueChanged<ConventionPhoto> onUpload;

  @override
  State<_UploadPhotoSheet> createState() => _UploadPhotoSheetState();
}

class _UploadPhotoSheetState extends State<_UploadPhotoSheet> {
  String caption = '';
  String selectedDay = 'July 3';
  PhotoEventTag selectedTag = PhotoEventTag.general;
  Uint8List? fileData;
  PhotoMediaType mediaType = PhotoMediaType.image;
  String fileName = 'upload.jpg';
  bool isUploading = false;
  bool showSuccess = false;
  String? uploadError;

  Future<void> _pickMedia() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.photo), title: const Text('Photo'), onTap: () => Navigator.pop(ctx, 'photo')),
            ListTile(leading: const Icon(Icons.videocam), title: const Text('Video'), onTap: () => Navigator.pop(ctx, 'video')),
          ],
        ),
      ),
    );
    if (choice == null) return;

    final picker = ImagePicker();
    if (choice == 'video') {
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;
      final data = await video.readAsBytes();
      final sizeError = PhotosLimits.validateFileSize(data.length);
      if (sizeError != null) { setState(() => uploadError = sizeError); return; }
      setState(() {
        fileData = data;
        mediaType = PhotoMediaType.video;
        fileName = 'upload.mp4';
        uploadError = null;
      });
    } else {
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      var data = await picked.readAsBytes();
      final processed = await PhotoImageProcessor.prepareForUpload(data);
      if (processed != null) data = processed;
      final sizeError = PhotosLimits.validateFileSize(data.length);
      if (sizeError != null) { setState(() => uploadError = sizeError); return; }
      setState(() {
        fileData = data;
        mediaType = PhotoMediaType.image;
        fileName = 'upload.jpg';
        uploadError = null;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (fileData == null) return;
    setState(() { isUploading = true; uploadError = null; });
    try {
      final photo = await PhotosAPI.upload(
        fileData: fileData!,
        fileName: fileName,
        mimeType: mediaType == PhotoMediaType.video ? 'video/mp4' : 'image/jpeg',
        mediaType: mediaType,
        caption: caption.isEmpty ? 'Convention moment' : caption,
        day: selectedDay,
        eventTag: selectedTag,
        uploadedBy: widget.uploaderName,
        uploaderEmail: widget.uploaderEmail,
      );
      widget.onUpload(photo);
      setState(() { isUploading = false; showSuccess = true; });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { isUploading = false; uploadError = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(HAASpacing.lg),
          children: [
            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: HAAFonts.sans(14).copyWith(color: HAAColors.muted))),
                const Spacer(),
                Text('Add Photo or Video', style: HAAFonts.sans(16, weight: FontWeight.w600)),
                const Spacer(),
                const SizedBox(width: 60),
              ],
            ),
            if (uploadError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(HAARadius.md)),
                child: Text(uploadError!, style: HAAFonts.sans(13).copyWith(color: HAAColors.charcoal)),
              ),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(HAARadius.lg),
                  border: Border.all(color: HAAColors.orange.withValues(alpha: 0.5), width: 1.5),
                ),
                child: fileData == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate, size: 36, color: HAAColors.orange),
                          Text('Tap to choose a photo or video', style: HAAFonts.sans(14, weight: FontWeight.w600)),
                          Text('Up to ${PhotosLimits.maxUploadMB} MB', style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(mediaType == PhotoMediaType.video ? Icons.videocam : Icons.check_circle, size: 36, color: HAAColors.success),
                          Text(mediaType == PhotoMediaType.video ? 'Video selected' : 'Photo selected', style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: HAAColors.success)),
                          Text(PhotosLimits.formattedSize(fileData!.length), style: HAAFonts.sans(12)),
                          Text('Tap to change', style: HAAFonts.sans(11).copyWith(color: HAAColors.muted)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text('CAPTION', style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
            TextField(
              onChanged: (v) => caption = v,
              maxLines: 3,
              decoration: InputDecoration(hintText: "What's happening?", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(HAARadius.md))),
            ),
            const SizedBox(height: 16),
            Text('SHARED AS', style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(HAARadius.md), border: Border.all(color: HAAColors.border)),
              child: Text(widget.uploaderName, style: HAAFonts.sans(14, weight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            Text('CONVENTION DAY', style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
            Wrap(
              spacing: 8,
              children: ['July 2', 'July 3', 'July 4', 'July 5'].map((day) {
                final selected = selectedDay == day;
                return GestureDetector(
                  onTap: () => setState(() => selectedDay = day),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? HAAColors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(HAARadius.sm),
                    ),
                    child: Text(day, style: HAAFonts.sans(12, weight: FontWeight.w600).copyWith(color: selected ? Colors.white : HAAColors.muted)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('EVENT TAG', style: HAAFonts.sans(10, weight: FontWeight.bold).copyWith(color: HAAColors.muted, letterSpacing: 0.8)),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: PhotoEventTag.values.map((tag) {
                final selected = selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(() => selectedTag = tag),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? HAAColors.orangeLight : Colors.white,
                      borderRadius: BorderRadius.circular(HAARadius.md),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tag.icon, size: 16, color: selected ? HAAColors.orange : HAAColors.muted),
                        Text(tag.label, textAlign: TextAlign.center, style: HAAFonts.sans(9, weight: FontWeight.w600).copyWith(color: selected ? HAAColors.orange : HAAColors.muted), maxLines: 2),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (showSuccess)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFE1F5EE), borderRadius: BorderRadius.circular(HAARadius.md)),
                child: Text('Shared! Now visible in the gallery', style: HAAFonts.sans(14, weight: FontWeight.bold).copyWith(color: HAAColors.success)),
              )
            else
              HAAButton(
                label: isUploading ? 'Uploading…' : 'Share with Everyone',
                icon: Icons.upload,
                onPressed: _handleUpload,
                enabled: !isUploading && fileData != null,
              ),
            const SizedBox(height: 12),
            Text(
              'Max file size: ${PhotosLimits.maxUploadMB} MB. Shared with all logged-in attendees.',
              textAlign: TextAlign.center,
              style: HAAFonts.sans(11).copyWith(color: HAAColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoDetailSheet extends StatefulWidget {
  const _PhotoDetailSheet({required this.photo, required this.currentUserEmail, required this.onDelete});
  final ConventionPhoto photo;
  final String currentUserEmail;
  final ValueChanged<String> onDelete;

  @override
  State<_PhotoDetailSheet> createState() => _PhotoDetailSheetState();
}

class _PhotoDetailSheetState extends State<_PhotoDetailSheet> {
  bool isDeleting = false;
  String? deleteError;

  bool get canDelete {
    final owner = widget.photo.uploaderEmail.trim().toLowerCase();
    final current = widget.currentUserEmail.trim().toLowerCase();
    return owner.isNotEmpty && owner == current;
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete this ${widget.photo.isVideo ? 'video' : 'photo'}?'),
        content: const Text('This cannot be undone. It will be removed from the shared gallery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() { isDeleting = true; deleteError = null; });
    try {
      await PhotosAPI.delete(photoId: widget.photo.id, uploaderEmail: widget.currentUserEmail);
      widget.onDelete(widget.photo.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { isDeleting = false; deleteError = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Done', style: HAAFonts.sans(15, weight: FontWeight.w600).copyWith(color: HAAColors.orange))),
          ),
          if (photo.mediaURL != null && !photo.isVideo)
            SizedBox(
              height: 300,
              width: double.infinity,
              child: CachedNetworkImage(imageUrl: photo.mediaURL!, fit: BoxFit.contain),
            )
          else
            SizedBox(height: 300, child: Center(child: Icon(Icons.photo, size: 80, color: photo.accentColor.withValues(alpha: 0.6)))),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(HAASpacing.lg),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: HAAColors.orangeLight.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(HAARadius.md)),
                  child: Text('${photo.uploadedBy} added this ${photo.isVideo ? 'video' : 'image'}', style: HAAFonts.sans(13, weight: FontWeight.w600)),
                ),
                const SizedBox(height: 14),
                Text(photo.caption, style: HAAFonts.serif(20, weight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: HAAColors.orangeLight, borderRadius: BorderRadius.circular(HAARadius.pill)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(photo.eventTag.icon, size: 10, color: HAAColors.orange),
                          const SizedBox(width: 4),
                          Text(photo.eventTag.label, style: HAAFonts.sans(11, weight: FontWeight.w600).copyWith(color: HAAColors.orange)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: HAAColors.muted),
                        const SizedBox(width: 4),
                        Text(photo.day, style: HAAFonts.sans(12).copyWith(color: HAAColors.muted)),
                      ],
                    ),
                  ],
                ),
                if (deleteError != null) ...[
                  const SizedBox(height: 12),
                  Text(deleteError!, style: HAAFonts.sans(13).copyWith(color: Colors.red)),
                ],
                if (canDelete) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isDeleting ? null : _delete,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(HAARadius.md)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDeleting) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                          else const Icon(Icons.delete, size: 14, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(isDeleting ? 'Deleting…' : 'Delete ${photo.isVideo ? 'Video' : 'Photo'}', style: HAAFonts.sans(14, weight: FontWeight.w600).copyWith(color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
