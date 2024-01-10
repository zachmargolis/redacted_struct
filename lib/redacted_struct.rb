# frozen_string_literal: true

require_relative "./redactable"
require_relative "./redacted_data"

# A subclass of Struct that redacts members by default, and can allow some to be printed
class RedactedStruct < Struct
  include Redactable

  VERSION = "2.0.0"

  def self.new(*name_and_members, keyword_init: nil, allowed_members: [], &block)
    super(*name_and_members, keyword_init: keyword_init, &block).tap do |struct_class|
      struct_class.class_eval do
        @allowed_members = Array(allowed_members)
      end
    end
  end
end
