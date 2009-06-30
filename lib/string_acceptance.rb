module StringAcceptance
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def accepts_string_for(method, args = {})
      class_name = self.reflect_on_association(method).class_name
      method = method.to_s
      options = { :parent_method => "name", :create => true }.merge(args)
      options[:parent_method] = options[:parent_method].to_s
      
      str = "def #{method}_with_string_acceptance=(obj)
          if obj.is_a?(String)
            @errors_on_#{method} = false
            obj = #{class_name}.find_by_#{options[:parent_method]}(obj) " 
      if options[:create]
        str += "|| #{class_name}.create({:#{options[:parent_method]} => obj})"
      else
        str += "
               if obj.nil?
                 @errors_on_#{method} = true
               end"
      end
      str += <<-eos
          end
          self.#{method}_without_string_acceptance = obj
        end
        alias_method_chain :#{method}=, :string_acceptance
      eos
      if !options[:create]
        str += "
          validate :no_errors_on_#{method}
          def no_errors_on_#{method}
            if @errors_on_#{method}
              errors.add(:#{method} ,'#{class_name} not found!')
            end
          end"
      end
      class_eval str
    end
  end
end
