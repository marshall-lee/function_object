class FunctionObject::Macro
  def initialize(arg_descs)
    @arg_descs = arg_descs
    @has_defaults = arg_descs.any?(&:default?)

    @arg_descs_without_defaults = arg_descs.take_while { |d| !d.default? }
    @arg_descs_with_defaults = arg_descs[arg_descs_without_defaults.length .. -1]
  end

  def class_mixin
    Module.new.tap do |mixin|
      arg_descs_with_defaults.each do |desc|
        mixin.module_eval do
          name = "_default_#{desc.name}"
          define_method(name, &desc.default)
          private name
        end
      end

      arg_descs.each do |desc|
        mixin.module_eval do
          attr_reader desc.name
        end
      end

      mixin.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def initialize(#{arg_list_stmt})
          #{ivar_assign_stmt}
        end
      RUBY
    end
  end

  def sclass_mixin
    Module.new.tap do |mixin|
      mixin.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def call(#{arg_list_stmt})
          new(#{arg_list_stmt}).call
        end
      RUBY
    end
  end

  private

  def arg_list_stmt
    stmts = arg_descs_without_defaults.map(&:name)
    stmts << '*_args' if defaults?
    stmts.join(',')
  end

  def ivar_assign_stmt
    stmts = []
    arg_descs_without_defaults.each do |desc|
      stmts << "@#{desc.name} = #{desc.name}"
    end
    arg_descs_with_defaults.each_with_index do |desc, i|
      stmts << <<-RUBY
        @#{desc.name} = if #{i} < _args.length
                          _args[#{i}]
                        else
                          _default_#{desc.name}
                        end
      RUBY
    end
    stmts.join($/)
  end

  attr_reader :arg_descs,
              :arg_descs_with_defaults,
              :arg_descs_without_defaults

  def defaults?
    @has_defaults
  end
end
