express = require 'express'
routes = require './routes'

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'

app.post '/allpay/payment-form-html', routes.paymentFormHtml
app.post '/invoices/:id/allpay-payment-callback', routes.paymentCallback
#app.post '/invoices/:id/allpay-online-payment-redirected', routes.onlinePaymentRedirected
app.post '/invoices/:id/allpay-offline-payment-redirected', routes.offlinePaymentRedirected
