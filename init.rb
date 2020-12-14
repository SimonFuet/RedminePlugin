Redmine::Plugin.register :ephesia_custom_tools do
  name 'Ephesia Custom Tools plugin'
  author 'Simon Fuet'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  menu :top_menu, :rtt_controller, {:controller => 'rtt_controller', :action => 'index' }, :caption => 'Mes RTTs'
end
