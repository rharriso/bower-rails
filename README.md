bower-rails
===========

rake tasks for bower on rails. Dependency file is bower.json in Rails root dir.

**Install**
in Gemfile

``` Ruby
  gem 'bower-rails'
```

**example config file**
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


**To install javascript files to correspondign directories**

``` bash
  rake bower:install
```