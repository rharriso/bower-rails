bower-rails
===========

[![Gem Version](https://badge.fury.io/rb/bower-rails.png)](http://badge.fury.io/rb/bower-rails)
[![Code Climate](https://codeclimate.com/github/42dev/bower-rails.png)](https://codeclimate.com/github/42dev/bower-rails)
[![Dependency Status](https://gemnasium.com/SergeyKishenin/bower-rails.png)](https://gemnasium.com/SergeyKishenin/bower-rails)
[![Build Status](https://travis-ci.org/42dev/bower-rails.png?branch=master)](https://travis-ci.org/42dev/bower-rails)
[![Coverage Status](https://coveralls.io/repos/42dev/bower-rails/badge.png)](https://coveralls.io/r/42dev/bower-rails)

Bower support for Rails projects. Dependency file is bower.json in Rails root dir or Bowerfile if you use DSL.
Check out [changelog][] for the latest changes and releases.

[changelog]: https://github.com/42dev/bower-rails/blob/master/CHANGELOG.md

**Requirements**

* [node](http://nodejs.org) ([on github](https://github.com/joyent/node))
* [bower](https://github.com/bower/bower) (>= 0.10.0) installed with npm

**Install**

in Gemfile

``` Ruby
  gem "bower-rails", "~> 0.6.1"
```

##JSON configuration

Bower-rails now supports the standard [bower package](https://github.com/bower/bower#defining-a-package) format out-of-the-box. Simply place your bower.json file the Rails root directory to start. Using the standard format will default all bower components to be installed under the `vendor` directory.

To install dependencies into both `lib` and `vendor` directories, run the initializer to generate a custom bower.json:

``` Bash
  rails g bower_rails:initialize
```

This will generate a special bower.json that combines two standard bower packages into one. Simply specify your dependencies under each folder name to install them into the corresponding directories.

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
NOTE: Available groups are `:lib` and `:vendor`. Others are not allowed according to the Rails convention.
NOTE: All the assets should be stored in `/assets` subdirectory so putting it under `./vendor/js` directory is unavailable

##Rake tasks

Once you are done with `bower.json` or `Bowerfile` you can run

* `rake bower:install` to install js components
* `rake bower:install:force` to install with force option
* `rake bower:update` to update js components
* `rake bower:update:prune` to update components and uninstall extraneous packages
* `rake bower:list` to list all packages
* `rake bower:resolve` to resolve [relative asset paths](#relative-asset-paths) in components

##Bower Configuration

If you provide a `.bowerrc` in the rails project root, bower-rails will use it for bower configuration.
Some .bowerrc options are not supported: `directory`, `cwd`, and `interactive`. Bower-rails
will ignore the `directory` property and instead will use the automatically generated asset path.

###Bower Installation

[Bower](https://github.com/bower/bower) should be installed using npm. Bower can be installed globally (with `$ npm install -g bower`) or in `node_modules` in the root directory of your project.

##Relative asset paths

Some bower components (eg. [Bootstrap](https://github.com/twbs/bootstrap/blob/0016c17f9307bc71fc96d8d4680a9c861f137cae/dist/css/bootstrap.css#L2263)) have relative urls in the CSS files for imports, images, etc. Rails prefers using [helper methods](http://guides.rubyonrails.org/asset_pipeline.html#coding-links-to-assets) for linking to assets within CSS. Relative paths can cause issues when assets are precompiled for production.

Before the `rake assets:precompile` task is run, the bower assets will be reinstalled with the relative paths replaced with calls to `asset_path` so that all asset links work in production.