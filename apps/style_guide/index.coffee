#
# The express app for the "style_guide" app.
#

express = require "express"
routes = require "./routes"

app = module.exports = express()
app.set "views", __dirname + "/templates"
app.set "view engine", "jade"
app.get '/style-guide', routes.index
