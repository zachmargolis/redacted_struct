# frozen_string_literal: true

RSpec.describe RedactedData do
  it "supports all the signatures of Data.define" do
    expect(RedactedData.define(:member).new(1)).to be

    data_class_with_block = RedactedData.define(:member) do
      def some_custom_method
        100
      end
    end

    expect(data_class_with_block.new(1).some_custom_method).to eq(100)
  end

  it "accepts allowed_members in all the signatures of Data.define" do
    expect(RedactedData.define(:member, allowed_members: [:member]).new(1)).to be

    data_class_with_block = RedactedData.define(:member, allowed_members: [:member]) do
      def some_custom_method
        100
      end
    end

    expect(data_class_with_block.new(1).some_custom_method).to eq(100)
  end

  let(:data_class) do
    RedactedData.define(
      :username,
      :password,
      :api_key,
      allowed_members: [:username],
    )
  end

  describe ".allowed_members" do
    it "is the list of redacted fields" do
      expect(data_class.allowed_members).to eq([:username])
    end
  end

  describe "#allowed_members" do
    it "is the list of redacted fields" do
      expect(instance.allowed_members).to eq([:username])
    end
  end

  let(:instance) do
    data_class.new(
      username: "example",
      password: "super secret",
      api_key: "123456",
    )
  end

  describe "#to_s" do
    it "redacts sensitive members" do
      expect(instance.to_s).to eq(
        '#<data username="example" password=[REDACTED] api_key=[REDACTED]>',
      )
    end
  end

  describe "#inspect" do
    it "redacts sensitive members" do
      expect(instance.to_s).to eq(
        '#<data username="example" password=[REDACTED] api_key=[REDACTED]>',
      )
    end
  end

  describe "#pp/#pretty_inspect" do
    require "pp"

    it "redacts when pretty printed" do
      io = StringIO.new

      PP.pp instance, io, 30

      # rubocop:disable Layout/TrailingWhitespace
      expect(io.string).to eq <<~STR
        #<data 
         username="example",
         password=[REDACTED],
         api_key=[REDACTED]>
      STR
      # rubocop:enable Layout/TrailingWhitespace
    end
  end
end
