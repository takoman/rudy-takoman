from __future__ import with_statement
from fabric.api import *

env.use_ssh_config = True  # use local ssh_config

def staging():
    env.hosts = ['staging.takoman.co']

def production():
    env.hosts = ['takoman.co']

def deploy():
    code_dir = '/home/takoman/rudy'
    with settings(warn_only=True):
        if run("test -d %s" % code_dir).failed:
            run("git clone git@github.com:takoman/rudy.git %s" % code_dir)
    with cd(code_dir):
        run("git pull")
        run("npm install")
        run("make cdn-assets")
        run("make sf")
