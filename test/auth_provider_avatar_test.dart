import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:femi_friendly/providers/auth_provider.dart';

void main() {
  test('avatar add and remove persists correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.loadFromPrefs();

    // initially no avatar
    expect(auth.avatarPath, isNull);

    // add avatar and await persistence
    await auth.updateProfile(avatarPath: '/tmp/avatar.png');
    expect(auth.avatarPath, '/tmp/avatar.png');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('profile_avatar'), '/tmp/avatar.png');

    // remove avatar by passing empty string and await persistence
    await auth.updateProfile(avatarPath: '');
    expect(auth.avatarPath, isNull);
    final prefs2 = await SharedPreferences.getInstance();
    expect(prefs2.getString('profile_avatar'), isNull);
  });
}
