import 'dart:io';

Future<void> main() async {
  final root = Directory('build/web').absolute;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 53217);
  stdout.writeln(
    'Pixel Painter build is running at http://localhost:${server.port}',
  );

  await for (final request in server) {
    final uriPath = request.uri.path == '/' ? '/index.html' : request.uri.path;
    final requestedPath = uriPath
        .substring(1)
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .join(Platform.pathSeparator);
    final target = File('${root.path}${Platform.pathSeparator}$requestedPath');

    if (requestedPath.contains('..') ||
        !target.absolute.path.startsWith(root.path)) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      continue;
    }

    final file = await target.exists()
        ? target
        : File.fromUri(root.uri.resolve('index.html'));
    request.response.headers
      ..contentType = _contentType(file.path)
      ..set(HttpHeaders.cacheControlHeader, 'no-store');
    await request.response.addStream(file.openRead());
    await request.response.close();
  }
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) {
    return ContentType.html;
  }
  if (path.endsWith('.js')) {
    return ContentType('text', 'javascript', charset: 'utf-8');
  }
  if (path.endsWith('.css')) {
    return ContentType('text', 'css', charset: 'utf-8');
  }
  if (path.endsWith('.json')) {
    return ContentType.json;
  }
  if (path.endsWith('.png')) {
    return ContentType('image', 'png');
  }
  if (path.endsWith('.svg')) {
    return ContentType('image', 'svg+xml');
  }
  if (path.endsWith('.wasm')) {
    return ContentType('application', 'wasm');
  }
  return ContentType.binary;
}
