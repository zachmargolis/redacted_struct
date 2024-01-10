# frozen_string_literal: true

# Class methods for the Redactable module. When Redactable is included in class that class is
# extended with these instance methods.
module RedactableClassMethods
  attr_reader :allowed_members
end

# A module that adds redacted functionality to a class
module Redactable
  def self.included(mod)
    mod.extend RedactableClassMethods
  end

  def inspect
    name_or_nil = self.class.name ? " #{self.class.name}" : nil

    attributes = members.map do |member|
      if allowed_members.include?(member)
        "#{member}=#{send(member).inspect}"
      else
        "#{member}=[REDACTED]"
      end
    end.join(" ")

    "#<#{base_name_for_inspection}#{name_or_nil} #{attributes}>"
  end

  def allowed_members
    self.class.allowed_members
  end

  # Overrides for pp
  # See https://github.com/ruby/pp/blob/3d925b5688b8226f653127d990a8dce48bced5fe/lib/pp.rb#L379-L391
  # rubocop:disable all
  def pretty_print(q)
    q.group(1, sprintf("#<struct %s", PP.mcall(self, Kernel, :class).name), '>') {
      q.seplist(PP.mcall(self, base_type_for_pp, :members), lambda { q.text "," }) {|member|
        q.breakable
        q.text member.to_s
        q.text '='
        q.group(1) {
          q.breakable ''
          if allowed_members.include?(member)
            q.pp self[member]
          else
            q.text "[REDACTED]"
          end
        }
      }
    }
  end
  # rubocop:enable all

  alias_method :to_s, :inspect

  def base_name_for_inspection
    if is_a? Struct
      "struct"
    elsif is_a? Data
      "data"
    end
  end

  def base_type_for_pp
    if is_a? Struct
      Struct
    elsif is_a? Data
      Data
    end
  end
end

# A subclass of Struct that redacts members by default, and can allow some to be printed
class RedactedStruct < Struct
  include Redactable

  VERSION = "1.1.0"

  def self.new(*name_and_members, keyword_init: nil, allowed_members: [], &block)
    super(*name_and_members, keyword_init: keyword_init, &block).tap do |struct_class|
      struct_class.class_eval do
        @allowed_members = Array(allowed_members)
      end
    end
  end
end

# rubocop:disable Style/MultilineIfModifier
# A sublcass of Data that redacts members by default, and can allow some to be printed
class RedactedData < Data
  include Redactable

  def self.define(*members, allowed_members: [], &block)
    super(*members, &block).tap do |data_class|
      data_class.class_eval do
        @allowed_members = Array(allowed_members)
      end
    end
  end

  # Overrides for pp
  # See https://github.com/ruby/pp/blob/3d925b5688b8226f653127d990a8dce48bced5fe/lib/pp.rb#L379-L391
  # rubocop:disable all
  def pretty_print(q)
    q.group(1, sprintf("#<data %s", PP.mcall(self, Kernel, :class).name), '>') {
      q.seplist(PP.mcall(self, Data, :members), lambda { q.text "," }) {|member|
        q.breakable
        q.text member.to_s
        q.text '='
        q.group(1) {
          q.breakable ''
          if allowed_members.include?(member)
            q.pp self.send(member)
          else
            q.text "[REDACTED]"
          end
        }
      }
    }
  end
  # rubocop:enable all
end if defined?(Data)
# rubocop:enable Style/MultilineIfModifier
