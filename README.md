bower-rails
===========

rake tasks for bower on rails. Dependency file is bower.json in Rails root dir.

**Requirements**

* [node](http://nodejs.org) ([on github](https://github.com/joyent/node))
* [bower](https://github.com/bower/bower) (>= 0.10.0) installed with npm

**Install**

in Gemfile

``` Ruby
	gem "bower-rails", "~> 0.4.0"
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
  rake bower:update  #update js components
```


##Ruby DSL configuration

The Ruby DSL configuration is a Jsfile with DSL syntax similar to Bundler


**Example Jsfile**

``` ruby
assets_path "assets/javascript"

# Puts files under ./vendor/assets/js
group :vendor, :assets_path => "assets/js"  do
  js "jquery"            # Assummes it's latests
  js "backbone", "1.2"
end

# Puts files under ./lib/assets/javascript
group :lib do
  js "jquery"
  js "backbone", "1.2"
end
```

**Available commands with a Jsfile**

``` bash
  rake bower:dsl:install #install js components
  rake bower:dsl:update  #update js components
```





