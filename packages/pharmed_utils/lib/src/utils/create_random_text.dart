import 'dart:math';

int createRandomText(int length) {
  const chars = '0123456789';
  final random = Random();
  final buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return int.parse(buffer.toString());
}
