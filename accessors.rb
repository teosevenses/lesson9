module Accessors

  def attr_accessor_with_history(*attributes)
    attributes.each do |attribute|
      var_attribute = "@#{attribute}".to_sym
      var_history = "@#{attribute}_history".to_sym
      define_method(attribute) { instance_variable_get(var_attribute) }
      define_method("#{attribute}=") do |value|
        if instance_variable_get(var_history).nil?
          instance_variable_set(var_history, [])
        end
        instance_variable_get(var_history) << instance_variable_get(var_attribute)
        instance_variable_set(var_attribute, value)
      end
    end
  end

  def strong_attr_accessor(name, class_name)
    var_name = "@#{name}".to_sym
    define_method(name) { instance_variable_get(var_name) }
    define_method("#{name}=") do |value|
      klass = Object.const_get(class_name)
      raise "Ошибка, переменная (#{value}) не является классом #{class_name}" unless value.is_a?(klass)
      instance_variable_set(var_name, value)
    end
  end
end

