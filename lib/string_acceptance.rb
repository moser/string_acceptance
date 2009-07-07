module StringAcceptance
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    #grumpf... I should refactor it (TODO)
    def accepts_string_for(method, args = {})
      class_name = self.reflect_on_association(method).class_name
      method = method.to_s
      options = { :parent_method => "name", :create => true, :ignore_case => true, :may_nil => true }.merge(args)
      if options[:parent_method].is_a?(Array)  && options[:parent_method].size > 1
        options[:parent_method].map! { |m| m.to_s }
        options[:create] = false #can't create when we don't know where the string should go => could default to first element in the array
        if options[:ignore_case]
          finder = "#{class_name}.find(:first, :conditions => [ '#{ (options[:parent_method].collect { |m| "LOWER(#{m}) = ?" }).join(' OR ') }', "+
                                                                "#{ (['obj.downcase'] * options[:parent_method].size).join(', ') } ])"
        else
          finder = "#{class_name}.find(:first, :conditions => [ '#{ (options[:parent_method].collect { |m| "#{m} = ?" }).join(' OR ') }', "+
                                                                "#{ (['obj'] * options[:parent_method].size).join(', ') } ])"
        end
      else
        options[:parent_method] = options[:parent_method].to_s
        if options[:ignore_case]
          finder = "#{class_name}.find(:first, :conditions => ['LOWER(#{options[:parent_method]}) = ?', obj.downcase]) "
        else
          finder = "#{class_name}.find_by_#{options[:parent_method]}(obj) "
        end
      end
      
      str = "def #{method}_with_string_acceptance=(obj)
          if obj.is_a?(String)
            @errors_on_#{method} = false
            obj = #{finder} " 
      if options[:create]
        str += "|| #{class_name}.create({:#{options[:parent_method]} => obj})"
      elsif options[:may_nil]
        str += "
               if obj.nil?
                 @errors_on_#{method} = true
               end"
      else #may_nil => false
        str += "
               if obj.nil?
                 obj = self.#{method}
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
