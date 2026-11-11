import 'core/env.dart';
import 'main.dart' as app;

Future<void> main() async {
  AppEnv.init(flavor: 'dev', baseUrl: 'https://agena.novusyazilim.com/api');
  await app.run();
}
