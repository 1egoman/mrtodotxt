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
  params = req.url.toLowerCase().split("?")[0].split("/").slice(2)
  matches = exports.select(params)

  res.setHeader "content-type", "text/plain"
  res.send todotxt.render(matches)

exports.edit = (req, res) ->
  res.send('edit item ' + req.params.item)

# update to the body content using selectors
# to pick what to update
exports.update = (req, res) ->
  newItem = todotxt.parse req.body

  params = req.url.toLowerCase().split("?")[0].split("/").slice(2)
  matches = exports.select(params)

  # warn user
  if matches.length > 5 and not "?confirm" in req.url
    res.send {
      status: "ERR",
      method: "update",
      msg: "Hmm, this query would update #{matches.length} items - add ?confirm to allow this."
    }


  else if matches.length > 0
    for item in matches
      todos[todos.indexOf(item)] = newItem

    exports.writeChangesToFile todos, (err) ->
      res.send {
        status: "OK",
        method: "update",
        msg: "Updated new todo item to: #{newItem}"
      }

  else
    res.send {
      status: "ERR",
      method: "update",
      msg: "#{params.join('/')} doesn't match anything."
    }


exports.destroy = (req, res) ->
  res.send('destroy item ' + req.params.item)

# select a new item from an array of selectors passed
exports.select = (selectors) ->
  matches = todos

  for selector in selectors
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

  matches

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
