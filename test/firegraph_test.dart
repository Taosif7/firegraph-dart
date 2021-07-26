import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firegraph/firegraph.dart';

Future<void> main() async {
  final instance = FakeFirebaseFirestore();
  createTestData(instance);

  test('It can fetch documents', () async {
    var result = await Firegraph.resolve(instance, r'''
    query{
      posts{
        id
        body
      }
      users{
        id
        name
      }
    }''');

    expect(result['posts'] != null, true);
    expect(result['posts'][0]['id'] != null, true);
    expect(result['users'] != null, true);
    expect(result['users'][0]['id'] != null, true);
  });

  test('It can fetch sub-collection documents', () async {
    var result = await Firegraph.resolve(instance, r'''
    query{
      posts{
        id
        body
        comments{
          id
        }
      }
    }''');

    expect(result['posts'] != null, true);
    expect(result['posts'][0]['comments'] != null, true);
    expect(result['posts'][0]['comments'][0]['id'] != null, true);
  });
}

Future<void> createTestData(FakeFirebaseFirestore instance) async {
  DocumentReference user =
      await instance.collection('users').add({'name': 'John doe', 'age': 36});
  DocumentReference doc = await instance
      .collection('posts')
      .add({'body': 'This is first post!', 'author': user});
  await doc.collection('comments').add({'message': 'Lovely!'});
  await doc.collection('comments').add({'message': 'Wow!'});
  await doc.collection('comments').add({'message': 'Ammmazzzing!'});
  await doc.collection('comments').add({'message': 'Welcome!'});
}
