class SchemaDotOrgJsonData
  include JobImporter
  
  def initialize(json, source)
    @json = json
    @source = source
  end
  
  def import
    parsed_json = JSON.parse(@json)
    position_openings = parsed_json.collect do |job|
      process_job(job)
    end.compact
    PositionOpening.import position_openings
  end
  
  def process_job(job)
    published_at = DateTime.parse(job['datePosted']) if job['datePosted']
    start_date = published_at ? published_at.to_date : Date.current
    end_date = start_date + 30.days
    days_remaining = (end_date - Date.current).to_i
    inactive = false
    days_remaining = 0 if days_remaining < 0 || start_date > end_date || inactive
    entry = {type: 'position_opening', source: @source, tags: %w(private)}
    entry[:external_id] = nil
    entry[:locations] = process_locations(job)
    if entry[:locations]
      entry[:locations] = [] if entry[:locations].size >= CATCHALL_THRESHOLD
      entry[:_ttl] = (days_remaining.zero? || entry[:locations].empty?) ? '1s' : "#{days_remaining}d"
      unless entry[:_ttl] == '1s'
        entry[:position_title] = job['title']
        entry[:organization_id] = process_organization(job) || @source.downcase.gsub(/ /, "_")
        entry[:organization_name] = process_organization_name(job)|| @source 
        entry[:start_date] = start_date
        entry[:end_date] = end_date
        entry[:url] = job['url'] 
      end
      entry
    end
  end

  def process_locations(job)
    job_location = job['jobLocation']
    if job_location
       city = job_location['address']['addressLocality'] unless ! job_location['address']
       state = job_location['address']['addressRegion'] unless ! job_location['address']
        [{city: city, state: state}]
    end
  end

  def process_organization(job)
    job_hiring_organization = job['hiringOrganization']
    if job_hiring_organization
      hiring_organization = (job['hiringOrganization']['name'] || job['hiringOrganization']['legalName'] || "").downcase.gsub(/ /,"_")
      return hiring_organization 
    end
    return nil
  end

  def process_organization_name(job)

    job_hiring_organization = job['hiringOrganization']
    if job_hiring_organization
      hiring_organization_name = (job['hiringOrganization']['name'] || job['hiringOrganization']['legalName'] || "")
      return hiring_organization_name
    end
    return nil
  end

end
