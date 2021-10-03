/// Uses https://pub.dev/packages/firebase_auth_mocks to test
/// sign-in / register (?) UI

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:ema/main.dart';

void main() {

//   testWidgets('User can signin with valid credentials', (WidgetTester tester) async {
//
//     final user = MockUser(
//       isAnonymous: false,
//       uid: 'uid123',
//       email: 'test@gmail.com',
//       displayName: 'ThomasTester'
//     );
//
//     final auth = MockFirebaseAuth(mockUser: user);
//
//     // TODO: update for checking UI changes
//     final result = await auth.signInWithEmailAndPassword(email: 'test@gmail.com', password: "abc123");
//
//     final t = result.user;
//
//     // Verify 'Send Notification' button exists
//     expect(t?.displayName, 'ThomasTester');
//   });
//
//   testWidgets('User can\'t signin with invalid credentials', (WidgetTester tester) async {
//
//     final user = MockUser(
//         isAnonymous: false,
//         uid: 'uid123',
//         email: 'test@gmail.com',
//         displayName: 'ThomasTester'
//     );
//
//     final auth = MockFirebaseAuth(mockUser: user);
//
//     // TODO: update for checking UI changes
//     final result = await auth.signInWithEmailAndPassword(email: 'bad@gmail.com', password: "abc");
//
//     final t = result.user;
// print(result.user);
//     // Verify 'Send Notification' button exists
//     expect(t?.displayName, 'ThomasTester');
//   });

}