import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class OpacityFilter extends StatefulWidget {
  const OpacityFilter({
    super.key,
    required this.opacityFilterValue,
    required this.child,
    required this.color1,
    required this.color2,
  });

  final double opacityFilterValue;
  final Widget child;
  final Color color1;
  final Color color2;

  @override
  State<OpacityFilter> createState() => _OpacityFilterState();
}

class _OpacityFilterState extends State<OpacityFilter> {
  @override
  Widget build(BuildContext context) {
    return ShaderBuilder((context, shader, child) {
      return AnimatedSampler(
        (image, size, canvas) {
          shader.setFloatUniforms((uniforms) {
            uniforms
              ..setFloat(widget.opacityFilterValue) // This is the alpha threshold. Adjust as needed.
              ..setSize(size)
              ..setColor(widget.color1)
              ..setColor(widget.color2);
            // ..setColor(Colors.white);
          });

          // Set the sampler
          shader.setImageSampler(0, image);

          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()..shader = shader,
          );
        },
        child: widget.child,
      );
    }, assetKey: 'assets/shaders/opacity_filter.frag');
    // });
  }
}
