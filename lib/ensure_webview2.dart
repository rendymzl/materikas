// import 'dart:io';
// import 'package:process_run/shell.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

// Future<void> ensureWebView2Installed() async {
//   const webView2RegKey =
//       r'Software\Microsoft\EdgeUpdate\ClientState\{F95E7CB0-8B24-4E48-A6A3-41D1A3D8E8A5}';
//   const webView2Url =
//       'https://go.microsoft.com/fwlink/p/?LinkId=2124703'; // WebView2 Evergreen installer

//   // Check if WebView2 is installed
//   try {
//     final result = Process.runSync(
//       'reg',
//       ['query', webView2RegKey],
//       runInShell: true,
//     );
//     if (result.exitCode == 0) {
//       print("WebView2 runtime is already installed.");
//       return;
//     }
//   } catch (e) {
//     print("Error checking WebView2 installation: $e");
//   }

//   // If not installed, download and install WebView2 runtime
//   print("WebView2 runtime not found. Downloading...");
//   final tempDir = await getTemporaryDirectory();
//   final webView2InstallerPath = '${tempDir.path}/webview2setup.exe';

//   try {
//     final response = await http.get(Uri.parse(webView2Url));
//     final file = File(webView2InstallerPath);
//     await file.writeAsBytes(response.bodyBytes);

//     print("Installing WebView2 runtime...");
//     final shell = Shell();
//     await shell.run('$webView2InstallerPath /silent /install');
//     print("WebView2 runtime installed successfully.");
//   } catch (e) {
//     print("Failed to install WebView2 runtime: $e");
//   }
// }
