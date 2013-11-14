## Edge version
* fixed bug with `bower:update` and `bower update:prune`: now refreshes `bower.json` after update task is executed
* `rake bower:list` task now available
* There is no more `dsl` namespace for rake tasks. Tasks are the same as for `bower.json` also for `Bowerfile` configuration files.
* Add support for standard bower package format by @kenips ([#41][])
* If a `.bowerrc` file is available in the rails project root, it will now be used as the starting point for the generated `.bowerrc` by @3martini. ([#40][])
* Root path is now always `Dir.pwd` without depending on `Rails.root`. Fixes [#42][]
* [DSL] Allow to store assets only in `:lib` or `:vendor` directories.
* [DSL] Keep groups independent. Fixes [#44][]
* [DSL] Assign default or custom `assets_path` for a group if it is not provided

[#44]: https://github.com/42dev/bower-rails/issues/44
[#42]: https://github.com/42dev/bower-rails/issues/42
[#41]: https://github.com/42dev/bower-rails/pull/41
[#40]: https://github.com/42dev/bower-rails/pull/40

## v0.5.0
* Jsfile was renamed to Bowerfile and BowerRails::Dsl#js to BowerRails::Dsl#asset ([discussion][])
[discussion]: https://github.com/42dev/bower-rails/pull/29