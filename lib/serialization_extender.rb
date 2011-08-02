# encoding: utf-8
require 'serialization_extender/version'
require 'ruby_interface'
module SerializationExtender
  extend RubyInterface
  
  interface :serialization_extender do
    class_attribute :profiles
    self.profiles ||= {}
    def self.profile(name, options = {}, &blk)
      self.profiles = profiles.merge name => { :options => options, :blk => blk }
    end
    
    interfaced do
      alias_method_chain :serializable_hash, :extending
    end

    def apply(options = nil)
      options = options.dup if options
      profile = (options && options.delete(:profile)) || Thread.current["_serialization_profile"] || :default
      calculated_options, blk = get_params profile, options
      res = owner.serializable_hash_without_extending calculated_options
      blk ? owner.instance_exec(res, &blk) : res
    end
    
    protected
    def get_params(profile_name, options = nil)
      profile = self.profiles[profile_name]
      return [options, nil] unless profile
      [options_merge(options ? options : {}, profile[:options]), profile[:blk]]
    end
    
    def options_merge(o1, o2)
      o2.each do |k, v|
        case o1[k]
        when Hash
          o1[k] = options_merge o1[k], o2[k]
        when Array
          o1[k] += v
        else
          o1[k] = v
        end
      end
      o1
    end
    
  end
  
  def serializable_hash_with_extending(options = nil)
    serialization_extender.apply options
  end
end
