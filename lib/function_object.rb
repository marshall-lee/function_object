class FunctionObject
  require 'function_object/version'
  require 'function_object/arguments_builder'
  require 'function_object/macro'

  class << self
    def arguments(&block)
      arg_descs = ArgumentsBuilder.new.build(&block)
      macro = Macro.new(arg_descs)
      self.class_eval { include macro.class_mixin }
      singleton_class.class_eval { include macro.sclass_mixin }
    end
    alias_method :args, :arguments

    def to_proc
      method(:call).to_proc
    end
  end
end
