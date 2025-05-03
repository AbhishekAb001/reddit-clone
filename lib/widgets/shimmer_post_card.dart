import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircular;

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
  }) : isCircular = true;

  const ShimmerWidget.rectangular({
    super.key,
    required this.width,
    required this.height,
  }) : isCircular = false;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerWidget.circular(
                width: 32.0,
                height: 32.0,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerWidget.rectangular(
                    width: 120.0,
                    height: 12.0,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  const ShimmerWidget.rectangular(
                    width: 80.0,
                    height: 8.0,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const ShimmerWidget.rectangular(
            width: double.infinity,
            height: 16.0,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          const ShimmerWidget.rectangular(
            width: 280.0,
            height: 16.0,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const ShimmerWidget.rectangular(
            width: double.infinity,
            height: 160.0,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => const ShimmerWidget.rectangular(
                width: 60.0,
                height: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
