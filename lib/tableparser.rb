require "tableparser/version"

# Helpers for table formatted results
module Tableparser
  # @param [String] io io with source data to parse
  # @return [Array<Array<String>>] rows
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
  #   Tableparser.parse(STDIN)
  #   => [['col1', 'col2'], ['val', 'val'], ['val', 'val']]
  def self.parse(io)
    io.readlines.map(&:chomp).grep(/\|/).map { |line| parse_line(line) }
  end

  # @param [String] io io with source data to parse
  # @param [Class] struct class that rows will be parsed as
  #
  # Assumes +struct+ was from +Struct.new(:col1, :col2)+. The code sets values on
  # the struct by name, not by index.
  #
  # *Note*: the code will downcase column names when setting.
  #
  # @return [Array<struct>] an array of instances of the +struct+ with fields
  #   set from the corresponding columns
  def self.parse_to_struct(io, struct)
    header_line, *rest = parse(io)

    cols = header_line.map(&:strip).reject(&:empty?)

    rest.map do |values|
      struct.new.tap do |row|
        cols.zip(values).each do |name, val|
          row[name.downcase] = val
        end
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
    line.split('|').map(&:strip)[1..-1]
  end
end
