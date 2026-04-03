import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../app_provider.dart';
import '../../core.dart';
import '../../models.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.loadLiveTv();
    provider.loadVideoTypes();
    provider.loadVideos();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _playVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
        _isVideoPlaying = true;
      });
  }

  void _playLiveTv(LiveTvStation station) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(station.url))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
        _isVideoPlaying = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Videos & Live TV')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live TV Section
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.broadcast_on_personal,
                        color: Colors.cyan,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Live TV',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (provider.liveTvStations.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No live TV stations available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.liveTvStations.length,
                      itemBuilder: (context, index) {
                        final station = provider.liveTvStations[index];
                        return ListTile(
                          title: Text(
                            station.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              _isVideoPlaying &&
                                      _videoController?.dataSource ==
                                          station.url
                                  ? Icons.stop_circle
                                  : Icons.play_circle_filled,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            onPressed: () {
                              if (_isVideoPlaying &&
                                  _videoController?.dataSource == station.url) {
                                _videoController?.pause();
                                setState(() => _isVideoPlaying = false);
                              } else {
                                _playLiveTv(station);
                              }
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Video Player
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              GlassContainer(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            const SizedBox(height: 16),

            // Video Categories
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.video_library, color: Colors.cyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Videos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('All', 'all'),
                        ...provider.videoTypes.map(
                          (type) => _buildCategoryChip(
                            type.videoType,
                            type.id.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.filteredVideos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No videos available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: provider.filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = provider.filteredVideos[index];
                        return _buildVideoCard(video);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final provider = Provider.of<AppProvider>(context);
    final isSelected = provider.currentVideoFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          provider.filterVideos(value);
        },
        backgroundColor: Colors.white10,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video) {
    return GestureDetector(
      onTap: () => _playVideo(video.videoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[900],
                ),
                child: video.videoThumbUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          video.videoThumbUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.video_library,
                                  color: Colors.white54,
                                ),
                              ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.video_library, color: Colors.white54),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.reciterName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (video.videoType.isNotEmpty)
                    Text(
                      video.videoType,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
