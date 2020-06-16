# frozen_string_literal: true

require "chmath/version"
require 'usage'
require 'opt_parse_validator'

module ChildrenMath
  class Error < StandardError;
  end

  class Runner
    def initialize
      start_time = Time.now

      begin
        parsed_cli_options = OptParseValidator::OptParser.new.add(
          OptParseValidator::OptIntegerRange.new(['-r',
                                                  '--result-number NUMBER-Range',
                                                  '[Require] Range of result number.'], required: true),
          OptParseValidator::OptIntegerRange.new(['-f',
                                                  '--first-number NUMBER-Range',
                                                  'Range of first number. The default number is result number min to result number max.']),
          OptParseValidator::OptInteger.new(['-c', '--count NUMBER', 'Count of subject number. The default count is 99.'], default: 99),
          OptParseValidator::OptInteger.new(['-w', '--page-width NUMBER', 'Page width with space. The default is 40.'], default: 40),
          OptParseValidator::OptFilePath.new(['-o', '--output FILE', 'Output to FILE'], writable: true, exists: false),
          OptParseValidator::OptBoolean.new(['-a', '--add', 'Only generate addition subject.']),
          OptParseValidator::OptBoolean.new(['-s', '--sub', 'Only generate subtraction subject.']),
          OptParseValidator::OptBoolean.new(['-i', '--info', 'Debug info.']),
        ).results

        ChildrenMath.usage if parsed_cli_options.empty?

        handle_subject(parsed_cli_options)

      rescue OptParseValidator::Error => e
        puts 'Parsing Error: ' + e.message
        ChildrenMath.usage
      end

      end_time = Time.now
      puts "Cost time: #{end_time - start_time}(S)" unless parsed_cli_options[:info].nil?
    end

    def handle_subject(options)
      p options unless options[:info].nil?

      result = options[:result_number]
      page_width = options[:page_width]
      teacher = Teacher.new(result.begin, result.end, page_width)
      create_subject(teacher, options)
    end

    def create_subject(teacher, opt)
      result = opt[:result_number]
      first = opt[:first_number].nil? ? result.begin..result.end : opt[:first_number]
      add_flag = opt[:add].nil? ? false : true
      sub_flag = opt[:sub].nil? ? false : true
      count = opt[:count]
      output = opt[:output]

      content = ''
      if (add_flag and sub_flag) or (!add_flag and !sub_flag)
        content = teacher.make_subject_mix(count, first.begin, first.end)
      elsif add_flag
        content = teacher.make_subject_add(count, first.begin, first.end)
      elsif sub_flag
        content = teacher.make_subject_sub(count, first.begin, first.end)
      else
        puts "None support subject."
      end

      if output.nil?
        puts content
      else
        teacher.write_file(content, output)
      end
    end

  end

  class Teacher
    SUBJECT_TYPE_ADD = 1
    SUBJECT_TYPE_SUB = 2

    MAX_PAGE_WIDTH = 40

    ADD_CHAR = '+'
    SUB_CHAR = '-'

    attr_accessor :result_number_max
    attr_accessor :result_number_min

    attr_accessor :first_number_max
    attr_accessor :first_number_min
    attr_accessor :second_number_max
    attr_accessor :second_number_min

    attr_accessor :page_width
    attr_accessor :subject_container

    # Initialize teacher job
    # @param The min result number
    # @param The max result number
    #
    def initialize(result_number_min = 4, result_number_max = 20, page_width = MAX_PAGE_WIDTH)
      @result_number_min = result_number_min
      @result_number_max = result_number_max
      @result_number_max = @result_number_min if @result_number_min > @result_number_max

      @page_width = page_width
      @subject_container = []
    end

    # Create addition subjects.
    # @param The count of subjects
    # @param The min first number
    # @param The max first number
    #
    # @return Subject text
    def make_subject_add(count = 99, first_num_min = 1, first_num_max = @result_number_max)
      operation = Array.new(count, SUBJECT_TYPE_ADD)
      max_text_length = 0
      operation.map! do
        message = create_add_subject(@result_number_min, @result_number_max, first_num_min, first_num_max)
        max_text_length = message.length if message.length > max_text_length
        message
      end
      subjects = subject_format(operation, max_text_length)
      subjects
    end

    # Create subtraction subjects.
    # @param The count of subjects
    # @param The min first number
    # @param The max first number
    #
    # @return Subject text
    def make_subject_sub(count = 99, first_num_min = 1, first_num_max = @result_number_max)
      operation = Array.new(count, SUBJECT_TYPE_SUB)
      max_text_length = 0
      operation.map! do
        message = create_sub_subject(@result_number_min, @result_number_max, first_num_min, first_num_max)
        max_text_length = message.length if message.length > max_text_length
        message
      end
      subject_format(operation, max_text_length)
    end

    def make_subject_mix(count = 99, first_num_min = 1, first_num_max = @result_number_max)
      operation = make_addsub_subject_count_fill(count)
      # Mix in
      operation.shuffle!

      max_text_length = 0
      operation.map! do |e|
        case e
        when SUBJECT_TYPE_ADD
          message = create_add_subject(@result_number_min, @result_number_max, first_num_min, first_num_max)
        when SUBJECT_TYPE_SUB
          message = create_sub_subject(@result_number_min, @result_number_max, first_num_min, first_num_max)
        else
          message = 'None-Support Type'
        end

        max_text_length = message.length if message.length > max_text_length
        message
      end

      subject_format(operation, max_text_length)
    end

    def subject_format(subject, text_length, row_count = 3)
      horizon_space = (@page_width / row_count).floor
      outputs = []
      message = ''
      subject.each_with_index do |sub, i|
        lead_space_length = text_length - sub.length
        message += (' ' * lead_space_length) + sub
        if (i + 1) % row_count != 0
          message += ' ' * horizon_space
        else
          outputs.push(message)
          message = ''
        end
      end
      outputs.join("\n")
    end

    def make_addsub_subject_count_fill(count = 50)
      half_count = (count / 2).floor
      operation = Array.new(half_count, SUBJECT_TYPE_ADD)
      operation + Array.new(count - half_count, SUBJECT_TYPE_SUB)
    end

    def range(min = 1, max = 20)
      Random.new.rand(min..max)
    end

    def create_add_subject(res_num_min, res_num_max, first_num_min = 1, first_num_max = res_num_max)
      result_number = range(res_num_min, res_num_max)

      first_real_min = result_number > first_num_min ? first_num_min : result_number
      first_real_max = result_number > first_num_max ? first_num_max : result_number
      first_real_max = first_real_min if first_real_min > first_real_max

      # if result_number > first_num_min or result_number > first_num_max
      # puts "Hit the bad number of first number.\nSet first min : #{first_real_min}, max : #{first_real_max}"
      # end

      num1 = range(first_real_min, first_real_max)
      num2 = result_number - num1
      if num2 == 0 and res_num_min != res_num_max
        # puts '-' * 20 + "res : #{res_num_min}, #{res_num_max}"
        # puts '-' * 20 + "first : #{first_real_min}, #{first_real_max}"
        return create_add_subject(res_num_min, res_num_max, first_real_min, first_real_max)
      end
      subject_message = make_subject_string(num1, num2, ADD_CHAR)
      handle_subject_string(subject_message)
    end

    def create_sub_subject(res_num_min, res_num_max, first_num_min = res_num_min, first_num_max = res_num_max)
      result_number = range(res_num_min, res_num_max)

      # fix first number as sub
      first_real_min = first_num_min < result_number ? result_number : first_num_min
      first_real_max = first_num_max < result_number ? result_number : first_num_max
      first_real_min = first_real_max if first_real_min > first_real_max

      num1 = range(first_real_min, first_real_max)
      num2 = num1 - result_number
      if num2 == 0 and res_num_min != res_num_max
        # exclude same number
        return create_sub_subject(res_num_min, res_num_max, first_real_min, first_real_max)
      end
      subject_message = make_subject_string(num1, num2, SUB_CHAR)
      handle_subject_string(subject_message)
    end

    def check_number_duplicated?(message)
      return true if @subject_container.include?(message)
      false
    end

    def handle_subject_string(message)
      @subject_container.push(message)
      message
    end

    def make_subject_string(number1, number2, operator = ADD_CHAR)
      "#{number1} #{operator} #{number2} = "
    end

    def write_file(content, file_path = 'subject.txt')

      File.open(file_path, 'w') do |f|
        f.write(content)
      end
    end
  end
end
