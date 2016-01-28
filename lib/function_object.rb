require 'function_object/version'

class FunctionObject
  class ArgumentsBuilder
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

    def build(&block)
      @descriptors = []
      instance_exec(&block)
      @descriptors
    end

    def argument(name, options = {})
      default = options[:default]
      @descriptors << Descriptor.new(name, default, options)
    end
    alias_method :arg, :argument
  end

  class << self
    def arguments(&block)
      arg_descs = ArgumentsBuilder.new.build(&block)
      has_defaults = arg_descs.any?(&:default?)

      without_defaults = arg_descs.take_while { |d| !d.default? }
      with_defaults = arg_descs[without_defaults.length .. -1]

      mixin = Module.new

      mixin.module_eval do
        with_defaults.each do |desc|
          private define_method("_default_#{desc.name}", &desc.default)
        end
      end if has_defaults

      mixin.module_eval do
        arg_descs.each do |desc|
          attr_reader desc.name
        end
      end

      arg_list_stmts = without_defaults.map(&:name)
      arg_list_stmts << '*_args' if has_defaults
      arg_list_stmt = arg_list_stmts.join(',')

      assign_stmts = []
      without_defaults.each do |desc|
        assign_stmts << "@#{desc.name} = #{desc.name}"
      end
      with_defaults.each_with_index do |desc, i|
        assign_stmts << <<-RUBY
          @#{desc.name} = if #{i} < _args.length
                            _args[#{i}]
                          else
                            _default_#{desc.name}
                          end
        RUBY
      end
      assign_stmt = assign_stmts.join($/)

      mixin.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def initialize(#{arg_list_stmt})
          #{assign_stmt}
        end
      RUBY

      include mixin

      smixin = Module.new

      smixin.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def call(#{arg_list_stmt})
          new(#{arg_list_stmt}).call
        end
      RUBY

      singleton_class.class_eval { include smixin }
    end
    alias_method :args, :arguments
  end
end
