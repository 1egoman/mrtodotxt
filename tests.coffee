t = require "./todo"

todo = new t.TodoList
todo.select ["@phone"], (all) ->
  todo.update("x Eskimo pies @GroceryStore", "hi @phone")
  t.log todo
