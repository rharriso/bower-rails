bower-rails
===========

rake tasks for bower on rails. Dependency file is bower.json in Rails root dir.

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


**Available commands**

``` bash
  rake bower:install #install js components
  rake bower:install:force #install with force option
  rake bower:update #update js components
  rake bower:update:prune #update components and uninstall extraneous packages
```


##Ruby DSL configuration

The Ruby DSL configuration is a Jsfile with DSL syntax similar to Bundler. 

**Example Jsfile**

By default assets are put to `./vendor/assets/bower_components` directory:

``` ruby

# Puts to ./vendor/assets/bower_components
js "backbone"
js "moment"
```

But the default value can be overridden by `assets_path` method:

``` ruby
assets_path "assets/my_javascripts"

# Puts to ./vendor/assets/my_javascripts/bower_components
js "backbone"
js "moment"
```

And finally, the `assets_path` method can be overridden by an option in a `group` call:

``` ruby
assets_path "assets/javascript"

# Puts files under ./vendor/assets/js/bower_components
group :vendor, :assets_path => "assets/js"  do
  js "jquery"            # Assummes it's latests
  js "backbone", "1.2"
end

# Puts files under ./lib/assets/javascript/bower_components
group :lib do
  js "jquery"
  js "backbone", "1.2"
end
```
NOTE: All the assets should be stored in `/assets` subdirectory so putting it under `./vendor/js` directory is unavailable

**Available commands with a Jsfile**

``` bash
  rake bower:dsl:install #install js components
  rake bower:dsl:install:force #install with force option
  rake bower:dsl:update #update js components
  rake bower:dsl:update:prune #update components and uninstall extraneous packages
```





