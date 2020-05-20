# frozen_string_literal: true

require "chmath/version"
require 'opt_parse_validator'

module ChildrenMath
  class Error < StandardError;
  end

  class Runner

    attr_accessor :output_file
    attr_accessor :subject_count
    attr_accessor :limit_number

    def initialize(options)
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

    def initialize(result_number_min = 4, result_number_max = 20)
      @result_number_min = result_number_min
      @result_number_max = result_number_max
      @page_width = MAX_PAGE_WIDTH
      @subject_container = []
    end

    def make_subject(count = 99, first_number_range = 0)
      operation = make_subject_count_fill(count)

      # Mix in
      operation.shuffle!
      # p operation

      max_text_length = 0
      operation.map! do |e|
        case e
        when SUBJECT_TYPE_ADD
          # result_number = range(3, @result_number_max)
          # message = create_add_subject(result_number)
          message = create_add_subject(@result_number_min, @result_number_max)
        when SUBJECT_TYPE_SUB
          # result_number = range(0, @result_number_max)
          # message = create_sub_subject(result_number)
          message = create_sub_subject(@result_number_min, @result_number_max)
        else
          message = 'unsupport type'
        end
        max_text_length = message.length if message.length > max_text_length
        message
      end

      subject_format_output(operation, max_text_length)
    end

    def subject_format_output(subject, text_length, row_count = 3)
      horizon_space = (MAX_PAGE_WIDTH / row_count).floor
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
      puts outputs.join("\n")
    end

    def make_subject_count_fill(count = 50)
      half_count = (count / 2).floor
      operation = Array.new(half_count, SUBJECT_TYPE_ADD)
      # operation = Array.new(half_count, SUBJECT_TYPE_SUB)
      operation + Array.new(count - half_count, SUBJECT_TYPE_SUB)
    end

    def range(min = 1, max = 20)
      Random.new.rand(min..max)
    end

    # def create_add_subject(result_number = 20)
    def create_add_subject(res_num_min, res_num_max, first_num_min = 1, first_num_max = res_num_max)
      result_number = range(res_num_min, res_num_max)

      first_real_min = result_number > first_num_min ? first_num_min : result_number
      first_real_max = result_number > first_num_max ? first_num_max : result_number
      num1 = range(first_real_min, first_real_max)
      num2 = result_number - num1
      if num2 == 0
        # res_num_min = 0
        # res_num_max = 1


        # result_number = range(4, @result_number_max)
        # return create_add_subject(result_number)
      end
      subject_message = make_subject_string(num1, num2, ADD_CHAR)
      handle_subject_string(subject_message)
    end

    def create_sub_subject(res_num_min, res_num_max, first_num_min = 20)
      num1 = range(result_number, @result_number_max)
      num2 = num1 - result_number
      if num2 == 0
        # exclude same number
        recreate_result = result_number - 1 > 0 ? result_number - 1 : range(0, @result_number_max)
        create_sub_subject(recreate_result)
      else
        subject_message = make_subject_string(num1, num2, SUB_CHAR)
        handle_subject_string(subject_message)
      end
    end

    def check_number_duplicated?(message)
      return true if @subject_container.include?(message)
      false
    end

    def handle_subject_string(message)
      if check_number_duplicated?(message)
        @subject_container.delete(message)
        result_number = range(3, @result_number_max)
        message = create_sub_subject(result_number)
      end
      @subject_container.push(message)
      message
    end

    def make_subject_string(number1, number2, operator = ADD_CHAR)
      "#{number1} #{operator} #{number2} = "
    end
  end
end
