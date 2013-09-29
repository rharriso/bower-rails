## Edge version
* fixed bug with `bower:update` and `bower update:prune`: now refreshes `bower.json` after update task is executed
* `rake bower:list` task now available
* There is no more `dsl` namespace for rake tasks. Tasks are the same as for `bower.json` also for `Bowerfile` configuration files.

## v0.5.0
* Jsfile was renamed to Bowerfile and BowerRails::Dsl#js to BowerRails::Dsl#asset ([discussion][])
[discussion]: https://github.com/42dev/bower-rails/pull/29