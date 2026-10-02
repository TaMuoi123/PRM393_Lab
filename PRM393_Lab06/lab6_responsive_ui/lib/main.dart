import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiveMovieApp());
}

class Movie {
  final String title;
  final int year;
  final List<String> genres;
  final String posterUrl;
  final double rating;

  Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });
}

final List<Movie> allMovies = [
  Movie(
    title: 'Inception',
    year: 2010,
    genres: ['Action', 'Sci-Fi', 'Thriller'],
    posterUrl: 'https://via.placeholder.com/150/0000FF/808080?text=Inception',
    rating: 8.8,
  ),
  Movie(
    title: 'The Dark Knight',
    year: 2008,
    genres: ['Action', 'Crime', 'Drama'],
    posterUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=The+Dark+Knight',
    rating: 9.0,
  ),
  Movie(
    title: 'Interstellar',
    year: 2014,
    genres: ['Adventure', 'Drama', 'Sci-Fi'],
    posterUrl: 'https://via.placeholder.com/150/000000/FFFFFF?text=Interstellar',
    rating: 8.6,
  ),
  Movie(
    title: 'The Matrix',
    year: 1999,
    genres: ['Action', 'Sci-Fi'],
    posterUrl: 'https://via.placeholder.com/150/00FF00/000000?text=The+Matrix',
    rating: 8.7,
  ),
  Movie(
    title: 'Forrest Gump',
    year: 1994,
    genres: ['Drama', 'Romance'],
    posterUrl: 'https://via.placeholder.com/150/FFFF00/000000?text=Forrest+Gump',
    rating: 8.8,
  ),
  Movie(
    title: 'Gladiator',
    year: 2000,
    genres: ['Action', 'Adventure', 'Drama'],
    posterUrl: 'https://via.placeholder.com/150/800080/FFFFFF?text=Gladiator',
    rating: 8.5,
  ),
  Movie(
    title: 'The Shawshank Redemption',
    year: 1994,
    genres: ['Drama'],
    posterUrl: 'https://via.placeholder.com/150/008080/FFFFFF?text=Shawshank',
    rating: 9.3,
  ),
];

final List<String> allGenres = [
  'Action',
  'Adventure',
  'Comedy',
  'Crime',
  'Drama',
  'Romance',
  'Sci-Fi',
  'Thriller'
];

class ResponsiveMovieApp extends StatelessWidget {
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Genres',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GenreScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Set<String> selectedGenres = {};
  String selectedSort = 'A-Z';

  final List<String> sortOptions = ['A-Z', 'Z-A', 'Year', 'Rating'];

  List<Movie> get visibleMovies {
    List<Movie> filtered = allMovies.where((movie) {
      // Filter by search query
      final matchesSearch =
          movie.title.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Filter by genre
      final matchesGenre = selectedGenres.isEmpty ||
          movie.genres.any((genre) => selectedGenres.contains(genre));
      
      return matchesSearch && matchesGenre;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      if (selectedSort == 'A-Z') {
        return a.title.compareTo(b.title);
      } else if (selectedSort == 'Z-A') {
        return b.title.compareTo(a.title);
      } else if (selectedSort == 'Year') {
        return b.year.compareTo(a.year); // Newest first
      } else if (selectedSort == 'Rating') {
        return b.rating.compareTo(a.rating); // Highest first
      }
      return 0;
    });

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      searchQuery = '';
      selectedGenres.clear();
      selectedSort = 'A-Z';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = visibleMovies;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Movie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Filters',
            onPressed: _clearFilters,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search movies...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Genres and Sort Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Genres',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (selectedGenres.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${selectedGenres.length}',
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: allGenres.map((genre) {
                            final isSelected = selectedGenres.contains(genre);
                            return FilterChip(
                              label: Text(genre),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedGenres.add(genre);
                                  } else {
                                    selectedGenres.remove(genre);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sort by',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedSort,
                        items: sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedSort = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Movie List Area
              Expanded(
                child: movies.isEmpty
                    ? const Center(child: Text('No movies found.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 800) {
                            // Phone Layout
                            return ListView.builder(
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                return _buildMovieCard(movies[index], false);
                              },
                            );
                          } else {
                            // Tablet/Web Layout
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                return _buildMovieCard(movies[index], true);
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, bool isGrid) {
    return Card(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double posterWidth = constraints.maxWidth > 300 ? 100 : 80;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  movie.posterUrl,
                  width: posterWidth,
                  height: posterWidth * 1.5,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: posterWidth,
                      height: posterWidth * 1.5,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Year: ${movie.year}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: movie.genres.map((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.blue),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
