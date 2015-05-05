namespace :jshint do
  task :require do
    sh "which jshint" do |ok, res|
      fail 'Cannot find jshint on $PATH' unless ok
    end
  end

  task :check => 'jshint:require' do
    project_root = File.expand_path('../../', File.dirname(__FILE__))
    config_file = File.join(project_root, '.jshintrc')
    js_root_dir = File.join(project_root, 'app', 'assets', 'javascripts')

    files = Rake::FileList.new
    files.include File.join(js_root_dir, '**', '*.js')
    %w(
      tender_widget_custom.js
    ).each{|f| files.exclude(File.join(js_root_dir,f))}

    sh "jshint #{files.join(' ')} --config #{config_file}" do |ok, res|
      fail 'JSHint found errors.' unless ok
    end
  end
end

desc 'Run JSHint checks against Javascript source'
task :jshint => 'jshint:check'
