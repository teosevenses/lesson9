# frozen_string_literal: true

class PassengerWagon < Wagon
  def initialize(num, place)
    @type = :passenger
    super
  end
end
