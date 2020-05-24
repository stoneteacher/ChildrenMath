# frozen_string_literal: true

module ChildrenMath
  module_function

  def usage

    description =
      <<-EOF
Usage: chmath [options]
  -r, --result-number NUMBER       [Require] Range of result number.
                                   Range separator to use: '-'
                                   This option is mandatory
  -f, --first-number NUMBER        Range of first number. The default number is result number min to result number max.
                                   Range separator to use: '-'
  -c, --count NUMBER               Count of subject number. The default count is 99.
  -w, --page-width NUMBER          Page width with space. The default is 40.
  -o, --output FILE                Output to FILE
  -a, --add                        Only generate addition subject
  -s, --sub                        Only generate subtraction subject

Example:
  $ chmath -r 1-20 -f 5-8 -c 99

    EOF

    puts description
    exit
  end

end
