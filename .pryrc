## Use method instead of alias in case `reload!` is not available
def r
  reload!
end

## Formatting SQL strings
class String
  SQL_JOINS = (%w[LEFT RIGHT FULL].reduce([]) do |accum, join_type|
    accum << "#{join_type} JOIN" << "#{join_type} OUTER JOIN"
  end << 'INNER JOIN').freeze
  SQL_COMMANDS = SQL_JOINS +
                 %w[SELECT
                    FROM
                    DISTINCT
                    WHERE
                    AND
                    GROUP\ By
                    ORDER
                    HAVING
                    INSERT
                    UPDATE
                    DELETE].freeze

  def f
    formatted = SQL_COMMANDS.inject(self) do |string, command|
      string.gsub(/#{command}/i, command)
            .gsub(/ #{command}/, "\n#{command}")
    end

    if formatted.starts_with?('SELECT')
      temp = formatted.split(',').map(&:strip)
      temp [1..-1] = temp[1..-1].map do |string|
        string = ' ' * 7 + string
      end
      formatted = temp.join(",\n")
    end

    puts formatted

    formatted
  end
end

if defined? ActiveRecord::Relation
  ActiveRecord::Relation.delegate :f, to: :to_sql
end

## EMACS
Pry.config.pager = false if ENV["INSIDE_EMACS"]
Pry.config.correct_indent = false if ENV['INSIDE_EMACS']
Pry.color = true

## pry-byebug
if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

# Refresh TTY size
def rs
  puts 'Applying new TTY size...'
  x, y = `stty size`.split.map(&:to_i)
  Readline.set_screen_size(x, y)
  true
rescue
  false
end

def hr
  '-' * (`stty size`.split(' ').last.to_i)
end

def procrastinate(page = 1, with_comments: true)
  require 'net/http'
  require 'nokogiri'

  uri      = URI.parse("https://anonimowe.pl/#{page}")
  page     = Net::HTTP.get(uri)
  parsed   = Nokogiri::HTML.parse(page)
  articles = parsed.xpath('//article')

  text = articles.map do |article|
    id       = article.xpath('header/h3/a').text
    section  = article.xpath('section').text
    comments = article.xpath('div/div/section/section/p').map(&:text).join

    ["id: #{id}", section, ("Comments: #{comments}" if with_comments)].join("\n")
  end

  pager      = Pry::Pager.new(Pry.new(Pry.config))
  final_text = text.join("\n#{hr}\n")

  pager.page(final_text)
end

# debug yielded parameters easily
# enumerable.any?(&f(2))
# ==
# enumerable.any? { |a1, a2| puts hr, "a1: #{a1}", "a2: #{a2}", hr }
#
# enumerable.any?(&f('field', 'field_name'))
# ==
# enumerable.any? { |field, field_name| puts hr, "field: #{field}", "field_name: #{field_name}", hr }
#
# enumerable.any?(&f(2, 2, 1))
# ==
# enumerable.any? { |a1, a2, (a3, a4), a5| puts hr, "a1: #{a1}", "a2: #{a2}", "a3: #{a3}", ..., hr }
# TODO: Totally refactor this
def f(*numbers_or_names, start_with_closure: false)
  if numbers_or_names.first.is_a?(Integer) && numbers_or_names.length == 1
    args      = (1..numbers_or_names.first).map { |n| "a#{n}" }
    proc_args = args.join(', ')
  elsif numbers_or_names.all? { |name| name.is_a?(Integer) } && numbers_or_names.length > 1
    args = (1..numbers_or_names.reduce(:+)).map { |n| "a#{n}" }

    arg_num = 1
    proc_args = numbers_or_names.map do |num_of_args_in_group|
      (arg_num...(arg_num + num_of_args_in_group)).map { |n| "a#{n}" }.tap do
        arg_num += num_of_args_in_group
      end
    end
    inside_closure = start_with_closure
    proc_args = proc_args.map { |args_group| args_group.join(', ') }.map do |args_group|
      (inside_closure ? "(#{args_group})" : args_group).tap do
        inside_closure = !inside_closure
      end
    end.join(', ')
  elsif numbers_or_names.all? { |name| name.is_a?(String) } && numbers_or_names.length >= 1
    args = numbers_or_names
    proc_args = args.join(', ')
  else
    raise 'Provide either a number of arguments, or arguments names as strings'
  end

  puts_args = args.map { |arg_name| %("#{arg_name}: \#{#{arg_name}}") }
  proc = %(Proc.new { |#{proc_args}| puts "#{hr}", #{puts_args.join(', ')}, "#{hr}" })

  eval(proc)
end

def copy(text)
  text = text.join("\n") if text.is_a?(Array)

  `echo "#{text}" | pbcopy`
end
alias pbcopy copy # Some gems add a global `copy` method :/

def sort(text)
  copy(text.split("\n").sort)
end

def catch_exception
  begin
    yield
  rescue => e
    e
  end
end

