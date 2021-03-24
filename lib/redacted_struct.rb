# frozen_string_literal: true

# A subclass of Struct that redacts members by default, and can allow some to be printed
class RedactedStruct < Struct
  VERSION = "1.0.1"

  def self.new(*name_and_members, keyword_init: nil, allowed_members: [], &block)
    super(*name_and_members, keyword_init: keyword_init, &block).tap do |struct_class|
      struct_class.class_eval do
        @allowed_members = Array(allowed_members)
      end
    end
  end

  class << self
    attr_reader :allowed_members
  end

  def allowed_members
    self.class.allowed_members
  end

  def inspect
    name_or_nil = self.class.name ? " #{self.class.name}" : nil

    attributes = members.map do |member|
      if allowed_members.include?(member)
        "#{member}=#{self[member].inspect}"
      else
        "#{member}=[REDACTED]"
      end
    end.join(" ")

    "#<struct#{name_or_nil} #{attributes}>"
  end

  alias_method :to_s, :inspect
end
