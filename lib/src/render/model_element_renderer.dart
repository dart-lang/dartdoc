// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model_element.dart';

abstract class ModelElementRenderer {
  String renderLinkedName(ModelElement modelElement);

  String renderExtendedDocLink(ModelElement modelElement);

  String renderYoutubeUrl(String youTubeId, String aspectRatio);

  String renderAnimation(
      String uniqueId, int width, int height, Uri movieUrl, String overlayId);
}

class ModelElementRendererHtml extends ModelElementRenderer {
  @override
  String renderLinkedName(ModelElement modelElement) {
    var cssClass = modelElement.isDeprecated ? ' class="deprecated"' : '';
    return '<a${cssClass} href="${modelElement.href}">${modelElement.name}</a>';
  }

  @override
  String renderExtendedDocLink(ModelElement modelElement) {
    return '<a href="${modelElement.href}">[...]</a>';
  }

  @override
  String renderYoutubeUrl(String youTubeId, String aspectRatio) {
    // Blank lines before and after, and no indenting at the beginning and end
    // is needed so that Markdown doesn't confuse this with code, so be
    // careful of whitespace here.
    return '''

<p style="position: relative;
          padding-top: $aspectRatio%;">
  <iframe src="https://www.youtube.com/embed/$youTubeId?rel=0"
          frameborder="0"
          allow="accelerometer;
                 autoplay;
                 encrypted-media;
                 gyroscope;
                 picture-in-picture"
          allowfullscreen
          style="position: absolute;
                 top: 0;
                 left: 0;
                 width: 100%;
                 height: 100%;">
  </iframe>
</p>

'''; // Must end at start of line, or following inline text will be indented.
  }

  @override
  String renderAnimation(
      String uniqueId, int width, int height, Uri movieUrl, String overlayId) {
    return '''

<div style="position: relative;">
  <div id="${overlayId}"
       onclick="var $uniqueId = document.getElementById('$uniqueId');
                if ($uniqueId.paused) {
                  $uniqueId.play();
                  this.style.display = 'none';
                } else {
                  $uniqueId.pause();
                  this.style.display = 'block';
                }"
       style="position:absolute;
              width:${width}px;
              height:${height}px;
              z-index:100000;
              background-position: center;
              background-repeat: no-repeat;
              background-image: url(static-assets/play_button.svg);">
  </div>
  <video id="$uniqueId"
         style="width:${width}px; height:${height}px;"
         onclick="var $overlayId = document.getElementById('$overlayId');
                  if (this.paused) {
                    this.play();
                    $overlayId.style.display = 'none';
                  } else {
                    this.pause();
                    $overlayId.style.display = 'block';
                  }" loop>
    <source src="$movieUrl" type="video/mp4"/>
  </video>
</div>

'''; // Must end at start of line, or following inline text will be indented.
  }
}

class ModelElementRendererMd extends ModelElementRendererHtml {
  @override
  String renderLinkedName(ModelElement modelElement) {
    if (modelElement.isDeprecated) {
      return '[~~${modelElement.name}~~](${modelElement.href})';
    }
    return '[${modelElement.name}](${modelElement.href})';
  }

  @override
  String renderExtendedDocLink(ModelElement modelElement) =>
      '[...](${modelElement.href})';
}
