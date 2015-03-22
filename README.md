TODOTXTaaS
===

This app hosts a todo.txt file over the network and provides easy ways to
manipulate the data. Put any `todo.txt` file following the
[standard format](https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format)
in the root and run with `coffee index.coffee`. Many queries return with
`content-type: text/plain` in todo.txt format, but some return data in json.

### GET /items
Outputs the full todo.txt file.
```
GET /items
(A) Thank Mom for the meatballs @phone
(B) Schedule Goodwill pickup +GarageSale @phone
Post signs around the neighborhood +GarageSale
@GroceryStore Eskimo pies
```

### GET /items/:selector
Outputs all items that match the selector(s). These can take the form of:
  - `@context` - search for all items with a context of `@context`
  - `+project` - search for all items with a project of `+project`
  - `text` - search in the item body for `text` (not case sensitive)

```
GET /items/@phone
(A) Thank Mom for the meatballs @phone
(B) Schedule Goodwill pickup +GarageSale @phone

GET /items/@phone/mom
(A) Thank Mom for the meatballs @phone
```

### POST /items
Adds a new item. The request body should contain the list item in todo.txt format.

```
POST /items
@GroceryStore milk

{
  "status": "OK",
  "method": "create",
  "msg": "Added new todo item: @GroceryStore milk"
}
```

### PUT /items/:selector
Updates all items that match the selector(s). These can take the form of:
  - `@context` - search for all items with a context of `@context`
  - `+project` - search for all items with a project of `+project`
  - `text` - search in the item body for `text` (not case sensitive)

The request body should contain the list item in todo.txt format to replace
anything items identified by the selectors.

```
GET /items/@phone/mom
(A) Thank Dad for the meatballs @phone

{
  "status": "OK",
  "method": "update",
  "msg": "Updated todo item: Thank Dad for the meatballs @phone"
}
```

### DELETE /items/:selector
  - destroy (Not implemented yet)
