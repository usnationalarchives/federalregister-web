module UserAgentHelper
  def ios?
    request.user_agent.match(/iPhone|iPad/)
  end
end
