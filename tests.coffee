t = require "./todo"

todo = new t.TodoList
todo.select ["@phone"], (all) ->
  t.log todo.update(all, "another item")
