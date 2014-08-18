# Setting up Server Environment

The following sections should walk you through all the steps from creating a DigitalOcean droplet to deploying Rudy.

- [Create a DigitalOcean droplet](#create-a-digitalocean-droplet)
- [Create a takoman user with sudo privilege](#create-a-takoman-user-with-sudo-privilege)
- [(Optional) Set up SSH login](#optional-set-up-ssh-login)
- [Set up git](#set-up-git)
- [Set up Nginx](#set-up-nginx)
- [Set up Environment and Rudy](#set-up-environment-and-rudy)
- [Deploy Rudy from Your Local](#deploy-rudy-from-your-local)

## Create a DigitalOcean droplet

See [Santa](https://github.com/takoman/santa/blob/master/doc/setting_up_server.md#create-a-digitalocean-droplet)

## Create a takoman user with sudo privilege

See [Santa](https://github.com/takoman/santa/blob/master/doc/setting_up_server.md#create-a-takoman-user-with-sudo-privilege)

## (Optional) Set up SSH login

See [Santa](https://github.com/takoman/santa/blob/master/doc/setting_up_server.md#optional-set-up-ssh-login)

## Set up git

See [Santa](https://github.com/takoman/santa/blob/master/doc/setting_up_server.md#set-up-git)

## Set up Nginx

See [Santa](https://github.com/takoman/santa/blob/master/doc/setting_up_server.md#set-up-nginx)
for setting up Nginx. But, instead, create a `takoman.co` (or `staging.takoman.co`
for staging, and modify corresponding values) site:

```
server {
    listen 80;

    server_name takoman.co;

    access_log  /var/log/nginx/takoman.co.access.log;
    error_log  /var/log/nginx/takoman.co.error.log;

    # Serve robots.txt directly from Nginx
    # Uncomment the following for staging to prevent search engines from
    # indexing the staging site.
    #location /robots.txt {
    #    return 200 "User-agent: *\nDisallow: /";
    #}

    location / {
        proxy_pass         http://127.0.0.1:6000/;
        proxy_redirect     off;

        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}
```

If you run into [server names hash bucket size issue](http://charles.lescampeurs.org/2008/11/14/fix-nginx-increase-server_names_hash_bucket_size)
when restarting Nginx, change the `server_names_hash_bucket_size` directives
at the `http` level to the next power of two. See the optimization section
of the [Nginx manual](http://nginx.org/en/docs/http/server_names.html).

## Set up Environment and Rudy

Log in the server, and install node

```bash
$ sudo apt-get install nodejs
$ sudo apt-get install npm
```

If you encounter a `node not found` error when running `npm install` later,
you will need to install `nodejs-legacy` additionally. See [stackoverflow]
(http://stackoverflow.com/questions/21168141/can-not-install-packages-using-node-package-manager-in-ubuntu)

```bash
sudo apt-get install nodejs-legacy
```

Clone Rudy
```bash
$ git clone git@github.com:takoman/rudy.git
```

Bootstrap Rudy
```bash
$ cd rudy
$ npm install
```

Run Rudy
```bash
$ make s
```

## Deploy Rudy from your local

Instead of logging into the server and deploying Rudy everytime, we use
[fabric](http://www.fabfile.org/) to deploy Rudy from our locals. It will pull
the latest master from GitHub repo, run `npm install`, and reload the app.
To make sure the app is running **forever** and to monitor it, we use [pm2]
(https://github.com/Unitech/pm2) for now. If it's not stable enough, we may
fall back and use [forever](https://github.com/nodejitsu/forever) by nodejitsu.

### Create config files for your environment (staging or production)

Before we run Rudy on the server, we have to provide configurations to be used
under different env (i.e. staging or production). Log in to the server and
create your config file using `config/config-env.coffee.example` as an example.

```bash
$ ssh takoman@takoman.co
$ cd path/to/rudy
$ cp config/config-env.coffee.example config/config-production.coffee  # or config/config-staging.coffee
# Then, modify the values as needed
```

**Remember that the config files for staging and production should never be
added to GitHub repo. Until we have better way to manage them (like Heroku's
dashboard to manage env vars), let's just keep them on the server.**

### Set up necessary environment variables

Before we have something similar to Heroku dashboard to manage various
environment variables, we need to set them up manually. Make sure the
following env vars are ready on the remote server prior to deploying Rudy:

- `S3_KEY`: To upload assets to CloudFront CDN
- `S3_SECRET`: To upload assets to CloudFront CDN

For example, edit the `~/.bash_profile` file on the remote server

```bash
S3_KEY=<your Amazon S3 key>
S3_SECRET=<your Amazon S3 secret >

export S3_KEY S3_SECRET
```

### Use Fabric to deploy Rudy locally

Install [fabric](http://www.fabfile.org/installing.html) on your local.

Then, you should be able to deploy Rudy to staging with

```bash
$ fab staging deploy
```

And deploy Rudy to production with

```bash
$ fab production deploy
```

Then, you should be able to see something like this:

```bash
$ fab staging deploy
[staging.takoman.co] Executing task 'deploy'
[staging.takoman.co] run: test -d /home/takoman/rudy
[staging.takoman.co] run: git pull
[staging.takoman.co] out: Already up-to-date.
[staging.takoman.co] out: 

[staging.takoman.co] run: npm install
[staging.takoman.co] out: npm WARN package.json backbone-super-sync@0.0.10 No repository field.
[staging.takoman.co] out: npm WARN package.json bootstrap-stylus@3.2.0 No repository field.
[staging.takoman.co] out: npm WARN package.json sqwish@0.2.2 No repository field.
[staging.takoman.co] out: 
[staging.takoman.co] run: env=staging make spm2
[staging.takoman.co] out: node_modules/.bin/pm2 ping
[staging.takoman.co] out: { msg: 'pong' }
[staging.takoman.co] out: RUNNING_RUDY=$(node_modules/.bin/pm2 list | grep rudy-staging -c); \
[staging.takoman.co] out:       case $RUNNING_RUDY in \
[staging.takoman.co] out:         0) echo "Starting rudy staging..."; RUDY_ENV=staging node_modules/.bin/pm2 start index.coffee --name rudy-staging ;; \
[staging.takoman.co] out:         1) echo "Reloading rudy staging..."; RUDY_ENV=staging node_modules/.bin/pm2 reload index.coffee --name rudy-staging ;; \
[staging.takoman.co] out:         *) echo "$RUNNING_RUDY instances of rudy-staging is running. Looks like something went wrong?" ;; \
[staging.takoman.co] out:       esac; \
[staging.takoman.co] out: 
[staging.takoman.co] out: Reloading rudy staging...
[staging.takoman.co] out: PM2 Reloading process by name index.coffee
[staging.takoman.co] out: PM2 Process rudy-staging succesfully reloaded
[staging.takoman.co] out: All processes reloaded
[staging.takoman.co] out: ┌──────────────┬────┬─────────┬───────┬────────┬───────────┬────────┬─────────────┬─────────────┐
[staging.takoman.co] out: │ App name     │ id │ mode    │ PID   │ status │ restarted │ uptime │      memory │    watching │
[staging.takoman.co] out: ├──────────────┼────┼─────────┼───────┼────────┼───────────┼────────┼─────────────┼─────────────┤
[staging.takoman.co] out: │ rudy-staging │ 0  │ cluster │ 28121 │ online │         1 │ 1s     │ 46.270 MB   │ unactivated │
[staging.takoman.co] out: └──────────────┴────┴─────────┴───────┴────────┴───────────┴────────┴─────────────┴─────────────┘
[staging.takoman.co] out:  Use `pm2 desc[ribe] <id>` to get more details
[staging.takoman.co] out: 


Done.
Disconnecting from takoman@staging.takoman.co... done.
```

Note that we use ssh config in the fabric deployment. If it prmopts you enter
password, make sure your local public key was in `authorized_keys` in the
server, and you set up your `~/.ssh/config` correctly.
