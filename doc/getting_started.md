# Getting Started with Rudy

*Rudy* is the codename for the desktop web app at Takoman.

Before you can set up Rudy for development you will want to set up [Santa](https://github.com/takoman/santa) which will provide the Takoman API that Rudy consumes. This doc will assume you've set up common development tools after getting started with Santa.

## Ezel

Read up on [Ezel](http://ezeljs.com/) and familarize yourself with Rudy concepts by understanding the foundation it was built on.

## Set-Up

#### Install Node.js

It is recommended to use the [nvm](https://github.com/creationix/nvm) tool to manage node versions and install node.

First install NVM

```
curl https://raw.github.com/creationix/nvm/master/install.sh | sh
```

Then install the latest node

```
nvm install 0.12
```

Then tell nvm to use the latest version of node by default and to update your PATH

```
nvm alias default 0.12
```

#### Install Rudy

- Fork and clone the Github repo to your local
- Install Node modules
```
cd rudy
npm install
```
Although not necessary, it's recommended to install mocha and coffeescript globally for debugging.

```
npm install mocha -g
npm install coffee-script -g
```

#### Set up configurations via environment variables
We use ["The Twelve-Factor App"](http://12factor.net/) as a reference, and all
environment configuration will live in environment variables. We use
[foreman](https://github.com/ddollar/foreman) to manage processes in development
and store the environment variables in the .env file.

- Use the .env.example as an example and set up necessary configs in the .env file
```
cp .env.example .env
# Then modify the environment variables
```

#### Get Santa access tokens from your local Santa shell
- Run the following commands in you local Santa shell to generate access tokens for your local Rudy application.
```python
starsirius:~/Code/rudy $ make shell
source ./venv/bin/activate && foreman run python santa/manage.py shell

>>> from santa.models.domain import *
>>> app = ClientApp(name='Rudy').save()
>>> print "TAKOMAN_ID={0} TAKOMAN_SECRET={1}".format(app.client_id, app.client_secret)
TAKOMAN_ID=6e221e69c94bed4f6757 TAKOMAN_SECRET=595610aaa89ca277ef3bb6aad6f28ae9
>>>
```
- Replace the `TAKOMAN_ID` and `TAKOMAN_SECRET` value in the .env file with the ones generated above.

#### Run the Server

```
make s
```

Rudy should be running at [localhost:4000](http://localhost:4000). Note that
we use [foreman](https://github.com/ddollar/foreman) to manage processes in
development. Make sure you have foreman installed.

Client-side code and templates will automatically reload on page refresh, but server-side code will not automatically reload without restarting the server. If you would like to watch for file changes and restart the server nodemon is a very popular tool.

```
npm install coffeee-script -g
npm install nodemon -g
nodemon coffee app.coffee
```
