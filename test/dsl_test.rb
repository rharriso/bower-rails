require "../lib/bower-rails/dsl"

BowerRails::Dsl.config = {:root_path => File.expand_path("./out") }

inst = BowerRails::Dsl.evalute(File.expand_path("./Bowerfile"))

inst.write_bower_json
