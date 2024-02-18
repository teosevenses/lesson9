# frozen_string_literal: true

class PassengerTrain < Train
  def initialize(num)
    @type = :passenger
    super
  end
end
