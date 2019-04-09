require "tableparser/version"

# Helpers for table formatted results
module Tableparser
  # @overload parse(io)
  #   @param [String] io io with source data to parse
  #   @return [Array<Array<String>>] rows
  # @overload parse(io, &block)
  #   @param [String] io io with source data to parse
  #   @yieldparam [Array<String>] row each row
  #
  # Parses output from tables (often from SQL queries) to CSV-like array of
  # rows of strings.
  #
  # It expects the contents of +io+ to look something like this, and will
  # skip over rows that don't match the format.
  #
  #     +---------+---------+
  #     | col1    | col2    |
  #     +---------+---------+
  #     | val     | val     |
  #     | val     | val     |
  #     +---------+---------+
  #
  # @example
  #   Tableparser.parse(STDIN) # =>
  #   [['col1', 'col2'], ['val', 'val'], ['val', 'val']]
  # @example
  #   Tableparser.parse(STDIN) do |row|
  #     # ...
  #   end
  def self.parse(io)
    iter = io.each_line
    pattern = /\|/

    if block_given?
      iter.grep(pattern) do |line|
        yield parse_line(line)
      end
    else
      iter.grep(pattern).map { |line| parse_line(line) }
    end
  end

  # @overload parse_to_struct(io, struct)
  #   @param [String] io io with source data to parse
  #   @param [Class] struct class that rows will be parsed as
  #   @return [Array<struct>] an array of instances of the +struct+ with fields
  #     set from the corresponding columns
  # @overload parse(io, struct, &block)
  #   @param [String] io io with source data to parse
  #   @yieldparam [struct] row each row
  #
  # Assumes +struct+ was from +Struct.new(:col1, :col2)+. The code sets values on
  # the struct by name, not by index.
  #
  # *Note*: the code will downcase column names when setting.
  #
  def self.parse_to_struct(io, struct)
    cols = nil

    # grap the header row
    parse(io) do |values|
      cols = values
      break
    end

    if block_given?
      parse(io) do |values|
        yield to_struct(values, struct, cols)
      end
    else
      parse(io).map do |values|
        to_struct(values, struct, cols)
      end
    end
  end

  # @api private
  # @param [String] line
  # @return [Array<String>]
  # @example parse a line
  #  parse_line("| banklin_card_token           | state       |")
  #  => ['banklin_card_token', 'state']
  def self.parse_line(line)
    line.chomp.split('|').map(&:strip)[1..-1]
  end

  # @api private
  def self.to_struct(values, struct, cols)
    struct.new.tap do |row|
      cols.zip(values).each do |name, val|
        row[name.downcase] = val
      end
    end
  end
end
