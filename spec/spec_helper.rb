require 'coveralls'
Coveralls.wear!

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'bower-rails'

class Hash
  def except(*keys)
    keys.each { |key| delete(key) }
    self
  end
end
