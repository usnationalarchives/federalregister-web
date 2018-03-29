module UserAgentHelper
  def iphone?
    request.user_agent.match(/iPhone/)
  end
end
