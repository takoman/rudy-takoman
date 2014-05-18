# Getting Started with Rudy

*Rudy* is the codename for the desktop web app at Takoman.

Before you can set up Rudy for development you will want to set up [Santa](https://github.com/takoman/santa) which will provide the Takoman API that Rudy consumes. This doc will assume you've set up common development tools after getting started with Santa.

## Ezel

Read up on [Ezel](http://ezeljs.com/) and familarize yourself with Rudy concepts by understanding the foundation it was built on.

## Install Node.js

It is recommended to use the [nvm](https://github.com/creationix/nvm) tool to manage node versions and install node.

First install NVM

````
curl https://raw.github.com/creationix/nvm/master/install.sh | sh
````

Then install the latest node

````
nvm install 0.10
````

Then tell nvm to use the latest version of node by default and to update your PATH

````
nvm alias default 0.10
````

## Install Node Modules

````
npm install
````

Although not necessary, it's recommended to install mocha and coffeescript globally for debugging.

````
npm install mocha -g
npm install coffee-script -g
````

## Run the Server

Make sure Santa is running on localhost:5000, then run the server, and open Rudy at [localhost:4000](http://localhost:4000).

````
make s
````

Client-side code and templates will automatically reload on page refresh, but server-side code will not automatically reload without restarting the server. If you would like to watch for file changes and restart the server nodemon is a very popular tool.

````
npm install coffeee-script -g
npm install nodemon -g
nodemon coffee app.coffee
````
