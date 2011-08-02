# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe UserbaseClient::User do
  before(:each) do
    @host = UserbaseClient.config.host
    @params = {'login' => "nick"}
    @guid = "GUID"
  end

  shared_examples_for "стандартный успешный ответ" do
    it "результат метода должен быть хешом" do
      stub_request(:any, @path).to_return(:body => "{}")
      @request.call.should be_instance_of(Hash)
    end
  end

  shared_examples_for "стандартный неуспешный ответ" do
    it "должен поднимать UserbaseClient::RecordNotFound при коде ответа 404" do
      stub_request(:any, @path).to_return(:status => 404)
      @request.should raise_error(UserbaseClient::RecordNotFound)
    end

    it "должен поднимать UserbaseClient::BadRequestError при коде ответа 400" do
      stub_request(:any, @path).to_return(:status => 400)
      @request.should raise_error(UserbaseClient::BadRequestError)
    end

    it "должен поднимать UserbaseClient::ConnectionError при коде ответа 500" do
      stub_request(:any, @path).to_return(:status => 500)
      @request.should raise_error(UserbaseClient::ConnectionError)
    end

    it "должен поднимать UserbaseClient::ConnectionError при таймауте" do
      stub_request(:any, @path).to_timeout
      @request.should raise_error(UserbaseClient::ConnectionError)
    end
  end

  describe ".create" do
    before(:each) do
      @path = "http://" + @host + "/v1/users.json"
      stub_request(:any, @path).to_return(:body => "{}")
      @request = lambda {UserbaseClient::User.create @params }
      @result = @request.call
    end

    it_should_behave_like "стандартный успешный ответ"
    it_should_behave_like "стандартный неуспешный ответ"

    it "должен запрашиваться /v1/users.json через POST" do
      WebMock.should have_requested(:post, @path)
    end

    it "передаваемые параметры должны попадать в запрос" do
      WebMock.should have_requested(:post, @path).with(:body => @params)
    end
  end

  describe ".update" do
    before(:each) do
      @path = "http://" + @host + "/v1/users/#{@guid}/attributes.json"
      stub_request(:any, @path).to_return(:body => "{}")
      @request = lambda { UserbaseClient::User.update @guid, @params }
      @result = @request.call
    end

    it_should_behave_like "стандартный успешный ответ"
    it_should_behave_like "стандартный неуспешный ответ"
    
    it "должен запрашиваться /v1/users/GUID/attributes.json через POST" do
      WebMock.should have_requested(:put, @path)
    end

    it "передаваемые параметры должны попадать в запрос" do
      WebMock.should have_requested(:put, @path).with(:body => @params)
    end
  end

  describe ".find_by_guid" do
    before(:each) do
      @path = "http://" + @host + "/v1/users/#{@guid}.json"
      @request = lambda { UserbaseClient::User.find_by_guid @guid }
    end
    
    it_should_behave_like "стандартный успешный ответ"
    it_should_behave_like "стандартный неуспешный ответ"

    context "успешный запрос" do
      before(:each) do
        stub_request(:any, @path).to_return(:body => Yajl::Encoder.encode(@params))
        @result = @request.call
      end
  
      it "должен запрашиваться /v1/users/GUID.json через GET" do
        WebMock.should have_requested(:get, @path)
      end
  
      it "должен возвращать распарсенные параметры ответа" do
        @result.should == @params
      end
    end
  end

  describe ".destroy" do
    before(:each) do
      @path = "http://" + @host + "/v1/users/#{@guid}.json"
      stub_request(:any, @path).to_return(:body => "{}")
      @request = lambda { UserbaseClient::User.destroy @guid }
      @result = @request.call
    end

    it_should_behave_like "стандартный успешный ответ"
    it_should_behave_like "стандартный неуспешный ответ"
    
    it "должен запрашиваться /v1/users/GUID.json через DELETE" do
      WebMock.should have_requested(:delete, @path)
    end
  end

  describe ".find_attribute" do
    before(:each) do
      @path = "http://" + @host + "/v1/users/#{@guid}/attributes/#{@params.keys.first}.json"
      stub_request(:any, @path).to_return(:body => Yajl::Encoder.encode(@params))
      @request = lambda { UserbaseClient::User.find_attribute @guid, @params.keys.first }
      @result = @request.call
    end

    it_should_behave_like "стандартный неуспешный ответ"
    
    it "должен запрашиваться /v1/users/GUID/attributes/ATTRIBUTE.json через GET" do
      WebMock.should have_requested(:get, @path)
    end

    it "должен возвращать распарсенные параметры ответа" do
      @result.should == @params[@params.keys.first]
    end
  end
  
  describe ".find_attributes" do
    before(:each) do
      @params = {"login" => "my_login", "name" => "Nick"}
      @path = "http://" + @host + "/v1/users/#{@guid}.json?" + {:attrs => @params.keys}.to_param
      stub_request(:any, @path).to_return(:body => Yajl::Encoder.encode(@params))
      @request = lambda { UserbaseClient::User.find_attributes @guid, @params.keys }
    end
    
    context "с выполненным запросом" do
      before(:each) do
        @result = @request.call
      end

      it_should_behave_like "стандартный неуспешный ответ"
      
      it "должен возвращать распарсенные параметры ответа" do
        @result.should include(@params)
      end
    end

    it "должен запрашиваться /v1/users/GUID.json через GET" do
      stub_request(:any, @path).to_return(:body => Yajl::Encoder.encode(@params))
      @result = @request.call
      WebMock.should have_requested(:get, @path)
    end
  end

  describe ".destroy_attributes" do
    context "один атрибут" do
      before(:each) do
        @path = "http://" + @host + "/v1/users/#{@guid}/attributes.json?" + {:attrs => [@params.keys.first]}.to_param
        stub_request(:any, @path).to_return(:body => "{}")
        @request = lambda { UserbaseClient::User.destroy_attributes @guid, @params.keys.first }
        @result = @request.call
      end
  
      it_should_behave_like "стандартный успешный ответ"
      it_should_behave_like "стандартный неуспешный ответ"
      
      it "должен запрашиваться /v1/users/GUID/attributes.json через DELETE" do
        WebMock.should have_requested(:delete, @path)
      end
    end
    
    context "несколько атрибутов" do
      before(:each) do
        @path = "http://" + @host + "/v1/users/#{@guid}/attributes.json?" + {:attrs => @params.keys}.to_param
        stub_request(:any, @path).to_return(:body => "{}")
        @request = lambda { UserbaseClient::User.destroy_attributes @guid, @params.keys }
        @result = @request.call
      end
  
      it_should_behave_like "стандартный успешный ответ"
      it_should_behave_like "стандартный неуспешный ответ"
      
      it "должен запрашиваться /v1/users/GUID/attributes.json через DELETE" do
        WebMock.should have_requested(:delete, @path).with(:attrs => @params.keys.first)
      end
    end
  end
  
  describe ".authenticate" do
    before(:each) do
      @path = "http://" + @host + "/v1/sessions.json"
      stub_request(:any, @path).to_return(:body => Yajl::Encoder.encode({:guid => @guid}), :content_type => 'application/json')
    end

    context "без указания атрибутов" do
      before(:each) do
        @request = lambda { UserbaseClient::User.authenticate @params.values.first, "pass" }
      end

      it "не должен поднимать ошибок" do
        @request.should_not raise_error
      end

      it "должен отправлять POST запрос с логином и паролем" do
        @request.call
        WebMock.should have_requested(:post, @path).with(:body =>  @params.merge('password' => 'pass'))
      end
    end

    context "с указанием параметров" do
      before(:each) do
        @request = lambda { UserbaseClient::User.authenticate @params.values.first, "pass", ["guid", "login"] }
        @result = @request.call
      end
  
      it_should_behave_like "стандартный неуспешный ответ"
      
      it "должен запрашиваться /v1/sessions.json через POST" do
        WebMock.should have_requested(:post, @path)
      end
  
      it "передаваемые параметры должны попадать в запрос" do
        WebMock.should have_requested(:post, @path).with(:body => @params.merge('password' => 'pass', 'attrs' => ['guid', 'login']))
      end
  
      it "должен возвращать GUID при наличии guid в ответе" do
        @result.should be_true
      end
  
      it "должен возвращать false при статусе ответа 401" do
        stub_request(:any, @path).to_return(:status => 401)
        @request.call.should be_false
      end
    end
  end
end
