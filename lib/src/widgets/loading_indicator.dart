import 'package:flutter/material.dart';

class HealthcareLoadingIndicator extends StatelessWidget {
  final double size;

  const HealthcareLoadingIndicator({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(16),
        child: Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKQmokGI7c4BLh7aKPtw3n4ys1sYa-wiWT939GZM0MNIiahOyxUkJvFPB1O2sdfDY5SM0&usqp=CAU',
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Theme.of(context).primaryColor,
            );
          },
        ),
      ),
    );
  }
}
