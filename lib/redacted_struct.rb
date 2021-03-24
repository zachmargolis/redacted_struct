# frozen_string_literal: true

# A subclass of Struct that can label members that should be redacted when printing
class RedactedStruct < Struct
  VERSION = "1.0.0"

  def self.new(*name_and_members, keyword_init: nil, redacted_members: [], &block)
    super(*name_and_members, keyword_init: keyword_init, &block).tap do |struct_class|
      struct_class.class_eval do
        @redacted_members = Array(redacted_members)
      end
    end
  end

  class << self
    attr_reader :redacted_members
  end

  def redacted_members
    self.class.redacted_members
  end

  def inspect
    name_or_nil = self.class.name ? " #{self.class.name}" : nil

    attributes = members.map do |member|
      if redacted_members.include?(member)
        "#{member}=[REDACTED]"
      else
        "#{member}=#{self[member].inspect}"
      end
    end.join(" ")

    "#<struct#{name_or_nil} #{attributes}>"
  end

  alias_method :to_s, :inspect
end
