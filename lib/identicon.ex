defmodule Identicon do
  # the main function will accept input
  # and then pass it to hash_input which will make a struct
  # and then send it into pick color
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(2500, 2500)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        hor_dist = rem(index, 5) * 500
        ver_dist = div(index, 5) * 500
        top_left = {hor_dist, ver_dist}
        bottom_right = {hor_dist + 500, ver_dist + 500}
        {top_left, bottom_right}
      end)

    # Enum.map returns a new collection
    %Identicon.Image{image | pixel_map: pixel_map}

    # the func will genereate the coordinates of the individual pixels ie its top_left and bottom_right x,y
    # image is the reference to image struct in the function itself
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn {code, _index} -> rem(code, 2) == 0 end)
    %Identicon.Image{image | grid: grid}
    # the function above will call the Identicon.image module
    # and will invoke the grid key which will then pass its values
    # to image through pattern matching.
    # this will then filter the grid(which has a code and index)
    #  by checking if its remainder is 0. this is then stored
    # to a variable called grid in order to updates its record
    # by calling the module again and passing grid

    # i have a feeling that image is our temporary variable
    # that holds all other data
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
    # the func above will pass image properties to hex
    # and will then cut the list into groups of threes and
    # then pass it to mapping function whic will then invoke the
    # mirror_row function
    # We then flatten the list  inorder to produce one single list
    # instead of lists of lists.
    # we then pass the list to Enum,with_index which wil then
    # produce tuples of two items, with one being the main element in the list and the other being the index of the element
  end

  def mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
    # it will append the row list with second and first elements
    # using pattern matching
  end

  def pick_color(image) do
    # pick_color() will accept image variable which is passed on
    # by the pipe operator in main().
    # using pattern matching, the new var hex_list will get image properties
    # where then we will pick the first three elements from the list
    # and ignore the rest of tail to create a hex_list
    # then create a new image struct by taking all image struct properties (as Identicon.Image only accepts hex, color and grid)
    # and also creating a color key with values of a tuple of rgb
    # a tuple is appropriate as its
    %Identicon.Image{hex: hex_list} = image
    [r, g, b | _tail] = hex_list
    %Identicon.Image{image | color: {r, g, b}}
  end

  # The above function can be written as follows:

  # def pick_color(%Identicon.Image{hex:[r, g, b | _tail]} = image)# do
  #  %Identicon.Image{image | color:{r, g, b}}
  # end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
