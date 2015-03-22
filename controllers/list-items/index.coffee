fs = require "fs"
_ = require "underscore"
todotxt = (require "jstodotxt").TodoTxt
todos = []

# GET     /items              ->  index
# GET     /items/new          ->  new
# POST    /items              ->  create
# GET     /items/:item       ->  show
# GET     /items/:item/edit  ->  edit
# PUT     /items/:item       ->  update
# DELETE  /items/:item       ->  destroy

# show all todos in the list
exports.index = (req, res) ->
  res.setHeader "content-type", "text/plain"
  res.send todotxt.render(todos)

exports.new = (req, res) ->
  res.send('new item')

# add new todo item to list
exports.create = (req, res) ->
  item = todotxt.parse req.body
  todos.push item
  exports.writeChangesToFile todos, (err) ->
    res.send {
      status: "OK",
      method: "create",
      msg: "Added new todo item: #{item}"
    }

# search by project or context
# multiple selectors can be seperated by /s, like
# `/items/@store/glue` -> `glue sticks @store`
exports.show = (req, res) ->
  matches = todos
  params = req.url.toLowerCase().split("/").slice(2)

  for selector in params
    matches = switch selector[0]

      # search by context
      when "@"
        matches.filter (i) ->
          selector.slice(1) in (i.contexts or [])

      # search by project
      when "+"
        matches.filter (i) ->
          selector.slice(1) in (i.projects or [])

      # search by phrase
      else
        matches.filter (i) ->
          _.intersection(
            selector.split(" "),
            (i.text.toLowerCase().split(' ') or [])
          ).length

  res.setHeader "content-type", "text/plain"
  res.send todotxt.render(matches)

exports.edit = (req, res) ->
  res.send('edit item ' + req.params.item)

exports.update = (req, res) ->
  res.send('update item ' + req.params.item)

exports.destroy = (req, res) ->
  res.send('destroy item ' + req.params.item)


# update todo.txt file from local cache
exports.writeChangesToFile = (todos, callback) ->
  filename = process.env.TODOTXTFILENAME or "todo.txt"
  fs.writeFile filename, todotxt.render(todos), (err) ->
    callback err

# import the todo.txt file to local cache
exports.populateCache = () ->
  filename = process.env.TODOTXTFILENAME or "todo.txt"
  fs.readFile filename, 'utf8', (err, data) ->
    console.error(err) if err
    todos = todotxt.parse(data)
    # console.log JSON.stringify(todos, null, 2)
