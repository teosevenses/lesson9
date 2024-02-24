# frozen_string_literal: true

require_relative 'with_manufacturer'
require_relative 'instance_counter'
require_relative 'validate'

class Train
  include InstanceCounter
  include WithManufacturer
  include Validation
  NUMBER_FORMAT = /^[A-Za-z0-9]{3}-?[A-Za-z0-9]{2}$/.freeze

  attr_reader :type, :num, :wagons, :attach_wagon, :all
  attr_accessor :route, :station

  validate :number, :format, NUMBER_FORMAT
  validate :number, :type, String

  class ValidationError < StandardError
  end

  def self.find(num)
    all.find { |train| num == train.num }
  end

  def initialize(num)
    @num = num
    @wagons = []
    @all = []
    @all << self
    raise ValidationError, 'Некорректные данные, пример номера 123-45, 222' unless valid?

    register_instance
  end

  def assign_route(route)
    route.trains << self
    self.route = route
    self.station = 0
  end

  def move_forward
    return unless !route.nil? && !station.nil?

    self.station = station + 1
  end

  def move_back
    return unless !route.nil? && !station.nil?

    self.station = station - 1
  end

  def yield_wagons(&block)
    @wagons.each do |wagon|
      block.call(wagon)
    end
  end

  private

  def valid?
    num.is_a?(String) && /^[0-9а-яА-Я]{3}(-[0-9a-zA-Z]{2})?\Z/.match?(num)
  end
end
