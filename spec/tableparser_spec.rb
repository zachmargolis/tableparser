require 'spec_helper'
require 'stringio'
require 'tableparser'

RSpec.describe Tableparser do
  let(:struct_class) { Struct.new(:col1, :col2) }

  let(:io) do
    StringIO.new <<~EOS
      +---------+---------+
      | col1    | col2    |
      +---------+---------+
      | val     | val     |
      | val     | val     |
      +---------+---------+
    EOS
  end

  describe '#parse' do
    it 'parses out into a CSV-like structure' do
      expect(Tableparser.parse(io)).to eq([
        ['col1', 'col2'],
        ['val', 'val'],
        ['val', 'val'],
      ])
    end

    context 'with blank values in rows' do
      let(:io) do
        StringIO.new <<~EOS
          +---------+---------+---------+
          | col1    | blank   | col2    |
          +---------+---------+---------+
          | val1    |         | val2    |
          +---------+---------+---------+
        EOS
      end

      it 'puts in empty string' do
        expect(Tableparser.parse(io)).to eq([
          ['col1', 'blank', 'col2'],
          ['val1', '', 'val2'],
        ])
      end
    end

    context 'with extra content that does not look like table content' do
      let(:io) do
        StringIO.new <<~EOS
          blah blah blah
          !!!! as;as;lkjasl;k
          ???? askl;dasl;adslj
          +---------+---------+
          | col1    | col2    |
          +---------+---------+
          | val     | val     |
          | val     | val     |
          +---------+---------+
          something somethign
        EOS
      end

      it 'skips the extra content' do
        expect(Tableparser.parse(io)).to eq([
          ['col1', 'col2'],
          ['val', 'val'],
          ['val', 'val'],
        ])
      end
    end
  end

  describe '#parse_to_struct' do
    it 'parses out into rows' do
      expect(Tableparser.parse_to_struct(io, struct_class)).to eq([
        struct_class.new('val', 'val'),
        struct_class.new('val', 'val'),
      ])
    end
  end
end

