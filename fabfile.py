"""
Fabfile for auth.openhealthcare.org.uk
"""
from fabric.api import *
from fabric.colors import red, green

web = ['ohc@auth.openhealthcare.org.uk']
PROJ_DIR = '/usr/local/ohc/ohc-auth/accounts'

def in_rvm(what):
    """
    Run a command in a RVM

    """
    run("rvm use 1.9.2@auth; {0}".format(what))

def deps():
    """
    Install the latest dependencies
    """
    with cd(PROJ_DIR):
        in_rvm('bundle install')

def stop():
    """
    Stop the application in production
    """
    with cd(PROJ_DIR):
        in_rvm('padrino stop')

def start():
    """
    Start the application in production.
    """
    with cd(PROJ_DIR):
        in_rvm('padrino start -p 4566 -e production -d')


@hosts(web)
def deploy():
    """
    Make it so!
    """
    with cd(PROJ_DIR):
        run('git pull origin master') #not ssh - key stuff
        deps()
        stop()
        start()
