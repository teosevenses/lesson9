# frozen_string_literal: true

require_relative 'instance_counter'
require_relative 'validate'

class Station
  include InstanceCounter
  include Validation

  attr_accessor :trains, :name
  attr_reader :all

  validate :name, :presence
  validate :name, :type, String

  class ValidationError < StandardError
  end

  def initialize(name)
    @name = name
    @trains = []
    raise ValidationError, 'Некорректное наименование станции, длина не менее двух символов' unless valid?.to_s

    @all = []
    @all << self
    register_instance
  end

  class << self
    attr_reader :all
  end

  def add_train(train)
    @trains << train
  end

  def delete_train(train)
    @trains.delete(train)
  end

  def train_type(type)
    @trains.select { |train| train.type == type }.count
  end

  def valid?
    name.is_a?(String) && /^[0-9а-яА-Я]{2,}\Z/.match?(name)
  end

  def yield_trains(&block)
    @trains.each do |train|
      block.call(train)
    end
  end
end
