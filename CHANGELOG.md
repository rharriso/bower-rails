## Egde version

Nothing pushed yet

## v0.11.0

* Bugfix with remove_extra_files when only bower.json in root without Bowerfile [#175][]
* Load Bowerfile from all gem dependencies before load by @gabealmer [#162][]
* Make bower components directory configurable [#183][]
* Shell-escape bower command to handle directories with spaces [#199][]
* Return proper exit code on rake tasks when 'bower' is not installed [#200][]
* Put url parameters outside of erb on paths resolve [#202][]

[#162]: https://github.com/rharriso/bower-rails/pull/162
[#175]: https://github.com/rharriso/bower-rails/pull/175
[#183]: https://github.com/rharriso/bower-rails/pull/183
[#199]: https://github.com/rharriso/bower-rails/pull/199
[#200]: https://github.com/rharriso/bower-rails/pull/200
[#202]: https://github.com/rharriso/bower-rails/pull/202

## v0.10.0

* add ability to configure bower to pass -F to bower install by @hubert [#129][]
* add ability to append files into `main` directive  by @gacha [#137][]

[#129]: https://github.com/42dev/bower-rails/pull/129
[#137]: https://github.com/rharriso/bower-rails/pull/137

## v0.9.2

* remove before hook in favour of rake dependency by @itszootime and @carsomyr [#121][]

[#121]: https://github.com/42dev/bower-rails/pull/121

## v0.9.1

* add `bower:clean:cache` rake task by @ruprict [#115][]

[#115]: https://github.com/42dev/bower-rails/pull/115

## v0.9.0

* do not resolve urls which start with '#' #102
* add support for [bower resolutions][] by @jasonayre [#107][]

[bower resolutions]: http://jaketrent.com/post/bower-resolutions/
[#107]: https://github.com/42dev/bower-rails/pull/107

## v0.8.3

* add `use_bower_install_deployment` configurable option by @Zhomart [#101][]
* fix `"cleans *.css.erb files before assets:precompile"` by @Zhomart [#101][]
* added support wildcards for task `rake bower:clean` by @Zhomart [#101][]

[#101]: https://github.com/42dev/bower-rails/pull/101

## v0.8.2

* fix `"undefined method 'perform' for main:Object"` by @kenips [#99][]

[#99]: https://github.com/42dev/bower-rails/pull/99

## v0.8.1

* Add configurable `root_path` option for `bower-rails`
* Extract performing logic to the separate `BowerRails::Performer` class by @Melanitski [#95][]
* Add `rake bower:install:production`, `rake bower:install:development`, set `rake bower:install` to match `rake bower:install:production`
* Add dev_dependencies to your Bowerfile DSL resolving to devDependencies in your bowerfile.json

## v0.7.4

* Add `rake bower:install:deployment` which installs from generated bower.json without generating it first, keeping any additions (like dependency conflict resolutions) intact [#89][] and [#92][]

[#89]: https://github.com/42dev/bower-rails/pull/89
[#92]: https://github.com/42dev/bower-rails/pull/92
[#95]: https://github.com/42dev/bower-rails/pull/95

## v0.7.3

* Add `install_before_precompile` configurable option to invoke `rake bower:install` before precompilation
* DSL: Add ability to specify `ref` option which accepts commit's SHA and composes it as a component's version
* Fix `NoMethodError: undefined method 'full_comment' for nil:NilClass`. Check for `rake assets:precompile` task existance.

## v0.7.2

* add configurable option for performing `rake bower:install` and `rake bower:clean` tasks before assets precompilation
* add ability to pass bower CLI options to bower-rails rake tasks if nessesary
* `rake bower:clean` task added to remove any component files not specified in their respective bower.json main directives by @paulnsorensen [#65][]
* `require 'find'` in bower.rake to fix `uninitialized constant Find` by @cmckni3 [#69][]
* allow a bundler-like way of specifying versions for Git Repos by @davetron5000 [#70][]
* Fix bug with `rake assets:precompile` enhancing [#72][]
* Ensuring executable command doesn't point to a directory by @clouseauu [#73][]
* Add github option to DSL by @xtian [#75][]

[#65]: https://github.com/42dev/bower-rails/pull/65
[#69]: https://github.com/42dev/bower-rails/pull/69
[#70]: https://github.com/42dev/bower-rails/pull/70
[#72]: https://github.com/42dev/bower-rails/pull/72
[#73]: https://github.com/42dev/bower-rails/pull/73
[#74]: https://github.com/42dev/bower-rails/pull/75

## v0.7.1

* update initialize generator to create sample `Bowerfile` by @byterussian [#64][]
* update initialize generator to create a `bower-rails` initializer file

[#64]: https://github.com/42dev/bower-rails/pull/64

## v0.7.0

* add configuration option for `BowerRails` that invokes `rake bower:install` and `rake bower:resolve` tasks before assets precompilation
* fixed bug with `bower:resolve` task: skip `File.read` if it's not a file (ex.: a directory name contains ".css") by @yujiym [#55][]

[#55]: https://github.com/42dev/bower-rails/pull/55

## v0.6.1

* Disable installing bower assets before precompilation
* Search node_modules directory local to project by @jimpo [#52][]

[#52]: https://github.com/42dev/bower-rails/pull/52

## v0.6.0
* fixed bug with `bower:update` and `bower update:prune`: now refreshes `bower.json` after update task is executed
* `rake bower:list` task now available
* There is no more `dsl` namespace for rake tasks. Tasks are the same as for `bower.json` also for `Bowerfile` configuration files.
* Add support for standard bower package format by @kenips ([#41][])
* If a `.bowerrc` file is available in the rails project root, it will now be used as the starting point for the generated `.bowerrc` by @3martini. ([#40][])
* Root path is now always `Dir.pwd` without depending on `Rails.root`. Fixes [#42][]
* [DSL] Allow to store assets only in `:lib` or `:vendor` directories.
* [DSL] Keep groups independent. Fixes [#44][]
* [DSL] Assign default or custom `assets_path` for a group if it is not provided
* Add `bower:resolve` task to fix relative URLs in CSS files with Rails asset_path helper and resolve bower components before precompile by @jimpo [#49][]

[#49]: https://github.com/42dev/bower-rails/pull/49
[#44]: https://github.com/42dev/bower-rails/issues/44
[#42]: https://github.com/42dev/bower-rails/issues/42
[#41]: https://github.com/42dev/bower-rails/pull/41
[#40]: https://github.com/42dev/bower-rails/pull/40

## v0.5.0
* Jsfile was renamed to Bowerfile and BowerRails::Dsl#js to BowerRails::Dsl#asset ([discussion][])
[discussion]: https://github.com/42dev/bower-rails/pull/29
