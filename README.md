bower-rails
===========

rake tasks for bower on rails. Dependency file is bower.json in Rails root dir.

**Requirements**

* [node](http://nodejs.org) ([on github](https://github.com/joyent/node))
* [bower](https://github.com/twitter/bow) installed with npm

**Install**

in Gemfile

``` Ruby
	gem 'bower-rails'
```

**Initialize**

To add an empty component.json file to the project root.

``` Bash
	rails g bower_rails:initialize
```


**Configuration**

The component.json file is two seperate bower package files. Defining a package in lib and vendor will install those packages to the corresponding directories.

**example component.json file**

``` javascript
{
   "lib": {
    "dependencies": {
      "threex"      : "git@github.com:rharriso/threex.git",
      "gsvpano.js"  : "https://github.com/rharriso/GSVPano.js/blob/master/src/GSVPano.js"  
    }    
  },
  "vendor": {
    "dependencies": {
      "three.js"  : "https://raw.github.com/mrdoob/three.js/master/build/three.js"
    }
  }
}
```


**Available command

``` bash
  rake bower:install #install js components
  rake bower:update  #update js components
```