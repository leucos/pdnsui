pdnsui [![Build Status](https://secure.travis-ci.org/leucos/pdnsui.png?branch=master)](http://travis-ci.org/leucos/pdnsui)
======

*A PowerDNS UI ThatDoesntSuck™ (well, hopefully)*

The ultimate goal is to produce a slick web interface to PowerDNS that
will let you do add/remove/update domains and records in your PowerDNs
database. While PowerDNS will try to enforce RFCs at the record level, it
*won't* ever prevent you from using invalid TLDs (like some PowerDNS web
interface out there sometimes do), since many people are using invalid
TLDs for internal naming schemes.

![pdnsui]
(https://github.com/leucos/pdnsui/raw/master/misc/screenshot.png)

_This software is *very* alpha. You definitively shouldn't use it on
production servers yet ! Don't come to me if your production DNS
database is trashed !_

Installing
----------

* Have a ride to the [GitHub: https://github.com/leucos/pdnsui/](GitHub page) and check the README.md

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

* Create the users database

The users database is different thatn the powerdns database.

```bash
rake db:migrate
```

You might want to seed the database with the first user (admin/1234) if 
runing for the first time :

```bash
rake db:seed
```

* Start the application 

```bash
bundle
MODE=DEV ramaze start -s thin
```
(you might need to `bundle exec` depending on your configuration)

* Point your browser to: [http://localhost:7000/] (http://localhost:7000/)
* Enjoy

_Note_ : you don't need to have powerdns on the machine to try this out.
However, advanced features (slave notifications, dns based specs) will
require a locally installed powerdns.

Using the search field
----------------------

The seach field is rather nice. You can combine filtering on domains, record name, record content and record type:

* `@<domain>` will restrict search to a single domain, e.g. `@github.com`
* `*<type>` will restrict search to a single type, e.g. `:mx`
* `:<id>` will retrieve a specific record ID
* `=<text>` will restrict search to records having 'test' in their `content` field
* `<text>` will search for 'text' in the record's name

For instance, typing `@github.com *mx =2 goog` will search for all MX records 
in the `github.com` domain, containing `goog` in their name, and having `2` in 
their content. As today, if you would handle github.com nameserver with 
PDNSui, it would return `ALT2.ASPMX.L.GOOGLE.com.` and `ASPMX2.GOOGLEMAIL.com.`
.

Specs (a.k.a. Tests)
--------------------

You can run specs (bacon flavor) just by issuing `rake`. Note that you
really should setup a specific database to run spec against (see ``when
:spec`` in config/database.rb). While not doing so should be safe for
your db, several specs will probably fail.

If you want code coverage, set the environment variable ``COVERAGE`` :

```bash
COVERAGE=ohyesplease rake
```

Coverage will be generated in the ``coverage`` folder, thanks to
[SimpleCov](https://github.com/colszowka/simplecov).

If you don't want bacon to spit out backtrace, just set a ``BACON_MUTE``
environment variable :

```bash
BACON_MUTE=yup rake
```

Planned features
----------------

* Write the _Planned Features_ section in README
* Find a LICENCE

Contributing to pdnsui
----------------------

* Check out the latest master to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't
  requested it and/or contributed it
* Fork the project
* Use a specific branch for your changes (one bonus point if it's prefixed with 'feature/')
* _write tests_, doc, commit and push until you are happy with your contribution
* Send a pull request (against develop please)
* Please try not to mess with the Rakefile, version, or history

License
-------

This is released [WTFPLv2](http://sam.zoy.org/wtfpl/), and comes without
any warranty.

Credits
-------

- PDNSui is built with the awesome [Ramaze
  Framework](https://github.com/Ramaze/ramaze) and [Sequel
ORM](https://github.com/jeremyevans/sequel). Thanks to Sequel's author
Jeremy Evans and to all the nice folks in Freenode#ramaze for their
dedicated help. Bear with me guys ;)

- Layout & CSS: [http://twitter.github.com/bootstrap/]
(http://twitter.github.com/bootstrap/)

- Favicon from: [http://glyphicons.com/] (http://glyphicons.com/)

- Apple touch icon from: [http://findicons.com/search/leaf] (http://findicons.com/search/leaf)

