# Firegraph

Firegraph is a plugin that lets you query firestore with GraphQL.
![GitHub release (latest by date)](https://img.shields.io/github/v/release/Taosif7/firegraph-dart)
![GitHub](https://img.shields.io/github/license/Taosif7/firegraph-dart?style=flat)
![GitHub last commit](https://img.shields.io/github/last-commit/Taosif7/firegraph-dart)

## Getting Started

Its very simple to get started. Just Install and use!

## Installing

To get the package from pub, run following command in your project directory

```bash
pub get firegraph 
```

You can also include the package directly into pubspec.yaml file as

```yaml
dependencies:
    firegraph: ^0.0.1
```

## Usage

To use firegraph, one must import the following into their file

```dart
import 'package:firegraph/firegraph.dart'
```

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

The result would be a map of following structure:

```json
{
    "posts":[
        {
            "id":"cd89J6Z59Q5c7GJ3K2S4",
            "body":"Hello Firegraph"
        },
        {
            "id":"Q2WMKp2bH3BJRkjvILvH",
            "body":"Hello World"
        }
    ]
}
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

The result would be a map of following structure:

```json
{
    "posts":[
        {
            "id":"cd89J6Z59Q5c7GJ3K2S4",
            "message":"A Post with comments",
            "comments":[
                {
                    "id":"d4qwwcp8o6i7mzxz",
                    "message":"Great!"
                },
                {
                    "id":"7ww4de6zxo6id4q",
                    "message":"Awesome!"
                }
            ]
        },
    ]
}
```

This way you can query subcollections as deep as possible.

## Contributing

Thank you for your interest! You are welcome (and encouraged) to submit Issues and Pull Requests. You are welcome to ping me on Twitter as well: [@taosif7](https://twitter.com/taosif7)
