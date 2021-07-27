# Basic Collection & Subcollection Querying

## Querying Collections

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

It is possible to query multiple root collections at the same time in a single query. For example we can query `users` collection along with `posts` collection.

```dart
Map posts = await Firegraph.resolve(FirebaseFirestore.instance, r'''
query{
    posts{
        id
        body
    }
    users{
        id
        name
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
    ],
    "users":[
        {
            "id":"d4qwwcp8o6i7mzxz",
            "name":"John Doe"
        },
        {
            "id":"sqz755xIP4K32O56",
            "name":"Jane Doe"
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

This way you can query subcollections as deep as possible
