require 'def_initialize'

module FunctionObject
  require 'function_object/version'
  require 'function_object/macro'
  require 'function_object/curry'

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def call_args(*args)
      macro = Macro.new(args)
      self.class_eval { include macro.class_mixin }
      singleton_class.class_eval { include macro.sclass_mixin }
    end

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
  end

  def call
  end
end
