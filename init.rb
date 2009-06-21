require 'string_acceptance'
ActiveRecord::Base.class_eval { include StringAcceptance }
