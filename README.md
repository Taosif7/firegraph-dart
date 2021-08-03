# Firegraph

Firegraph is a plugin that lets you query firestore with GraphQL.

## Getting Started

Its very simple to get started. Just Install and use!

## Installing

To get the package from pub, run following command in your project directory

```bash
flutter pub get firegraph 
```

You can also include the package directly into pubspec.yaml file as

```yaml
dependencies:
    firegraph: ^1.0.0
```

## Usage

To use firegraph, one must import the following into their file

```dart
import 'package:firegraph/firegraph.dart'
```

## Querying

### Querying Collections

A collection can be queried same as a graphQL type query. For example, to query the collection `posts` with `id` and `message` fields for each document, the instruction would be:

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts{
        id
        body
    }
}
''');
```

### Querying Subcollections

A subcollection can be treated as same as a type inside a parent type. For example, to query the subcollection `comments` inside document in the collection `posts` (the hierarchy is posts/doc/comments/doc) the instruction would be:

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts{
        id
        body
        comments{
            id
            message
        }
    }
}
''');
```

This way you can query subcollections as deep as possible.

### Querying Reference documents

A `DocumentReference` field holding a reference to a document or a string field holding plain `path` to a document can be queried as a child of original document.

For example, a document in posts collections holds author DocumentReference which is a document in users collection, this can be queried in the following manner:

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts{
        id
        body
        author{
            id
            name
            age
        }
    }
}
''');
```

For String fields that hold the path to the document, same can be done. Aditionally, a parent path to document can be provided with `path` parameter. Example:

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts{
        id
        body
        authorId(path:"users/"){
            id
            name
            age
        }
    }
}
''');
```

for more reference on queries collections, subcollections & Documents, checkout [examples](example/querying.md).

## Aliases

We support aliases with same query structure as GraphQL. example:

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    articles: posts{
        id
        articleBody: body
        writer: author{
            id
            name
            age
        }
    }
}
''');
```

## Filtering queries

Document queries can be filtered using `where` query of firebase. We have support for every `where` query of firebase as graphql `where` arguments.

For example, if you want to query all users with age>30 you have to use `_gt` (greater than) suffix in where filter. Example query would be:

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

These filters can be applied to any collection or subcollection query, whether nested any deep! and in any amount. For more references, checkout the [examples](example/filtering.md#filtering-queries).

`NOTE`: For some queries you must have indexes already created in your firebase project. To create or view indexes in your firebase project, [follow this link](https://console.firebase.google.com/u/0/project/_/firestore/indexes).

## Ordering queries

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

For more references, checkout the [examples](example/filtering.md#ordering-queries).

## Limit queries

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

## Caching

Firegraph implements a simple cache mechanism that stores all referenced documents queried via collections and sub-collections and provides cache benefit to explicitly referenced documents i.e. *documents those are queried by reference*.

`Note` that cache is distinct for each and every query.

## Contributing

Thank you for your interest! You are welcome (and encouraged) to submit Issues and Pull Requests. You are welcome to ping me on Twitter as well: [@taosif7](https://twitter.com/taosif7)
