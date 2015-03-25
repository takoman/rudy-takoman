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
[fabric](http://www.fabfile.org/) for streamlining the deployment process
from local to remote environments (e.g. staging and production.)
After setting up [SSH config files](http://docs.fabfile.org/en/1.10/usage/execution.html#leveraging-native-ssh-config-files)
on both your local and server, you should be able to deploy Rudy to
different environments via:

```
fab staging deploy
fab production deploy
```

Note that we use ssh config in the fabric deployment. If it prmopts you to enter
password, make sure your local public key was in `authorized_keys` on the
server, and you have set up your `~/.ssh/config` correctly.

See the [fabfile](https://github.com/takoman/rudy/blob/master/fabfile.py) for more details.

### Deployment Overview

We use ["The Twelve-Factor App"](http://12factor.net/) as a reference all
configuration will live in environment variables. Make sure you have modified
the .env file accordingly on the server before deployment. On the server,

```
cp .env.example .env
# Modify the environment variables as needed
```

What will happen on the remote server after you run `fab <env> deploy`?

1. Pull the latest master from GitHub repo
2. Run `npm install` to install packages
3. Compile assets and use [bucket-assets](https://github.com/artsy/bucket-assets) (with necessary S3 credentials in the env vars on the server) to upload them to our S3 bucket
4. Restart the app

To make sure the app is running **forever** and to monitor it, we use [forever]
(https://github.com/foreverjs/forever) to manage our Rudy processes. [PM2]
(https://github.com/Unitech/pm2) was a good candidate for us, but looks like
it has some [minor issues](https://github.com/takoman/rudy/issues/84).

**Remember that the .env file on staging and production should never be
added to version control. Until we have better way to manage them (like Heroku's
dashboard to manage env vars), let's just keep them on the server.**
