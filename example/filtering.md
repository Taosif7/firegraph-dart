# Filtering, Ordering & Paginating queries

## Filtering queries

---
Document queries can be filtered using `where` query of firebase. We have support for every `where` query of firebase as graphql `where` arguments.

For example, if you want to query all users with age>30 you have to use `_gt` key suffix in where filter. Example dart code would be:

```dart
Map users = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    users(where:{
        age_gt: 30
    }){
        id
        name
        age
    }
}
''');
```

so for any `key`, its suffix determines the operator. all the supported filters with suffixes are listed below.

| Where filter | Suffix | Accepted values
| :--- | :--- | ---: |
|.where(key, isEqualTo: value)| key_eq: value| any
|.where(key, isNotEqualTo: value)| key_neq: value| any
|.where(key, isGreaterThan: value)| key_gt: value| any
|.where(key, isGreaterThanOrEqualTo: value)| key_gte: value| any
|.where(key, isLessThan: value)| key_lt: value| any
|.where(key, isLessThanOrEqualTo: value)| key_lte: value| any
|.where(key, isNull: value)| key_null: value| boolean
|.where(key, arrayContains: value)| key_contains: value| any
|.where(key, arrayContainsAny: value)| key_containsAny: value| List
|.where(key, whereIn: value)| key_in: value| List
|.where(key, whereNotIn: value)| key_notIn: value| List

These filters can be applied to any collection or subcollection query, whether nested any deep! and in any amount.

You can construct a crazy query like this, and its still legit!

```dart
Map users = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts(where:{
        likes_gt: 100,
        views_lt: 5000,
        category_in: ["photography", "music"]
    }){
        id
        body
        date
        comments(where:{
            date_gt: "2021-07-27T00:00:00.999Z",
            likes_gt: 10
        }){
            id
            message
        }
    }
    users(where:{
        age_lt:35,
        favourite_color_null:false,
        hobbies_containsAny:["singing","photography"],

    }){
        id
        name
        age
        hobbies
        favourite_color
    }
}
''');
```

### `NOTE`: For some queries you must have indexes already created in your firebase project

To create or view indexes in your firebase project, [follow this link](https://console.firebase.google.com/u/0/project/_/firestore/indexes)

## Ordering queries

---
Document queries can be ordered using `orderBy` query of firebase. You can supply an `orderBy` argument of object type, defining the fields you want to sort by and the order of those fields as `asc`ending or `desc`ending.

For example, if you want to query the users in ascending order of their age, your query would look like:

```dart
Map users = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    users(orderBy:{
        age: "asc"
    }){
        id
        name
        age
    }
}
''');
```

Now, if you want to query users by age in ascending and then by their name in ascending, query would look like:

```dart
Map users = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    users(orderBy:{
        age: "asc",
        name: "asc"
    }){
        id
        name
        age
    }
}
''');
```

### Note that this will order by age first, and then by name

## Limit queries

---
To limit the number of queried documents in a collection or subcollection, supply `limit` argument.

For example, to query only 10 users, your query would look like:

```dart
Map users = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    users(limit: 10){
        id
        name
        age
    }
}
''');
```
