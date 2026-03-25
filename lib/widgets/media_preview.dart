import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:open_filex/open_filex.dart';

class MediaPreviewList extends StatelessWidget {
  final List<String> mediaPaths;

  const MediaPreviewList({super.key, required this.mediaPaths});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: mediaPaths.length,
      itemBuilder: (context, index) {
        final path = mediaPaths[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            width: 300,
            child: MediaPreviewItem(path: path),
          ),
        );
      },
    );
  }
}

class MediaPreviewItem extends StatelessWidget {
  final String path;

  const MediaPreviewItem({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final ext = path.toLowerCase().split('.').last;
    final isVideo = ['mp4', 'mov', 'mkv', 'webm', 'avi', 'flv', 'wmv', 'm4v', '3gp', 'mpg', 'mpeg', 'ts', 'vob', 'm2ts'].contains(ext);
    final isAudio = ['mp3', 'm4a', 'wav', 'aac', 'opus', 'aif', 'aiff', 'flac', 'alac', 'wma', 'ogg', 'amr', 'mid', 'midi'].contains(ext);
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'wbmp', 'heic', 'heif', 'tiff', 'tif'].contains(ext);

    return GestureDetector(
      onTap: () {
         if (isImage || (!isVideo && !isAudio)) {
           // Provide fallback to image viewer if completely unknown but picked via image picker
           Navigator.push(
             context,
             MaterialPageRoute(builder: (_) => FullScreenImageViewer(path: path)),
           );
         } else {
           OpenFilex.open(path);
         }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MediaThumbnail(path: path),
            if (isVideo || isAudio)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isVideo ? "Video" : "Audio",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String path;
  const FullScreenImageViewer({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
           minScale: 0.1,
           maxScale: 5.0,
           child: Image.file(
             File(path),
             errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white)),
           ),
        )
      )
    );
  }
}

class MediaThumbnail extends StatefulWidget {
  final String path;
  const MediaThumbnail({super.key, required this.path});

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  Uint8List? _thumbData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final ext = widget.path.toLowerCase().split('.').last;
    final isVideo = ['mp4', 'mov', 'mkv', 'webm', 'avi', 'flv', 'wmv', 'm4v', '3gp', 'mpg', 'mpeg', 'ts', 'vob', 'm2ts'].contains(ext);
    final isAudio = ['mp3', 'm4a', 'wav', 'aac', 'opus', 'aif', 'aiff', 'flac', 'alac', 'wma', 'ogg', 'amr', 'mid', 'midi'].contains(ext);

    try {
      if (isVideo) {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: widget.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 25,
        );
        if (mounted) setState(() => _thumbData = uint8list);
      } else if (isAudio) {
        final metadata = await MetadataRetriever.fromFile(File(widget.path));
        if (mounted && metadata.albumArt != null) {
          setState(() => _thumbData = metadata.albumArt);
        }
      }
    } catch (e) {
      debugPrint("Thumbnail load error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    final ext = widget.path.toLowerCase().split('.').last;
    final isVideo = ['mp4', 'mov', 'mkv', 'webm', 'avi', 'flv', 'wmv', 'm4v', '3gp', 'mpg', 'mpeg', 'ts', 'vob', 'm2ts'].contains(ext);
    final isAudio = ['mp3', 'm4a', 'wav', 'aac', 'opus', 'aif', 'aiff', 'flac', 'alac', 'wma', 'ogg', 'amr', 'mid', 'midi'].contains(ext);

    if (!isVideo && !isAudio) {
      return Image.file(
        File(widget.path), 
        fit: BoxFit.cover, 
        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.insert_drive_file, size: 40, color: Colors.white54))
      );
    }

    if (_thumbData != null) {
      return Image.memory(_thumbData!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    return Center(child: Icon(isVideo ? Icons.videocam : Icons.audiotrack, size: 40, color: Colors.white54));
  }
}
