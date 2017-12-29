Virtualhost Manage Script
=========================

Bash Script to allow create or delete apache/nginx virtual hosts on Linux & OS X on a quick way.


## Installation

#### For Linux (Debian, Ubuntu, Mint)
```
curl -o virtualhost.sh https://gist.githubusercontent.com/flowlep/ed63bca4f74df0e2551e9e64ec8ccaca/raw/f0194dfcd2d61e1b7eb55edcf54524429dda6a38/virtualhost.sh 
sudo mv virtualhost.sh /usr/bin/virtualhost && sudo chmod +x /usr/bin/virtualhost
```

#### For OS X
```
curl -o virtualhost.sh https://gist.githubusercontent.com/flowlep/f25f7416f65c8d3180ddeb96aa622619/raw/25d8908d822a78be1dd5f970b13fd234c1b6a60d/virtualhost-osx.sh
sudo mv virtualhost.sh /usr/bin/virtualhost && sudo chmod +x /usr/bin/virtualhost
```


## Usage

Basic command line syntax:

``` bash
$ sudo virtualhost [create | delete] [domain] [host_dir]
```

It will : 
* Add your domain in `/etc/hosts` file
* Create the virtualhost configuration for Nginx
* Restart Nginx

#### Examples

to create a new virtual host:

    $ sudo virtualhost create mysite.dev /home/user/sites/mysite

to delete a virtual host

    $ sudo virtualhost delete mysite.dev
