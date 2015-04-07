# Rudy [![Build Status](https://api.shippable.com/projects/540e739e3479c5ea8f9e5460/badge?branchName=master)](https://app.shippable.com/projects/540e739e3479c5ea8f9e5460/builds/latest)

Rudy, nickname of [Rudolph the Red-Nosed Reindeer](http://en.wikipedia.org/wiki/Rudolph_the_Red-Nosed_Reindeer) (aka "Santa's 9th Reindeer"), is Takoman's desktop web app. Please see the [doc folder](doc/) for more details, a good place to start is [getting_started.md](doc/getting_started.md).

Meta
---

* __State:__ production
* __Production:__ [http://takoman.co/](http://takoman.co/) | [DigitalOcean](#)
* __Staging:__ [http://staging.takoman.co/](http://staging.takoman.co/) | [DigitalOcean](https://cloud.digitalocean.com/droplets/2236486)
* __Github:__ [https://github.com/takoman/rudy/](https://github.com/takoman/rudy/)
* __CI:__ [Shippable](https://app.shippable.com/projects/540e739e3479c5ea8f9e5460); merged PRs to takoman/rudy#master are automatically deployed to staging; production is manually deployed from shippable
* __Point People:__ [@starsirius](https://github.com/starsirius), [@beamjet](https://github.com/beamjet)

Set-Up
---

- Install [NVM](https://github.com/creationix/nvm)
- Install Node 0.12
```
nvm install 0.12
nvm alias default 0.12
```
- Fork Rudy to your Github account in the Github UI.
- Clone your repo locally (substitute your Github username).
```
git clone git@github.com:starsirius/rudy.git
```
- Install node modules
```
cd rudy
npm install
```
- Get Santa access tokens from your local Santa shell
```python
from santa.models.domain import *
app = ClientApp(name='Rudy').save()
print "TAKOMAN_ID={0} TAKOMAN_SECRET={1}".format(app.client_id, app.client_secret)
```
- Create a .env file using the example and paste in `TAKOMAN_ID`, `TAKOMAN_SECRET` and other sensitive configuration.
```
cp .env.example .env
# Then modify the environment variables
```
- Start Rudy pointing to the local [Santa](https://github.com/takoman/santa) API
```
make s
```
- Rudy should now be running at [http://localhost:4000/](http://localhost:4000/)

Additional docs
---

You can find additional documentation about Rudy (deployments et c) in this repository's /doc directory.


&copy; copyright 2014 by [starsirius](https://github.com/starsirius) and [beamjet](https://github.com/beamjet).
