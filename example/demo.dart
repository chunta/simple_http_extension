import 'package:simple_http_extension/simple_http_extension.dart';

void main() async {
  var httpEx = HttpEx();

  // Example usage of performing an HTTP GET request
  var url = 'https://jsonplaceholder.typicode.com/posts/1';
  try {
    var response = await httpEx.get(url);
    print('Response: $response');
  } catch (e) {
    print('Error: $e');
  }

  // Example usage of performing an HTTP GET request without caching
  var anotherUrl = 'https://jsonplaceholder.typicode.com/posts/2';
  try {
    var response = await httpEx.forceGet(anotherUrl);
    print('Response: $response');
  } catch (e) {
    print('Error: $e');
  }
}
