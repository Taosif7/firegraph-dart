import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firegraph/firegraph.dart';

Future<void> main() async {
  final instance = FakeFirebaseFirestore();
  createTestData(instance);

  group('Document & Collections:', () {
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
  });

  group("Where:", () {
    test('It can filter by _eq', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          gender_eq:"female"
        }){
          id
          gender
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['gender'], "female");
      }
    });

    test('It can filter by _neq', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          gender_neq:"female"
        }){
          id
          gender
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['gender'], "male");
      }
    });

    test('It can filter by _gt', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          age_gt:20
        }){
          id
          age
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['age'] > 20, true);
      }
    });

    test('It can filter by _gte', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          age_gte:32
        }){
          id
          age
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['age'] >= 32, true);
      }
    });

    test('It can filter by _lt', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          age_lt:36
        }){
          id
          age
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['age'] < 36, true);
      }
    });

    test('It can filter by _lte', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          age_lte:36
        }){
          id
          age
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['age'] <= 36, true);
      }
    });

    test('It can filter by _null', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          favourite_color_null:true
        }){
          id
          favourite_color
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(result['users'][i]['favourite_color'], null);
      }
    });

    test('It can filter by _contains', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          hobbies_contains:"dancing"
        }){
          id
          hobbies
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(List.castFrom(result['users'][i]['hobbies']).contains('dancing'),
            true);
      }
    });

    test('It can filter by _containsAny', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          hobbies_containsAny:["dancing","writing"]
        }){
          id
          hobbies
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        List userHobbies = List.castFrom(result['users'][i]['hobbies']);
        expect(
            userHobbies.contains('dancing') || userHobbies.contains('writing'),
            true);
      }
    });

    test('It can filter by _in', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          favourite_color_in:["red","blue"]
        }){
          id
          favourite_color
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(
            result['users'][i]['favourite_color'] == 'red' ||
                result['users'][i]['favourite_color'] == 'blue',
            true);
      }
    });

    // FIXME: whereNotIn is not supported by fake_cloud_firestore library
    /* test('It can filter by _notIn', () async {
      var result = await Firegraph.resolve(instance, r'''
      query{
        users(where:{
          favourite_color_notIn:["red","blue"]
        }){
          id
          favourite_color
        }
      }
      ''');

      for (var i = 0; i < result['users'].length; i++) {
        expect(
            result['users'][i]['favourite_color'] != 'red' &&
                result['users'][i]['favourite_color'] != 'blue',
            true);
      }
    }); */
  });
}

Future<void> createTestData(FakeFirebaseFirestore instance) async {
  // users collections
  DocumentReference user1 = await instance.collection('users').add({
    'name': 'Jane doe',
    'age': 32,
    'gender': 'female',
    'hobbies': ['singing', 'painting', 'writing'],
    'favourite_color': 'red'
  });
  DocumentReference user2 = await instance.collection('users').add({
    'name': 'Matthew',
    'age': 48,
    'gender': 'male',
    'hobbies': ['dancing', 'playing music', 'photography'],
    'favourite_color': 'blue'
  });
  DocumentReference user3 = await instance.collection('users').add({
    'name': 'Havana',
    'age': 16,
    'gender': 'female',
    'hobbies': ['singing', 'dancing', 'playing music'],
    'favourite_color': 'green'
  });
  DocumentReference user4 = await instance.collection('users').add({
    'name': 'John doe',
    'age': 36,
    'gender': 'male',
    'hobbies': ['singing', 'writing', 'photography'],
    'favourite_color': null
  });

  // posts collection
  DocumentReference doc = await instance
      .collection('posts')
      .add({'body': 'This is first post!', 'author': user4});
  await doc.collection('comments').add({'message': 'Lovely!'});
  await doc.collection('comments').add({'message': 'Wow!'});
  await doc.collection('comments').add({'message': 'Ammmazzzing!'});
  await doc.collection('comments').add({'message': 'Welcome!'});
}
