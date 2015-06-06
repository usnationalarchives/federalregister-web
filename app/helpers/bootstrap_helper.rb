module BootstrapHelper
  def bootstrap_context_wrapper(&block)
    render partial: 'special/helpers/bootstrap_context_wrapper',
      locals: {content: capture(&block)}
  end

  def bootstrap_col(args)
    args.map{|k,v| "col-#{k}-#{v}" }.join(' ')
  end
end
