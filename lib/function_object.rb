class FunctionObject
  require 'function_object/version'
  require 'function_object/arguments_builder'
  require 'function_object/macro'
  require 'function_object/curry'

  class << self
    def arguments(*simple_args, &block)
      arg_descs =
        ArgumentsBuilder.new(simple_args).build(&block)

      include_macro_mixin(Macro.new(arg_descs))
    end
    alias_method :args, :arguments

    def call
      new.call
    end
    alias [] call

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

  private

    def include_macro_mixin(macro)
      self.class_eval { include macro.class_mixin }
      singleton_class.class_eval { include macro.sclass_mixin }
    end
  end

  def call
  end
end
