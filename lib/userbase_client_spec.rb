# encoding: utf-8
require 'spec_helper'

describe UserbaseClient do
  it "должен устанавливаться хост" do
    UserbaseClient.config.host = 'example.com'
    UserbaseClient.config.host.should == 'example.com'
  end

  it "должен присутствовать хост по умолчанию" do
    UserbaseClient.config.host.should_not be_empty
  end

  it "конфигурация должна происзводиться через блок" do
    UserbaseClient.config do |config|
      config.host = "example3.com"
    end
    UserbaseClient.config.host.should == 'example3.com'
  end

  it "конфигурация должна происзводиться через блок после простой конфигурации" do
    UserbaseClient.config.host = 'example.com'
    UserbaseClient.config do |config|
      config.host = "example4.com"
    end
    UserbaseClient.config.host.should == 'example4.com'
  end
end
