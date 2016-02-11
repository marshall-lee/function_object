class FunctionObject
  class Curry
    def initialize(object, arity_range, args = [])
      @object = object
      @arity_range = arity_range
      @args = args
    end

    def call(*args)
      new_args = @args + args

      if new_args.count < @arity_range.first
        Curry.new(@object, @arity_range, new_args)
      else
        @object.(*new_args)
      end
    end
    alias [] call

    def to_proc
      method(:call).to_proc
    end
  end
end
