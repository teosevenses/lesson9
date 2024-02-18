# frozen_string_literal: true

require_relative 'with_manufacturer'

class Wagon
  include WithManufacturer

  attr_reader :type, :num, :busy_place, :place

  def initialize(num, place)
    @num = num
    @place = place
    @busy_place = 0
  end

  def take_place
    @busy_place += 1
  end

  def free_place
    place - busy_place
  end
end
