require 'thor'
require 'rake'
Rake.load_rakefile(File.dirname(__FILE__)+'/Rakefile')
class Test < Thor
  desc "train_and_validate FILE", "train a tree for the given file and validate is against a validation set"
  method_option :"training-proportion", :type => :numeric, :default => 1.0, :aliases => 't'
  method_option :"data-dir", :type => :string, :default => File.dirname(__FILE__)+'/data'
  def train_and_validate(filename)
    Rake::Task['install'].invoke
    require 'idhja22'
    csv_path = "#{options[:'data-dir']}/#{filename}.csv"
    t, v = Idhja22::Tree.train_and_validate_from_csv(csv_path, options[:"training-proportion"])
    puts t.get_rules
    puts "Against validation set probability of successful classifiction: #{v}" if options[:"training-proportion"] < 1.0
  end
end