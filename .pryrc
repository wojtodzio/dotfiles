## Shortcut for reloading
def r
  reload!
end

## Formatting SQL strings
class String
  SQL_COMMANDS = %w(SELECT
                    FROM
                    DISTINCT
                    WHERE
                    AND
                    GROUP
                    ORDER
                    HAVING
                    INSERT
                    UPDATE
                    DELETE
                    INNER\ JOIN
                    LEFT\ JOIN).freeze

  def f
    formatted = SQL_COMMANDS.inject(self) do |string, command|
      string.gsub(/#{command}/i, command)
            .gsub(/[^\A]#{command}/, "\n#{command}")
    end

    if formatted.downcase.starts_with?('select')
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

## EMACS
# Pry.config.pager = false if ENV["INSIDE_EMACS"]
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
