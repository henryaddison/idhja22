# Idhja22

Mostly my attempt at writing a gem.

Used for training a binary classifying tree (target values should be Y or N). Leaf nodes are a probability of Y rather than a Y or N.

## Installation

Add this line to your application's Gemfile:

    gem 'idhja22'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install idhja22

## Usage

Simplest usage is to have a CSV of training data. The final column is treated as the target category value of each entry, the other columns are attributes for each datum. The first row is used as for attribute and target category labels.

    > tree = Idhja22::Tree.train_from_csv('/path/to/data.csv')

To print out the rules produced by the tree:
    > puts tree.get_rules

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
