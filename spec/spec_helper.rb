$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'function_object'

module DefFunctionHelper
  def def_function(&block)
    Class.new do
      include FunctionObject
      class_eval(&block)
    end
  end
end

RSpec.configure do |config|
  config.include DefFunctionHelper
end
