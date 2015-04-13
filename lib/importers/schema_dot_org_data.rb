class SchemaDotOrgData
  include JobImporter
  
  def initialize
  end
  
  def import(html, source)
    doc = Mida::Document.new(html)
    position_openings = []
    doc.items.each do |item|
      if item.type == "http://schema.org/JobPosting"
        position_openings << process_job_posting(item, source)
      end
    end
    PositionOpening.import position_openings.compact
  end
  
  def process_job_posting(job_posting, source)
    if job_posting.properties
      published_at = DateTime.parse(job_posting.properties["datePosted"]) if job_posting.properties["datePosted"]
      start_date = published_at ? published_at.to_date : Date.current
      end_date = start_date + 30.days
      days_remaining = (end_date - Date.current).to_i
      inactive = false
      days_remaining = 0 if days_remaining < 0 || start_date > end_date || inactive
      entry = {type: 'position_opening', source: source, tags: ["federal", source.downcase.gsub(/ /, "_")]}
      entry[:external_id] = job_posting.id || job_posting.properties["url"]
      entry[:locations] = process_locations(job_posting)
      if entry[:locations]
        entry[:locations] = [] if entry[:locations].size >= CATCHALL_THRESHOLD
        entry[:_ttl] = (days_remaining.zero? || entry[:locations].empty?) ? '1s' : "#{days_remaining}d"
        unless entry[:_ttl] == '1s'
          entry[:position_title] = job_posting.properties['title'].first if job_posting.properties['title']
          entry[:organization_id] = process_organization(job_posting) || source.downcase.gsub(/ /, "_")
          entry[:organization_name] = process_organization_name(job_posting) || source
          entry[:start_date] = start_date
          entry[:end_date] = end_date
          entry[:minimum] = job_posting.properties['baseSalary'] if job_posting.properties['baseSalary']
        end
      end 
      entry
    end
  end
  
  def process_locations(job_posting)
    job_location = job_posting.properties['jobLocation']
    if job_location.first.properties['address']
      address = job_location.first.properties['address']
      return address.collect do |job_location|
        city = job_location.properties['addressLocality'].first
        state = job_location.properties['addressRegion'].first
        {city: city, state: state}
      end
    end
  end
  
  def process_organization(job_posting)
    hiring_organization = job_posting.properties['hiringOrganization']
    if hiring_organization
      return hiring_organization.first.properties['name'].first.gsub(' ','_')
    else
      return nil
    end
  end
  
  def process_organization_name(job_posting)
    hiring_organization = job_posting.properties['hiringOrganization']
    if hiring_organization
      return hiring_organization.first.properties['name'].first
    else
      return nil
    end
  end    
end
