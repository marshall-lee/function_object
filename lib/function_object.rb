class FunctionObject
  require 'function_object/version'
  require 'function_object/arguments_builder'
  require 'function_object/macro'
  require 'function_object/curry'

  class << self
    def arguments(*simple_args, &block)
      arg_builder = ArgumentsBuilder.new
      simple_args.map { |name| arg_builder.argument(name) }
      arg_descs = arg_builder.build(&block)
      macro = Macro.new(arg_descs)
      self.class_eval { include macro.class_mixin }
      singleton_class.class_eval { include macro.sclass_mixin }
    end
    alias_method :args, :arguments

    def call
      new.call
    end

    def to_proc
      method(:call).to_proc
    end

    def curry(arity = 0)
      unless arity == 0
        raise ArgumentError,
              "wrong number of arguments (given #{arity}, expected 0)"
      end
      self
    end
  end

  def call
  end
end
