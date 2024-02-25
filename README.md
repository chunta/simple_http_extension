## Features

A http helper class that detect remote protocol (max-age) and support local cache.

## Getting started

# simple_http_extension

A Dart package that extends HTTP functionality with caching and revalidation logic.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  simple_http_extension: ^1.0.0

import 'package:simple_http_extension/simple_http_extension.dart';

void main() {
  var httpEx = HttpEx();

  // Perform an HTTP GET request
  httpEx.get('https://example.com')
    .then((response) {
      print('Response: $response');
    })
    .catchError((error) {
      print('Error: $error');
    });
}