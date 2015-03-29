fs = require "fs"
path = require "path"
_ = require "underscore"
todotxt = (require "jsTodoTxt").TodoTxt

class TodoList
  constructor: (@todoFile="./todo.txt") ->
    @getFileSync()

  # get todo.txt file contents from disk and save a
  # local cache white also reterning a copy
  getFile: (args...) ->
    args.name ?= path.normalize @todoFile
    callback = args.callback or args.cb or () ->

    fs.readFile args.name, "utf8", (err, data) ->
      callback err if err

      @todos = todotxt.parse(data)
      callback null, @todos

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

  create: (text) ->

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

    callback todotxt.render(matches)



module.exports = TodoFilter