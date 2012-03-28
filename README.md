pdnsui
======

[![Build
Status](https://secure.travis-ci.org/leucos/pdnsui.png?branch=master)](http://travis-ci.org/earzue/pdnsui)

GitHub: https://github.com/leucos/pdnsui/

A PowerDNS UI ThatDoesntSuck™ (well, hopefully)

![pdnsui]
(raw/master/misc/screenshot.png)

_This softwre is *very* alpha. You definitively shouldn't use it on
production servers yet !_

Installing
----------

* Clone the repository

```bash
git clone https://leucos@github.com/leucos/pdnsui.git
cd pdnsui
git checkout develop
```

* If you're using rvm, it should create a gemset automatically

* If you're just testing around, create a powerdns MySQL database using
  the sql file given in `misc/powerdns.mysql` :

```bash
mysqladmin create powerdns-test -u root -p
mysql powerdns-test -p -u root < misc/powerdns.mysql
```

* Configure the database

```bash
cp config/database.rb.sample config/database.rb
vim config/database.rb
```

* Start the application 

```bash
bundle
MODE=DEV ramaze start -s thin
```
(you might need to `bundle exec` depending on your configuration)

* Point your browser to: [http://localhost:7000/] (http://localhost:7000/)
* Enjoy

_Note_ : you don't need to have powerdns on the machine to try things out.
However, advanced features (slave notifications, dns based specs) will
require a locally installed powerdns.

Contributing to pdnsui
----------------------
 
* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't
  requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Please try not to mess with the Rakefile, version, or history. If you
  want to have your own version, or is otherwise necessary, that is
fine, but please isolate to its own commit so I can cherry-pick around
it.

Credits
-------
- PDNSui is built with the awesome [Ramaze
  Framework](https://github.com/Ramaze/ramaze) an [Sequel
ORM](https://github.com/jeremyevans/sequel). Thanks to Sequel's author
Jeremy Evans and to all the nice folks in Freenode#ramaze for their
dedicated help. Bare with me guys ;)

- Layout & CSS: [http://twitter.github.com/bootstrap/]
(http://twitter.github.com/bootstrap/)

- Favicon from: [http://glyphicons.com/] (http://glyphicons.com/)

- Apple touch icon from: [http://findicons.com/search/leaf] (http://findicons.com/search/leaf)

