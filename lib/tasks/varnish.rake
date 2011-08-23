namespace :varnish do
  namespace :config do
    desc "Regenerate varnish config"
    task :generate do
      File.open(File.join(Rails.root, 'config', 'varnish.vcl'), 'w') do |f|
        template_content = IO.read(File.join(Rails.root, 'config', 'varnish.vcl.erb'))
        yml_path = File.join(Rails.root, 'config', 'varnish.yml')
        
        config = {
          'my_fr2' => {'port' => 3000, 'host' => '127.0.0.1', 'hostname' => 'my-fr2.local'},
          'fr2' =>    {'port' => 80,   'host' => 'www.federalregister.gov', 'hostname' => 'www.federalregister.gov'}
        }
        
        if File.exists?(yml_path)
          config.deep_merge!(YAML::load_file(yml_path))
        end
        f.write ERB.new(template_content).result(binding)
      end
    end
  end
  
  desc "Start varnish, recompiling config if necessary"
  task :start => 'varnish:config:generate' do
    port = ENV['PORT'] || 8080
    sh "varnishd -f config/varnish.vcl -a 0.0.0.0:#{port} -s malloc,10M -T 127.0.0.1:6082"
    puts "please visit http://scc.local:#{port}/"
  end
  
  desc "Stop varnish"
  task :stop do
    sh "killall varnishd"
    puts "varnish shutting down..."
  end

  desc "Restart varnish"
  task :restart => [:stop, :start]
end
