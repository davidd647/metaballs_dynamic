#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

layout(location = 0) uniform float uAlphaThreshold; // Threshold for alpha value
layout(location = 1) uniform vec2 uSize;
layout(location = 2) uniform vec4 color1;
layout(location = 3) uniform vec4 color2;
layout(location = 4) uniform sampler2D uTexture;


out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 color = texture(uTexture, uv);

  vec3 gradientColor = mix(color1.rgb, color2.rgb, uv.y);

  fragColor = vec4(gradientColor, 1.0);
  
  if (color.a < uAlphaThreshold) {
    discard; 
  } else {  
    fragColor = vec4(gradientColor.r, gradientColor.g, gradientColor.b, 1.0);
  }
}
