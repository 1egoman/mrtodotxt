Todo = require "./todo"

todo = new Todo null
todo.select [], (all) ->
  console.log all
