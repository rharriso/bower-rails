## Edge version

* add configurable option for performing `rake bower:install` and `rake bower:clean` tasks before assets precompilation
* add ability to pass bower CLI options to bower-rails rake tasks if nessesary
* `rake bower:clean` task added to remove any component files not specified in their respective bower.json main directives by @paulnsorensen [#65][]
* `require 'find'` in bower.rake to fix `uninitialized constant Find` by @cmckni3 [#69][]
* allow a bundler-like way of specifying versions for Git Repos by @davetron5000 [#70][]

[#65]: https://github.com/42dev/bower-rails/pull/65
[#69]: https://github.com/42dev/bower-rails/pull/69
[#70]: https://github.com/42dev/bower-rails/pull/70

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
