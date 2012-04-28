express = require("express")
routes = require("./routes")
app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.set 'view options', pretty: true
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

app.get "/", routes.index
app.post "/", routes.entry.create
app.get "/:original", routes.entry.show
app.post "/:original", routes.diff.create
app.get "/:original/:new", routes.diff.show

port = process.env.PORT or 3000
app.listen port, ->
  console.log "Listening on " + port