class NlxData
  include JobImporter
  
  def initialize(json, source, organization_id, organization_name)
    @json = json
    @source = source
    @organization_id = organization_id
    @organization_name = organization_name
  end
  
  def import
    parsed_json = JSON.parse(@json)
    position_openings = parsed_json.collect do |job|
      process_job(job)
    end.compact
    PositionOpening.import position_openings
  end
  
  def process_job(job)
    published_at = DateTime.parse(job['date_new'])
    start_date = published_at.to_date
    end_date = start_date + 30.days
    days_remaining = (end_date - Date.current).to_i
    inactive = false
    days_remaining = 0 if days_remaining < 0 || start_date > end_date || inactive
    entry = {type: 'position_opening', source: @source, tags: %w(federal)}
    entry[:external_id] = job['guid']
    entry[:locations] = process_locations(job['location'])
    if entry[:locations]
      entry[:locations] = [] if entry[:locations].size >= CATCHALL_THRESHOLD
      entry[:_ttl] = (days_remaining.zero? || entry[:locations].empty?) ? '1s' : "#{days_remaining}d"
      unless entry[:_ttl] == '1s'
        entry[:position_title] = job['title']
        entry[:organization_id] = @organization_id
        entry[:organization_name] = @organization_name
        entry[:start_date] = start_date
        entry[:end_date] = end_date
        entry[:url] = job['url']
      end
      entry
    end
  end
  
  def process_locations(locations)
    normalized_location_str = normalize_location(locations)
    cities_comma_state = normalized_location_str.rpartition(',')
    city, state = cities_comma_state.first.strip, cities_comma_state.last.strip
    [{city: city, state: state}] if state.length == 2
  end
end