# frozen_string_literal: true

# A module that adds redacted functionality to a class
module Redactable
  def self.included(mod)
    class << mod
      attr_reader :allowed_members
    end
  end

  def inspect
    name_or_nil = self.class.name ? " #{self.class.name}" : nil

    members_h = to_h
    attributes = members.map do |member|
      if allowed_members.include?(member)
        "#{member}=#{members_h[member].inspect}"
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
    q.group(1, sprintf("#<%s %s", base_name_for_inspection, PP.mcall(self, Kernel, :class).name), '>') {
      members_h = to_h
      q.seplist(PP.mcall(self, base_type_for_pp, :members), lambda { q.text "," }) {|member|
        q.breakable
        q.text member.to_s
        q.text '='
        q.group(1) {
          q.breakable ''
          if allowed_members.include?(member)
            q.pp members_h[member]
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
    else
      "data"
    end
  end

  def base_type_for_pp
    if is_a? Struct
      Struct
    else
      Data
    end
  end
end
