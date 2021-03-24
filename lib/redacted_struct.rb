# frozen_string_literal: true

# A subclass of Struct that redacts members by default, and can allow some to be printed
class RedactedStruct < Struct
  VERSION = "1.1.0"

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

  # Overrides for pp
  # See https://github.com/ruby/pp/blob/3d925b5688b8226f653127d990a8dce48bced5fe/lib/pp.rb#L379-L391
  # rubocop:disable all
  def pretty_print(q)
    q.group(1, sprintf("#<struct %s", PP.mcall(self, Kernel, :class).name), '>') {
      q.seplist(PP.mcall(self, Struct, :members), lambda { q.text "," }) {|member|
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
end
