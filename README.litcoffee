mrtodotxt
===

This app loads a todo.txt file and provides easy ways to
manipulate the data. Uses any `todo.txt` file following the
[standard format](https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format).

## This is literate coffeescript! Give it a go with `coffee -l README.litcoffee`

### Create a todo list instance
    mrt = require "./" # or "mrtodotxt"
    todo = new mrt.TodoList {}, "./todo.txt"

### Add some new items

    todo.create "milk @grocerystore"
    todo.create "coffee @grocerystore"
    todo.create "code @computer +mrtodotxt"

### Selectors
Below, we find all todo items with the `@grocerystore` context.
Then, we log them out with the log helper. Selectors can take the form of:
- `@context` - search for all items with a context of `@context`
- `+project` - search for all items with a project of `+project`
- `text` - search in the item body for `text` (not case sensitive)

Oh, and `mrt.log` is a helper for prettyprinting todo.txt lists.

    todo.select ["@grocerystore"], (all) ->
      mrt.log all, "All with @grocerystore"

### Marking Items
Next, after selecting all the items that contain the word `code`
and the context `@computer`, we mark the items as completed. Then,
we log out our changes. (`todo.unmark` exists to unmark items as completed)

    todo.select ["code", "@computer"], (code) ->
      todo.mark code, (m) ->
        mrt.log m, "Marked code item"

    todo.select ["code", "@computer"], (code) ->
      todo.unmark code, (m) ->
        mrt.log m, "Marked code item"

### Updating
In this snippet, the item with text content of "milk" is updated to 2% milk, and logged out.
Also, this example demonstrates that methods can be used synchronously.

    todo.select ["milk"], (milk) ->
      items = todo.update milk, "2% milk @grocerystore"
      mrt.log items, "Updated Milk"

### Deleting
Lastly, we delete coffee from the list.

    todo.select ["coffee"], (coffee) ->
      todo.delete coffee, (items) ->
        mrt.log items, "Deleted Coffee"
