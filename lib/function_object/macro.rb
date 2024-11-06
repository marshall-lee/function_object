class FunctionObject::Macro
  def initialize(args)
    @mod_initialize = DefInitialize.with(*args)
    @parameters = @initialize.instance_method(:initialize).parameters
    @mod_class_call = ClassCall.new(args_str, @parameters)
  end

  attr_reader :mod_initialize,
              :mod_class_call

  class ClassCall < Module
    def initialize(args_str, parameters)
      used_names = parameters.map { |_, n| n }.compact
      unk_counter = 0
      names = parameters.map do |_, name|
        next name if name

        while used_names.include?(name = "unknown_#{unk_counter}")
          unk_counter += 1
        end
        name
      end
      nargs_str = parameters.zip(names).map do |(type, _), name|
        case type
        when :req, :opt then name
        when :keyreq, :key then "#{name}: #{name}"
        when :rest then "*#{name}"
        when :keyrest then "**#{name}"
        end
      end.join(', ')

      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def call(#{args_str})
          new(#{nargs_str}).call
        end
      RUBY
    end
  end
end
