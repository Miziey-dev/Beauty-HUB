import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/auth_data_source.dart';
import '../../data/photo_upload_service.dart';
import '../../data/review_repository.dart';

/// Screen 7 -- Review flow (docs/consumer-flow.md): "photo upload strongly
/// encouraged -- these feed the style feed with real local content."
class LeaveReviewScreen extends StatefulWidget {
  const LeaveReviewScreen({super.key, required this.bookingId, required this.salonId});

  final String bookingId;
  final String salonId;

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int _rating = 5;
  final _bodyController = TextEditingController();
  final List<XFile> _photos = [];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(limit: 4);
    setState(() => _photos.addAll(picked));
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final uploader = context.read<PhotoUploadService>();
      final photoUrls = <String>[];
      for (final photo in _photos) {
        photoUrls.add(await uploader.uploadReviewPhoto(photo.path));
      }
      if (!mounted) return;

      final customerId = context.read<AuthDataSource>().currentUserId!;
      await context.read<ReviewRepository>().submitReview(
            bookingId: widget.bookingId,
            salonId: widget.salonId,
            customerId: customerId,
            rating: _rating,
            body: _bodyController.text.trim().isEmpty ? null : _bodyController.text.trim(),
            photoUrls: photoUrls,
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Could not submit review: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('How was your appointment?', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  iconSize: 36,
                  icon: Icon(star <= _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() => _rating = star),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Tell us about it (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickPhotos,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_photos.isEmpty ? 'Show off the result' : '${_photos.length} photo(s) added'),
          ),
          if (_photos.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(File(_photos[index].path), width: 72, height: 72, fit: BoxFit.cover),
                ),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit review'),
          ),
        ],
      ),
    );
  }
}
