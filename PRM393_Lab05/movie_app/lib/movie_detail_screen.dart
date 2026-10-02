import 'package:flutter/material.dart';
import 'movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner hình ảnh với title đè lên góc trái dưới
            Stack(
              children: [
                Hero(
                  tag: 'poster_${widget.movie.id}',
                  child: Image.network(
                    widget.movie.posterUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        Container(height: 250, color: Colors.grey.shade300),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thể loại (Chips có viền nhạt giống ảnh)
                  Wrap(
                    spacing: 8.0,
                    children: widget.movie.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Overview (chỉ là text thuần, không có tiêu đề "Overview")
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // Các nút chức năng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite,
                        color: isFavorite ? Colors.red : Colors.grey.shade700,
                        label: 'Favorite',
                        onTap: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.star,
                        color: Colors.grey.shade700,
                        label: 'Rate',
                        onTap: () {},
                      ),
                      _buildActionButton(
                        icon: Icons.share,
                        color: Colors.grey.shade700,
                        label: 'Share',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Danh sách trailer (Có vạch kẻ phân chia)
                  const Text(
                    'Trailers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.movie.trailers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.play_circle, color: Colors.grey.shade700, size: 30),
                        title: Text(
                          widget.movie.trailers[index],
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        onTap: () {},
                      );
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

  Widget _buildActionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
        ],
      ),
    );
  }
}
