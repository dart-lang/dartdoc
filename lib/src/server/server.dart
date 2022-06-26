// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

//import 'package:cli_util/cli_logging.dart';

/// Instances of the class [AbstractGetHandler] handle GET requests.
abstract class AbstractGetHandler {
  /// Handles a GET request received by the HTTP server.
  Future<void> handleGetRequest(HttpRequest request);
}

/// Instances of the class [HttpPreviewServer] implement a simple HTTP server
/// that serves up dartfix preview pages.
class HttpPreviewServer {
  /// Future that is completed with the HTTP server once it is running.
  Future<HttpServer>? _serverFuture;

  /// The internet address the server should bind to.  Should be suitable for
  /// passing to [HttpServer.bind], i.e. either a [String] or an
  /// [InternetAddress].
  final Object? bindAddress;

  /// Port number to run the preview server on.  If zero, then allow
  /// [HttpServer.bind] to pick one.
  final int preferredPort;

  //final Logger _logger;

  /// Initializes a newly created HTTP server.
  HttpPreviewServer(this.bindAddress, this.preferredPort)
      : assert(bindAddress is String || bindAddress is InternetAddress);

  //Future<String> get authToken async {
  //  await _serverFuture;
  //}

  /// Returns the port this server is bound to.
  Future<String?> get boundHostname async {
    return (await _serverFuture)?.address.host;
  }

  /// Returns the port this server is bound to.
  Future<int?> get boundPort async {
    return (await _serverFuture)?.port;
  }

  void close() {
    _serverFuture?.then((HttpServer server) {
      server.close();
    });
  }

  /// Begins serving HTTP requests over the given port.
  Future<int?> serveHttp() async {
    if (_serverFuture != null) {
      return boundPort;
    }

    try {
      _serverFuture = HttpServer.bind(bindAddress, preferredPort);
      var server = await _serverFuture!;
      _handleServer(server);
      return server.port;
    } catch (ignore) {
      // If we can't bind to the specified port, don't remember the broken
      // server.
      _serverFuture = null;
      // TODO(jcollins-g): Display a better error message?
      rethrow;
    }
  }

  /// Handles a GET request received by the HTTP server.
  Future<void> _handleGetRequest(HttpRequest request) async {
    //await previewSite.handleGetRequest(request);
    var uri = request.uri;
    var path = uri.path;
    try {
      /*if (path == highlightCssPath) {
        // Note: `return await` needed due to
        // https://github.com/dart-lang/sdk/issues/39204
        return await respond(request, HighlightCssPage(this));
      } else if (path == highlightJsPath) {
        // Note: `return await` needed due to
        // https://github.com/dart-lang/sdk/issues/39204
        return await respond(request, HighlightJSPage(this));
      } else if (path == robotoFontPath) {
        // Note: `return await` needed due to
        // https://github.com/dart-lang/sdk/issues/39204
        return await respond(request, RobotoPage(this));
      } else if (path == '/' ||
          decodedPath == migrationInfo!.includedRoot ||
          decodedPath ==
              '${migrationInfo!.includedRoot}${pathMapper!.separator}') {
        // Note: `return await` needed due to
        // https://github.com/dart-lang/sdk/issues/39204
        return await respond(request, IndexFilePage(this));
      }*/
      if (path == '/') {
        var response = request.response;
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.html;
        response.write('hello');
        response.close();
      } else {
        throw 'what is this? $path';
      }

      // Note: `return await` needed due to
      // https://github.com/dart-lang/sdk/issues/39204
      //return await respond(
      //    request, createUnknownPage(path), HttpStatus.notFound);
    } catch (exception, stackTrace) {
      //_respondInternalError(request, path, exception, stackTrace);
    }
  }

  /// Attaches a listener to a newly created HTTP server.
  void _handleServer(HttpServer httpServer) {
    httpServer.listen((HttpRequest request) async {
      var updateValues = request.headers[HttpHeaders.upgradeHeader];
      if (request.method == 'GET') {
        await _handleGetRequest(request);
      } else if (updateValues != null && updateValues.contains('websocket')) {
        // We do not support WebSocket connections.
        var response = request.response;
        response.statusCode = HttpStatus.notFound;
        response.headers.contentType = ContentType.text;
        response.write(
            'WebSocket connections not supported (${request.uri.path}).');
        //unawaited(response.close());
      } else {
        _returnUnknownRequest(request);
      }
    });
  }

  /// Returns an error in response to an unrecognized request received by the
  /// HTTP server.
  void _returnUnknownRequest(HttpRequest request) {
    var response = request.response;
    response.statusCode = HttpStatus.notFound;
    response.headers.contentType = ContentType.text;
    response.write('Not found');
    response.close();
  }
}

void main() {
  var server = HttpPreviewServer(_computeBindAddress('localhost'), 8080);
  server.serveHttp();
}

/// Computes the internet address that should be passed to `HttpServer.bind`
/// when starting the dartdoc server.  May be overridden in derived classes.
Object? _computeBindAddress(String hostname) {
  if (hostname == 'localhost') {
    return InternetAddress.loopbackIPv4;
  } else if (hostname == 'any') {
    return InternetAddress.anyIPv6;
  } else {
    return hostname;
  }
}
