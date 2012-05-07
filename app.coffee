express = require("express")
routes = require("./routes")
require('jade/lib/inline-tags').push('textarea'); # Fix whitespace issue in textareas
app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.set 'view options', pretty: true, layout: false
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express["static"](__dirname + "/public")
  app.use require("connect-assets")()
  app.use app.router
  app.use express.cookieParser()
  app.use express.session({ secret: "keyboard cat" })

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.get "/:original?", routes.entry.show
app.post "/", routes.entry.create

port = process.env.PORT or 3000
app.listen port, ->
  console.log "Listening on " + port
