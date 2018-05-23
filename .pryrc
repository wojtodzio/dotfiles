## Aliases defined as methods to undefined method errors

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
# echo "def rs
#   puts 'Applying new TTY size...'
#   x, y = \`stty size\`.split.map(&:to_i)
#   Readline.set_screen_size(x, y)
#   true
# rescue
#   false
# end" >> ~/.pryrc
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
def f(*number_or_names)
  if number_or_names.first.is_a?(Integer) && number_or_names.length == 1
    number = number_or_names.first
    args = (1..number).map { |n| "a#{n}" }
  elsif number_or_names.all? { |name| name.is_a?(String) } && number_or_names.length >= 1
    args = number_or_names
  else
    raise 'Provide either a number of arguments, or arguments names as strings'
  end

  puts_args = args.map { |arg_name| %("#{arg_name}: \#{#{arg_name}}") }
  proc = %(Proc.new { |#{args.join(', ')}| puts "#{hr}", #{puts_args.join(', ')}, "#{hr}" })

  eval(proc)
end
