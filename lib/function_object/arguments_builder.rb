class FunctionObject::ArgumentsBuilder
  Descriptor = Struct.new(:name, :default, :options) do
    def initialize(*)
      super
      if default? && !self.default.respond_to?(:call)
        fail ArgumentError, "#{self.default.inspect} is expected to be callable"
      end
    end

    def default?
      options.key? :default
    end
  end

  def initialize
    @descriptors = []
  end

  def build(&block)
    instance_exec(&block) if block
    @descriptors
  end

  def argument(name, options = {})
    default = options[:default]
    @descriptors << Descriptor.new(name, default, options)
  end
  alias_method :arg, :argument
end
