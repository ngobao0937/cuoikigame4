
import 'package:flutter/material.dart';
import 'DetailScreen.dart';
import 'FaceDetection.dart';

class _Photo {
  _Photo({
    required this.assetName,
    required this.title,
  });

  final String assetName;
  final String title;
}

class GridList extends StatelessWidget {
  const GridList({Key? key}) : super(key: key);

  List<_Photo> _photos(BuildContext context) {
    return [
      _Photo(assetName: 'assets/images/unnamed.png', title: 'Text Scanner'),
      _Photo(assetName: 'assets/images/barcode.jpg', title: 'Barcode Scanner'),
      _Photo(assetName: 'assets/images/label.png', title: 'Label Scanner'),
      _Photo(assetName: 'assets/images/istockphoto-1388734014-612x612.jpg', title: 'Face Detection'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Home"),
      ),
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            childAspectRatio: 0.8, // Adjust child aspect ratio
            children: _photos(context).map<Widget>((photo) {
              return _GridPhotoItem(
                photo: photo,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.center,
      child: Text(text),
    );
  }
}

class _GridPhotoItem extends StatelessWidget {
  const _GridPhotoItem({Key? key, required this.photo,}) : super(key: key);

  final _Photo photo;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        photo.assetName,
        fit: BoxFit.cover,
      ),
    );

    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(photo.title),
        ),
      ),
      child: InkResponse(
        child: image,
        onTap: () {
          if(photo.title != 'Face Detection'){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Detailscreen(), settings: RouteSettings(arguments: photo.title)));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FaceDetectorScreen()));
          }
        },
      ),
    );
  }
}