require 'yaml'
require 'optparse'

def check_existence_in_yaml(expectedObj, obj_in_file, space_num)
  unless space_num == 0 || (expectedObj.is_a?(Hash) && obj_in_file.is_a?(Hash))
    puts " " * space_num + "Expected: [" + expectedObj.inspect + "]"
    puts " " * space_num + "Actually: [" + obj_in_file.inspect + "]"
    puts
  else
    unless expectedObj.nil? && obj_in_file.nil?
      expectedObj.each do |key, value|
        unless obj_in_file[key].nil?
          unless obj_in_file[key] == value
            @@__has_error = true
            puts " " * space_num + "Error in checking key[" + key.inspect + "]"
            check_existence_in_yaml(value, obj_in_file[key], space_num + 2)
          end
        else
          unless value.nil?
            puts "Error: key[" + key.inspect + "] not exist!!!\n"
          end
        end
      end
    else
      puts "Error: expectedObj is nil or obj_in_file is nil\n"
    end
  end
end

#OPT ANALYSE
options = {}
options[:modified] = []

OptionParser.new do |opts|
  opts.banner = "Usage: yml_utility.rb [options]"

  opts.on("-m", "--modified-files=filepath1,filepath2", "All modified yml files(full path), use comma to seperate") do |v|
    unless v.nil? || v.to_s.empty?
      a = v.to_s.split(',')
      a.each do |value|
        options[:modified].push(value)
      end
    end

  end

  opts.on("-t", "--target-file=filepath", "The target yml file") do |v|
    options[:target] = v
  end

  opts.on("-p", "--print=filepath", "Print help") do |v|
    options[:printfile] = v
    exit
  end

  opts.on("-h", "--help", "Print help") do
    puts opts
    exit
  end

end.parse!

unless options[:printfile].nil? || options[:printfile].to_s.empty?
  if options[:modified].empty? || options[:target].nil? || options[:target].to_s.empty?
    puts "No input for modified file paths or target file, we need both of them set"
  else
    puts "No input for print action!"
  end
else
  print_file(options[:printfile])
end

def print_file(printfile)
  #PRINT FILE
  puts "Start loading file ..."
  tar_file = YAML.load_file(printfile)

  puts "Print file content ..."
  puts tar_file
end

def compare_files(options)
  #COMPARE FILES

  @@__has_error = false

  ori_files = {}
  ori_files[:name] = []
  ori_files[:content] = []
  __count = 0

  puts "Start loading modified files..."
  options[:modified].each do |path|
    if (File.exist?(path)) then
      ori_files[:name].insert(__count, File.absolute_path(path))
      ori_files[:content].insert(__count, YAML.load_file(path))
      __count = __count + 1
    else
      puts "Error: " + File.absolute_path(path) + " not exist, so it will not be loaded"
    end
  end
  puts "Load complete"

  puts "Start loading target file..."
  tar_file = YAML.load_file(options[:target])
  puts "Load complete"

  tar_file.each do |key, value|
    puts "Now checking file => " + key
    _index = ori_files[:name].find_index(key)
    unless _index.nil?
      check_existence_in_yaml(value, ori_files[:content][_index], 0)
    else
      @@__has_error = true
      puts "Error : can not find file => " + key
    end
  end

  unless @@__has_error
    puts "All checking has passed :)"
  end
end
