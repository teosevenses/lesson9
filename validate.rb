module Validation
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def validate(attribute, validation_type, *arg)
      @validations ||= []
      @validations << { attribute: attribute, type: validation_type, arg: arg }
    end
  end

  module InstanceMethods
    def validate!
      self.class.instance_variable_get(:@validations).each do |validation|
        attribute = instance_variable_get("@#{validation[:attribute]}")
        send("validate_#{validation[:type]}", attribute, *validation[:arg])
      end
    end

    def valid?
      validate!
      true
    rescue StandardError
      false
    end

    def presence_validate(attribute)
      raise "Ошибка валидации, нужно ввести #{attribute}" if attribute.nil? || attribute.empty?
    end

    def format_validate(attribute, format_type)
      raise "Ошибка формата, нужно ввести корректный #{attribute}" unless attribute.match(format_type)
    end

    def type_validate(attribute, attribute_class)
      raise "Ошибка типа: #{attribute} не соответствует классу #{attribute_class}" unless attribute.is_a?(attribute_class)
    end
  end
end
