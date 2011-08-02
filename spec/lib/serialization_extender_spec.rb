# encoding: utf-8
require 'spec_helper'
require 'active_model'

describe SerializationExtender do
  let(:klass) do
    Class.new do
      include ActiveModel::Serializers::JSON
      include SerializationExtender
      serialization_extender do
        profile :default, :methods => [:extended_foo]
      end
      attr_accessor :foo, :bar

      def attributes
        @attributes ||= { 'foo' => 'nil', 'bar' => 'nil' }
      end

      def self.name
        "Obj"
      end

      def extended_foo
        "extended foo"
      end
    end
  end

  let(:obj) { klass.new }

  it "should include `extended_foo` serialization result" do
    obj.as_json['obj'][:extended_foo].should eq("extended foo")
  end

  context "multiple profiles" do
    before do
      klass.serialization_extender.profile :short, :only => [:foo]
    end

    it "should serialize only `foo`" do
      obj.foo = "fee"
      obj.as_json(:profile => :short)['obj'].should eq({ "foo" => "fee" })
    end
  end

  context "with block" do
    before do
      klass.serialization_extender.profile :custom do |res|
        res.merge :custom => "cu"
      end
    end

    it "should add `custom`" do
      obj.foo = "fee"
      res = obj.as_json(:profile => :custom)['obj']
      res["foo"].should eq("fee")
      res[:custom].should eq("cu")
    end
  end

end
