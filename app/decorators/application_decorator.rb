class ApplicationDecorator < Draper::Base
 def self.decorate_methods(*method_names)
   options = method_names.extract_options!
   decorator = options.delete(:with) || raise("Must pass a decorator class using :with")

   method_names.each do |method_name|
     define_method method_name do |*args, &blk|
       results = model.send(method_name, *args, &blk)
       decorator.decorate(results)
     end
   end
 end
end
