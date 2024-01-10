# frozen_string_literal: true

# rubocop:disable Style/Documentation
# rubocop:disable Style/MultilineIfModifier
# A subclass of Data that redacts members by default, and can allow some to be printed
class RedactedData < Data
  include Redactable

  def self.define(*members, allowed_members: [], &block)
    super(*members, &block).tap do |data_class|
      data_class.class_eval do
        @allowed_members = Array(allowed_members)
      end
    end
  end
end if defined?(Data)
# rubocop:enable Style/MultilineIfModifier
# rubocop:enable Style/Documentation
