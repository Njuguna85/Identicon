defmodule Identicon.Image do
  # hex is the list of hashed numbers
  # struct can have a default value and can only hold some primitive data
  # this can only take a hex property and not any other
  defstruct(hex: nil, color: nil, grid: nil, pixel_map: nil)
end
