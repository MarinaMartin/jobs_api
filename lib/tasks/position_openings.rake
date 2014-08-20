namespace :jobs do
  desc 'Import USAJobs XML file'
  task :import_usajobs_xml, [:filename] => :environment do |t, args|
    if args.filename.nil?
      puts 'usage: rake jobs:import_usajobs_xml[filename.xml]'
    else
      importer = UsajobsData.new(args.filename)
      importer.import
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
  
  desc 'Import Schema.org urls from Employment Center'
  task :import_employment_center_schema_dot_org_urls => :environment do
    response = HTTParty.get(ENV['EMPLOYMENT_CENTER_API_BASE_URL'] + "/api/employers")
    if response.code == 200
      parsed_response = JSON.parse(response.body)
      schema_dot_org_data = SchemaDotOrgData.new
      parsed_response.each do |employer|
        employer_response = HTTParty.get(employer['url'])
        schema_dot_org_data.import(employer_response.body, employer['company_name'] || "Schema.org") if employer_response.code == 200
      end
    end
  end

  desc 'Recreate position openings index'
  task recreate_index: :environment do
    PositionOpening.delete_search_index if PositionOpening.search_index.exists?
    PositionOpening.create_search_index
  end
end