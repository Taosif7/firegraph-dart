import 'dart:convert';

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

  group("Order & Limit:", () {
    test("ordering by single field", () async {
      Map result = await Firegraph.resolve(instance, r'''
      query{
        users(orderBy:{
          age:"Asc"
        }){
          id
          age
          name
        }
      }
      ''');

      if (result['users'].length < 2) return;
      for (var i = 1; i < result['users'].length; i++) {
        expect(
            result['users'][i]['age'] >= result['users'][i - 1]['age'], true);
      }
    });

    test("ordering by multiple fields", () async {
      Map result = await Firegraph.resolve(instance, r'''
      query{
        users(orderBy:{
          level:"asc",
          age:"desc",
        }){
          id
          age
          level
          name
        }
      }
      ''');

      List users = result['users'];
      if (users.length < 2) return;

      Map<int, List<Map>> levelledUsers = {};

      levelledUsers[0] = [users[0]];
      for (var i = 1; i < users.length; i++) {
        expect(users[i - 1]['level'] <= users[i]['level'], true);

        if (levelledUsers[i] == null) {
          levelledUsers[i] = [users[i]];
        } else
          levelledUsers[i].add(users[i]);
      }

      levelledUsers.entries.forEach((sameLevelUserEntries) {
        var sameLevelUsersList = sameLevelUserEntries.value;
        if (sameLevelUsersList.length < 2) return;
        for (var i = 1; i < sameLevelUsersList.length; i++) {
          expect(
              sameLevelUsersList[i - 1]['age'] >= sameLevelUsersList[i]['age'],
              true);
        }
      });
    });

    test("limiting collection & sub-collection", () async {
      Map result = await Firegraph.resolve(instance, r'''
      query{
        posts{
          id
          comments(limit:1){
            id
          }
        }
        users(limit:1){
          id
        }
      }
      ''');

      expect(result['users'].length, 1);
      for (var i = 0; i < result['posts'].length; i++) {
        expect(result['posts'][i]['comments'].length, 1);
      }
    });
  });

  group('Document Reference:', () {
    test('fetch document for documentReference fields', () async {
      Map result = await Firegraph.resolve(instance, r'''
      query{
        posts(limit:2){
          id
          body
          author{
            id
            name
            gender
          }
        }
      }
      ''');

      for (var i = 0; i < result['posts'].length; i++) {
        var post = result['posts'][i];
        expect(post['author'] != null, true);
        expect(post['author']['name'] != null, true);
      }
    });

    test('fetch document for raw string fields', () async {
      Map result = await Firegraph.resolve(instance, r'''
      query{
        posts(limit:2){
          id
          body
          comments(limit:2){
            id
            message
            user(path:"users/"){
              id
              name
              gender
            }
          }
        }
      }
      ''');

      for (var i = 0; i < result['posts'].length; i++) {
        var post = result['posts'][i];
        for (var j = 0; j < post['comments'].length; j++) {
          var comment = post['comments'][j];
          expect(comment['id'] != null, true);
          expect(comment['user'] != null, true);
          expect(comment['user']['name'] != null, true);
        }
      }
    });
  });
}

Future<void> createTestData(FakeFirebaseFirestore instance) async {
  // users collections
  DocumentReference user1 = await instance.collection('users').add({
    'name': 'Jane doe',
    'age': 32,
    'gender': 'female',
    'hobbies': ['singing', 'painting', 'writing'],
    'favourite_color': 'red',
    'level': 2,
  });
  DocumentReference user2 = await instance.collection('users').add({
    'name': 'Matthew',
    'age': 48,
    'gender': 'male',
    'hobbies': ['dancing', 'playing music', 'photography'],
    'favourite_color': 'blue',
    'level': 2,
  });
  DocumentReference user3 = await instance.collection('users').add({
    'name': 'Havana',
    'age': 16,
    'gender': 'female',
    'hobbies': ['singing', 'dancing', 'playing music'],
    'favourite_color': 'green',
    'level': 2,
  });
  DocumentReference user4 = await instance.collection('users').add({
    'name': 'John doe',
    'age': 36,
    'gender': 'male',
    'hobbies': ['singing', 'writing', 'photography'],
    'favourite_color': null,
    'level': 3,
  });

  // posts collection
  DocumentReference doc = await instance
      .collection('posts')
      .add({'body': 'This is first post!', 'author': user4});
  await doc
      .collection('comments')
      .add({'message': 'Lovely!', 'user': user1.id});
  await doc.collection('comments').add({'message': 'Wow!', 'user': user3.id});
  await doc
      .collection('comments')
      .add({'message': 'Ammmazzzing!', 'user': user3.id});
  await doc
      .collection('comments')
      .add({'message': 'Welcome!', 'user': user2.id});
}
