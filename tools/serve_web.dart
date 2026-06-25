import 'dart:io';

Future<void> main() async {
  final log = File('.dart_appdata/static_server.log');
  final root = Directory('build/web').absolute;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 53217);
  await log.writeAsString('listening on http://localhost:53217\n');

  await for (final request in server) {
    try {
      final path = Uri.decodeComponent(request.uri.path);
      final relativePath = path == '/' ? 'index.html' : path.substring(1);
      var file = File('${root.path}/$relativePath');
      if (!await file.exists()) {
        file = File('${root.path}/index.html');
      }

      final resolvedPath = file.absolute.path;
      if (!resolvedPath.startsWith(root.path)) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        continue;
      }

      request.response.headers
        ..set(HttpHeaders.cacheControlHeader, 'no-cache')
        ..contentType = _contentType(file.path);
      await request.response.addStream(file.openRead());
      await request.response.close();
    } catch (error, stackTrace) {
      await log.writeAsString('$error\n$stackTrace\n', mode: FileMode.append);
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }
}

ContentType _contentType(String path) {
  final extension = path.split('.').last.toLowerCase();
  return switch (extension) {
    'html' => ContentType.html,
    'js' => ContentType('application', 'javascript', charset: 'utf-8'),
    'css' => ContentType('text', 'css', charset: 'utf-8'),
    'json' => ContentType.json,
    'png' => ContentType('image', 'png'),
    'jpg' || 'jpeg' => ContentType('image', 'jpeg'),
    'svg' => ContentType('image', 'svg+xml'),
    'wasm' => ContentType('application', 'wasm'),
    'otf' => ContentType('font', 'otf'),
    'ttf' => ContentType('font', 'ttf'),
    _ => ContentType.binary,
  };
}
