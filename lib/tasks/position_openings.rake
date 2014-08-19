require 'net/ssh/proxy/http'

namespace :jobs do
  desc 'Download and import USAJobs XML file'
  task download_and_import_usajobs_xml: :environment do
    uri = URI(ENV['QUOTAGUARDSTATIC_URL'])
    proxy = Net::SSH::Proxy::HTTP.new(uri.host, uri.port, :user => uri.user, :password => uri.password)
    data = []
    Net::SFTP.start(ENV['OPM_HOST'], ENV['OPM_USER'], :password => ENV['OPM_PASSWORD'], :proxy => proxy) do |sftp|
      sftp.dir.foreach("Prod") do |entry|
        if entry.name.ends_with?(".xml")
          puts "Downloading: #{entry.name}"
          data << sftp.download!("Prod/#{entry.name}")
        end
      end
    end
    data.each_with_index do |data_import, index|
      tempfile = Tempfile.new("import_#{index}")
      tempfile.write(data_import)
      tempfile.rewind
      UsajobsData.new(tempfile.path).import
    end
  end
  
  desc 'Import USAJobs XML file'
  task :import_usajobs_xml, [:filename] => :environment do |t, args|
    if args.filename.nil?
      puts 'usage: rake jobs:import_usajobs_xml[filename.xml]'
    else
      importer = UsajobsData.new(args.filename)
      importer.import
    end
  end
  
  desc 'Import NLX data feeds'
  task :import_nlx_data_feed, [:url, :source, :organization_id, :organization_name] => :environment do |t, args|
    if args.url.nil? || args.source.nil? || args.organization_id.nil? || args.organization_name.nil?
      puts 'usage: rake jobs:import_nlx_data_feed[url, source, organization_id, organization_name]'
    else
      response = HTTParty.get(args.url)
      if response.code == 200
        importer = NlxData.new(response.body, args.source, args.organization_id, args.organization_name)
        importer.import
      end
    end
  end

  desc 'Import Neogov YAML file containing agency info'
  task :import_neogov_rss, [:yaml_filename] => :environment do |t, args|
    begin
      YAML.load(File.read(args.yaml_filename)).each do |config|
        agency, details = config
        tags, organization_id, organization_name = details['tags'], details['organization_id'], details['organization_name']
        if agency.blank? or tags.blank? or organization_id.blank?
          puts 'Agency, tags, and organization ID are required for each record. Skipping record....'
        else
          importer = NeogovData.new(agency, tags, organization_id, organization_name)
          importer.import
          puts "Imported jobs for #{agency} at #{Time.now}"
        end
      end
    rescue Exception => e
      puts "Trouble running import script: #{e}"
      puts e.backtrace
      puts '-'*80
      puts "usage: rake jobs:import_neogov_rss[yaml_filename]"
      puts "Example YAML file syntax:"
      puts "bloomingtonmn:"
      puts "\ttags: city tag_2"
      puts "\torganization_id: US-MN:CITY-BLOOMINGTON"
      puts "\torganization_name: City of Bloomington"
      puts "ohio:"
      puts "\ttags: state tag_3"
      puts "\torganization_id: US-OH"
    end
  end

  desc 'Recreate position openings index'
  task recreate_index: :environment do
    PositionOpening.delete_search_index if PositionOpening.search_index.exists?
    PositionOpening.create_search_index
  end
end