express = require 'express'
routes = require './routes'
{ loginPath, signupPath, facebookCallbackPath } = require('../../lib/middleware/takoman-passport').options

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'
app.get '/login', routes.index

# Use the same `loginPath` and `signupPath` as in takoman-passport. The
# passport will handle the actually login and errors, and if succeeded, the
# request will be passed here and go on (which is a redirection to the
# previous page here.)
app.post loginPath, routes.redirectBack
app.post signupPath, routes.redirectBack
app.get facebookCallbackPath, routes.redirectBack

app.get '/logout', routes.logout, routes.redirectBack
