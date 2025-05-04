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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerWidget.circular(
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
              ),
              SizedBox(width: screenWidth * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangular(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.015,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  ShimmerWidget.rectangular(
                    width: screenWidth * 0.2,
                    height: screenHeight * 0.01,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          ShimmerWidget.rectangular(
            width: double.infinity,
            height: screenHeight * 0.02,
          ),
          SizedBox(height: screenHeight * 0.01),
          ShimmerWidget.rectangular(
            width: screenWidth * 0.7,
            height: screenHeight * 0.02,
          ),
          SizedBox(height: screenHeight * 0.02),
          ShimmerWidget.rectangular(
            width: double.infinity,
            height: screenHeight * 0.2,
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => ShimmerWidget.rectangular(
                width: screenWidth * 0.18,
                height: screenHeight * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCommentCard extends StatelessWidget {
  const ShimmerCommentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.04,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subreddit
          ShimmerWidget.rectangular(
            width: screenWidth * 0.25,
            height: screenHeight * 0.015,
          ),
          SizedBox(height: screenWidth * 0.02),

          // Post title
          ShimmerWidget.rectangular(
            width: double.infinity,
            height: screenHeight * 0.02,
          ),
          SizedBox(height: screenWidth * 0.01),
          ShimmerWidget.rectangular(
            width: screenWidth * 0.7,
            height: screenHeight * 0.02,
          ),

          // Divider
          SizedBox(height: screenWidth * 0.02),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[800],
          ),
          SizedBox(height: screenWidth * 0.02),

          // Comment text lines
          ShimmerWidget.rectangular(
            width: double.infinity,
            height: screenHeight * 0.015,
          ),
          SizedBox(height: screenWidth * 0.01),
          ShimmerWidget.rectangular(
            width: double.infinity,
            height: screenHeight * 0.015,
          ),
          SizedBox(height: screenWidth * 0.01),
          ShimmerWidget.rectangular(
            width: screenWidth * 0.5,
            height: screenHeight * 0.015,
          ),

          // Footer
          SizedBox(height: screenWidth * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangular(
                width: screenWidth * 0.2,
                height: screenHeight * 0.012,
              ),
              ShimmerWidget.rectangular(
                width: screenWidth * 0.15,
                height: screenHeight * 0.025,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
