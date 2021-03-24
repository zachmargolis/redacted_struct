# frozen_string_literal: true

RSpec.describe RedactedStruct do
  it "has a version number" do
    expect(RedactedStruct::VERSION).not_to be nil
  end

  describe ".new" do
    it "supports all the signatures of Struct.new" do
      expect(RedactedStruct.new(:member).new(1)).to be
      expect(RedactedStruct.new(:member, keyword_init: true).new(member: 1)).to be
      expect(RedactedStruct.new("SomeClass", :member).new(1)).to be
      expect(RedactedStruct.new("SomeOtherClass", :member, keyword_init: true).new(member: 1)).to be

      struct_class_with_block = RedactedStruct.new(:member) do
        def some_custom_method
          100
        end
      end

      expect(struct_class_with_block.new(1).some_custom_method).to eq(100)
    end

    it "accepts redacted_members in all the signatures of Struct.new" do
      expect(RedactedStruct.new(:member, redacted_members: [:member]).new(1)).to be
      expect(
        RedactedStruct.new(:member, keyword_init: true, redacted_members: [:member]).new(member: 1),
      ).to be
      expect(RedactedStruct.new("AnotherClass", :member, redacted_members: [:member]).new(1)).to be
      expect(
        RedactedStruct.new(
          "AnotherOtherClass",
          :member,
          keyword_init: true,
          redacted_members: [:member],
        ).new(member: 1),
      ).to be

      struct_class_with_block = RedactedStruct.new(:member, redacted_members: [:member]) do
        def some_custom_method
          100
        end
      end

      expect(struct_class_with_block.new(1).some_custom_method).to eq(100)
    end
  end

  let(:struct_class) do
    RedactedStruct.new(
      :username,
      :password,
      :api_key,
      keyword_init: true,
      redacted_members: [:password, :api_key],
    )
  end

  let(:named_struct_class) do
  end

  describe ".redacted_members" do
    it "is the list of redacted fields" do
      expect(struct_class.redacted_members).to eq([:password, :api_key])
    end
  end

  describe "#redacted_members" do
    it "is the list of redacted fields" do
      expect(instance.redacted_members).to eq([:password, :api_key])
    end
  end

  let(:instance) do
    struct_class.new(
      username: "example",
      password: "super secret",
      api_key: "123456",
    )
  end

  describe "#to_s" do
    it "redacts sensitive members" do
      expect(instance.to_s).to eq(
        '#<struct username="example" password=[REDACTED] api_key=[REDACTED]>',
      )
    end

    it "redacts sensitive members in named structs" do
      named_instance = RedactedStruct.new(
        "MyCustomConfig",
        :uuid,
        :session_secret,
        keyword_init: true,
        redacted_members: [:session_secret],
      ).new(uuid: "abcdef", session_secret: "secret")

      expect(named_instance.to_s).to eq(
        '#<struct RedactedStruct::MyCustomConfig uuid="abcdef" session_secret=[REDACTED]>',
      )
    end
  end

  describe "#inspect" do
    it "redacts sensitive members" do
      expect(instance.to_s).to eq(
        '#<struct username="example" password=[REDACTED] api_key=[REDACTED]>',
      )
    end

    it "redacts sensitive members in named structs" do
      named_instance = RedactedStruct.new(
        "MyCustomConfigAgain",
        :uuid,
        :session_secret,
        keyword_init: true,
        redacted_members: [:session_secret],
      ).new(uuid: "abcdef", session_secret: "secret")

      expect(named_instance.to_s).to eq(
        '#<struct RedactedStruct::MyCustomConfigAgain uuid="abcdef" session_secret=[REDACTED]>',
      )
    end
  end
end
