# frozen_string_literal: true

module WithManufacturer
  def list_manufacturer(name)
    @manufacturer = name
  end

  def manufacturer
    @manufacturer
  end
end
