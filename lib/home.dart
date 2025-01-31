import 'package:flutter/material.dart';
import 'database_helper.dart';

class GalleryPage extends StatefulWidget {
  final int userId;
  final List<Map<String, dynamic>> images;
  final List<int> favorites;
  final Function(int) onFavoriteChanged;

  GalleryPage({this.userId, this.images, this.favorites, this.onFavoriteChanged});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Center(child: Text('Brak zdjęć w bazie'));
    }

    return GridView.builder(
      itemCount: widget.images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        childAspectRatio: 1, // Keeps images square
        mainAxisSpacing: 0, // No vertical spacing
        crossAxisSpacing: 0, // No horizontal spacing
      ),
      itemBuilder: (context, i) {
        return GridTile(
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => widget.onFavoriteChanged(widget.images[i]['id']),
                  child: Image.asset(
                    widget.images[i]['image_url'],
                    fit: BoxFit.cover, // Ensures images fully cover the grid cell
                  ),
                ),
              ),
              Positioned(
                top: 8, // Adjusts padding from the top
                right: 8, // Moves the heart icon to the right
                child: IconButton(
                  icon: Icon(
                    widget.favorites.contains(widget.images[i]['id'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.favorites.contains(widget.images[i]['id']) ? Colors.red : Colors.white,
                  ),
                  onPressed: () => widget.onFavoriteChanged(widget.images[i]['id']),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final int userId;
  final List<Map<String, dynamic>> images;
  final Function(int) onFavoriteChanged;

  FavoritesPage({this.userId, this.images, this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Center(child: Text('Brak ulubionych zdjęć'));
    }

    return GridView.builder(
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 0, // No vertical spacing
        crossAxisSpacing: 0, // No horizontal spacing
      ),
      itemBuilder: (context, i) {
        return GridTile(
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => onFavoriteChanged(images[i]['id']),
                  child: Image.asset(
                    images[i]['image_url'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
