class ApplicationDecorator < Draper::Base
  include ActionView::Helpers::TagHelper

  delegate :type, :to => :model

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

  #############
  # UTILITIES #
  #############

  def pluralize_without_count(count, word, plural=nil)
    count == 1 ? word : (plural ? plural : word.pluralize)
  end

  def wrap_in_dd(items)
    items.map{|item| content_tag(:dd, item) }.join("\n")
  end

end
