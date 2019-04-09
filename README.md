# Tableparser

A gem for parsing table-like formats like from SQL output such as MySQL (when it's not batch-formatted).

```ruby
io = StringIO.new <<-EOS
+---------+---------+
| col1    | col2    |
+---------+---------+
| val     | val     |
| val     | val     |
+---------+---------+
EOS
Tableparser.parse(io)
# => [['col1', 'col2'], ['val', 'val'], ['val', 'val']]
```

It can also parse the content in to instances of a `Struct` class.

```ruby
MyRow = Struct.new(:col1, :col2)
Tableparser.parse_to_struct(io, MyRow)
# => [#<struct MyRow col1="val", col2="val">, #<struct MyRow col1="val", col2="val">]
```

Also comes with a handy `tableparser` exectuable:

```bash
$ echo "SELECT 1 AS one, 2 AS two" | mysql --table
+-----+-----+
| one | two |
+-----+-----+
|   1 |   2 |
+-----+-----+

$ echo "SELECT 1 AS one, 2 AS two" | mysql --table | tableparser
one,two
1,2
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tableparser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tableparser

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachmargolis/tableparser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tableparser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zachmargolis/tableparser/blob/master/CODE_OF_CONDUCT.md).
