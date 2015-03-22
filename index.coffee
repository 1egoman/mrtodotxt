app = (require "express")()
bodyParser = require "body-parser"
app.use(bodyParser.text());

# resources
listItems = require './controllers/list-items'
listItems.populateCache();
app.get("/items", listItems.index)
# app.get("/items/new", listItems.new)
# app.get("/items/:item/edit", listItems.edit)
app.get("/items/([\w\/\@\+]*)", listItems.show)
app.post("/items", listItems.create)
app.put("/items/:item", listItems.update)
app.delete("/items/:item", listItems.destroy)

# listen for server response
app.listen(process.env.PORT || 8005)
