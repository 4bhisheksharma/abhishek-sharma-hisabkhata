import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const ChatLoadingIndicator({super.key, this.color, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      ),
    );
  }
}
