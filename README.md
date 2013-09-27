bower-rails
===========

Bower support for Rails projects. Dependency file is bower.json in Rails root dir or Bowerfile if you use DSL.
Check out Changelog.md for the latest changes and releases.

**Requirements**

* [node](http://nodejs.org) ([on github](https://github.com/joyent/node))
* [bower](https://github.com/bower/bower) (>= 0.10.0) installed with npm

**Install**

in Gemfile

``` Ruby
	gem "bower-rails", "~> 0.4.4"
```

**Initialize**

To add an empty bower.json file to the project root.

``` Bash
	rails g bower_rails:initialize
```

##JSON configuration

The bower.json file is two seperate bower [component.js](https://github.com/twitter/bower#defining-a-package) files. Defining a package in lib and vendor will install those packages to the corresponding directories.

**example bower.json file**

``` javascript
{
   "lib": {
    "name": "bower-rails generated lib assets",
    "dependencies": {
      "threex"      : "git@github.com:rharriso/threex.git",
      "gsvpano.js"  : "https://github.com/rharriso/GSVPano.js/blob/master/src/GSVPano.js"
    }
  },
  "vendor": {
    "name": "bower-rails generated vendor assets",
    "dependencies": {
      "three.js"    : "https://raw.github.com/mrdoob/three.js/master/build/three.js"
    }
  }
}
```

##Ruby DSL configuration

The Ruby DSL configuration is a Bowerfile at the project's root with DSL syntax similar to Bundler. 

**Example Bowerfile**

By default assets are put to `./vendor/assets/bower_components` directory:

``` ruby

# Puts to ./vendor/assets/bower_components
asset "backbone"
asset "moment"
```

But the default value can be overridden by `assets_path` method:

``` ruby
assets_path "assets/my_javascripts"

# Puts to ./vendor/assets/my_javascripts/bower_components
asset "backbone"
asset "moment"
```

And finally, the `assets_path` method can be overridden by an option in a `group` call:

``` ruby
assets_path "assets/javascript"

# Puts files under ./vendor/assets/js/bower_components
group :vendor, :assets_path => "assets/js"  do
  asset "jquery"            # Assummes it's latests
  asset "backbone", "1.2"
end

# Puts files under ./lib/assets/javascript/bower_components
group :lib do
  asset "jquery"
  asset "backbone", "1.2"
end
```
NOTE: All the assets should be stored in `/assets` subdirectory so putting it under `./vendor/js` directory is unavailable

##Rake tasks

Once you are done with `bower.json` or `Bowerfile` you can run

* `rake bower:install` to install js components
* `rake bower:install:force` to install with force option
* `rake bower:update` to update js components
* `rake bower:update:prune` to update components and uninstall extraneous packages
* `rake bower:list` to list all packages
