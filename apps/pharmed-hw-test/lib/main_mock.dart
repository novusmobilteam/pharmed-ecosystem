import 'core/env.dart';
import 'main.dart' as app;

Future<void> main() async {
  AppEnv.init(flavor: 'mock', baseUrl: 'https://agena.novusyazilim.com/api');
  await app.run();
}
