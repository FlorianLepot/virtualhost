Virtualhost Manage Script
===========

Bash Script to allow create or delete apache/nginx virtual hosts on Ubuntu on a quick way.

## Installation ##

1. Download virtualhost.sh
2. Move it
``` bash
$ mv virtualhost.sh /usr/bin/virtualhost
```
3. Apply permission to execute:
```
$ chmod +x /usr/bin/virtualhost
```

## Usage ##

Basic command line syntax:

    $ sudo virtualhost [create | delete] [domain] [host_dir]

### Examples ###

to create a new virtual host:

    $ sudo virtualhost create mysite.dev /home/user/sites/mysite

to delete a virtual host

    $ sudo virtualhost delete mysite.dev
