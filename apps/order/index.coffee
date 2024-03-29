express = require "express"
routes = require "./routes"

app = module.exports = express()
app.set "views", __dirname + "/templates"
app.set "view engine", "jade"
app.get "/orders/create", routes.orderCreation
app.get "/orders/:id", routes.index
