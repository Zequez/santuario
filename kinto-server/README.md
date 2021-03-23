# Kinto for Scalingo

`kinto-scalingo` is an example on how to use [Kinto](http://kinto-storage.org) and [Scalingo](https://scalingo.com) together.
Following the installation you should have a Kinto server available for you to use.

## Installation for Scalingo

To deploy Kinto on Scalingo, just click on this button:

[![Deploy to Scalingo](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy)

or using CLI:

```
$ git clone http://github.com/Kinto/kinto-scalingo.git --depth=1 my-kinto && cd my-kinto
$ scalingo create my-kinto
$ scalingo --app my-kinto addons-add scalingo-postgresql free
$ git push scalingo master
```

## How to upgrade / change configuration?

First of all use the [Scalingo command](http://cli.scalingo.com/) to login:

Clone this repository and link it to your Scalingo app (here named `my-kinto`):

```
$ git clone http://github.com/Kinto/kinto-scalingo.git --depth=1 my-kinto
$ cd my-kinto
```

If you did not create the app on the Scalingo dashboard yet:

```
$ scalingo create my-kinto
$ scalingo --app my-kinto addons-add scalingo-postgresql free
```

otherwise, if the app is already created:

```
$ git remote add scalingo git@scalingo.com:my-kinto.git
```

(*optional*) Edit your configuration:

```
$ <Edit kinto.ini with your new settings>
$ git commit -am "New setting"
```

> Note: You can also edit the `requirements.txt` to add new dependencies / plugins.

Deploy your modification:

```
$ git push scalingo master

 <-- Start deployment of my-kinto -->
-----> Installing python-3.5.2
     $ pip install -r requirements.txt
       Collecting kinto>=6.0.0 (from -r /build/7a05a928-1044-48aa-86bc-e85236101692/requirements.txt (line 1))
         Downloading kinto-6.0.0-cp2.cp3-none-any.whl (2.2MB)
       Collecting SQLAlchemy (from -r /build/7a05a928-1044-48aa-86bc-e85236101692/requirements.txt (line 2))
         Downloading SQLAlchemy-1.1.6.tar.gz (5.2MB)
       Collecting psycopg2 (from -r /build/7a05a928-1044-48aa-86bc-e85236101692/requirements.txt (line 3))
         Downloading psycopg2-2.7-cp35-cp35m-manylinux1_x86_64.whl (2.1MB)
       Collecting zope.sqlalchemy (from -r /build/7a05a928-1044-48aa-86bc-e85236101692/requirements.txt (line 4))
         Downloading zope.sqlalchemy-0.7.7.tar.gz

[...]

-----> Running post-compile hook
/app/.scalingo/python/lib/python3.5/site-packages/kinto/core/storage/postgresql/client.py:87: UserWarning: Reuse existing PostgreSQL connection. Parameters permission_* will be ignored.
  warnings.warn(msg)
INFO   Running kinto 6.0.0.
INFO   Created PostgreSQL cache tables
INFO   Create PostgreSQL storage schema at version 15 from /app/.scalingo/python/lib/python3.5/site-packages/kinto/core/storage/postgresql/schema.sql
INFO   Created PostgreSQL storage schema (version 15).
INFO   Created PostgreSQL permission tables
-----> Procfile declares types -> web
 Build complete, shipping your container...
 Waiting for your application to boot...
 <-- https://my-kinto.scalingo.io -->
```

Done!
