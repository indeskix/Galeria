import 'package:flutter/material.dart';
import 'package:gallery_app/preview_image.dart';

class GalleryPage extends StatelessWidget {
  final List<Map<String, String>> items;
  final List<bool> favorites;
  final ValueChanged<int> onFavoriteChanged;

  GalleryPage({this.items, this.favorites, this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int i) {
          return Product(
            product_image: items[i]['pic'],
            isFavorite: favorites[i],
            onFavoriteButtonPressed: () => onFavoriteChanged(i),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Map<String, String>> items;
  final ValueChanged<int> onFavoriteChanged;

  FavoritesPage({this.items, this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int i) {
          return Product(
            product_image: items[i]['pic'],
            isFavorite: true,
            onFavoriteButtonPressed: () => onFavoriteChanged(i),
          );
        },
      ),
    );
  }
}

class Product extends StatelessWidget {
  final String product_image;
  final bool isFavorite;
  final VoidCallback onFavoriteButtonPressed;

  Product({this.product_image, this.isFavorite, this.onFavoriteButtonPressed});

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: product_image,
              child: Material(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PreviewImage(picDetails_view: product_image),
                    ));
                  },
                  child: Image.asset(
                    product_image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: onFavoriteButtonPressed,
            ),
          ),
        ],
      ),
    );
  }
}
