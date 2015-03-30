fs = require "fs"
path = require "path"
_ = require "underscore"
todotxt = (require "jsTodoTxt").TodoTxt
chalk = require "chalk"
watch = require "watch"

class TodoList
  constructor: (@options={}, @todoFile="./todo.txt") ->
    @getFileSync()

    # watch for local file updates and update the cache
    if @options.watch
      watch.watchTree path.dirname(@todoFile), (f, curr, prev) =>
        if prev and curr
          @getFile()

  # get todo.txt file contents from disk and save a
  # local cache white also reterning a copy
  getFile: (args...) ->
    args.name ?= path.normalize @todoFile
    callback = args.callback or args.cb or () ->

    fs.readFile args.name, "utf8", (err, data) ->
      callback err if err

      @todos = todotxt.parse(data)
      callback null, @todos if callback

  # get todo.txt file contents from disk and save a
  # local cache white also reterning a copy, all syncronously
  # really, this should only be in the constructor.
  getFileSync: (args...) ->
    args.name ?= path.normalize @todoFile
    callback = args.callback or args.cb or () ->

    data = (fs.readFileSync args.name).toString()
    @todos = todotxt.parse(data)
    callback data.length, @todos

  # with local cache contents, write todo.txt to disk
  putFile: (args...) ->
    args.name ?= @todoFile
    callback = args.callback or args.cb or () ->

    fs.writeFile args.name, @todos, (err) ->
      callback err or null

  # create a new list item in teh list
  create: (text) ->
    @todos.push todotxt.parse(text)[0]
    todotxt.render(@todos)

  # select todo list items that match the selectors
  select: (selectors=[], callback) ->
    matches = @todos

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

    if callback
      callback todotxt.render(matches)
    else
      todotxt.render(matches)

  # update the given items based upon
  update: (selection, update, callback) ->
    update = todotxt.render(update) if typeof update isnt "string"
    selection = @select([selection]) if typeof selection isnt "object"

    # update each selected item with the updated text
    updates = _.intersection @todos, selection
    todoList = todotxt.render(@todos).split '\n'
    for sel in selection.split '\n'
      todoList[todoList.indexOf sel] = update
    todoList = _.compact(todoList).join '\n'

    # decompile the new todo list
    @todos = todotxt.parse(todoList)

    callback(todoList) if callback
    todoList

  # delete the specified item
  delete: (selection, callback) ->
    if typeof selection is "object"
      selection = todotxt.render(selection)
    else
      selection = @select([selection])

    # update each selected item with the updated text
    updates = _.intersection @todos, selection
    todoList = todotxt.render(@todos).split '\n'
    for sel in selection.split '\n'
      delete todoList[todoList.indexOf sel]
    todoList = _.compact(todoList).join '\n'

    # decompile the new todo list
    @todos = todotxt.parse(todoList)

    callback(todoList) if callback
    todoList

  # "check off" an item after completion
  mark: (selection, callback) ->
    selection = @select([selection]) if typeof selection isnt "object"

    # update each selected item with the updated text
    updates = _.intersection @todos, selection
    todoList = todotxt.render(@todos).split '\n'
    for sel in selection.split '\n'
      todoList[todoList.indexOf sel] = "x "+todoList[todoList.indexOf sel]
    todoList = _.compact(todoList).join '\n'

    # decompile the new todo list
    @todos = todotxt.parse(todoList)

    callback(todoList) if callback
    todoList

  # un-"check off" an item after completion
  unmark: (selection, callback) ->
    selection = @select([selection]) if typeof selection isnt "object"

    # update each selected item with the updated text
    updates = _.intersection @todos, selection
    todoList = todotxt.render(@todos).split '\n'
    for sel in selection.split '\n'
      todoList[todoList.indexOf sel] = todoList[todoList.indexOf sel].replace(/^[xX]/gim, '').trim()
    todoList = _.compact(todoList).join '\n'

    # decompile the new todo list
    @todos = todotxt.parse(todoList)

    callback(todoList) if callback
    todoList


exports.TodoList = TodoList

# prettyprint a todo.txt formatted string
exports.log = (todoList, title=null) ->
  todoList = todotxt.render(todoList.todos) if typeof todoList isnt "string"

  if title
    rule = ('-' for q in title.split '').join ''
    console.log "#{title}\n#{rule}"
  todoList = todoList.replace /(\(.\))/gi, chalk.red("$1")
  todoList = todoList.replace /([+][\w]+)/gi, chalk.green("$1")
  todoList = todoList.replace /([@][\w]+)/gi, chalk.blue("$1")
  todoList = todoList.replace /([\d]{1,4}[-/][\d]{1,4}[-/][\d]{1,4})/gi, chalk.magenta("$1")
  todoList = todoList.replace /^[xX]/gim, chalk.yellow("x")
  console.log todoList, "\n"
