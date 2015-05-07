module JobImporter
  
  CATCHALL_THRESHOLD = 20
  
  def normalize_location(location_str)
    location_str.gsub!(/[()]/, '')
    location_str.sub!(/ Arizona Strip$/i, '')
    location_str.sub!(/ ?(United States|, US)$/i, '')
    location_str.sub!(/(, GQ)? Guam$/i, ', GQ')
    location_str.sub!(/(, PR)? Puerto Rico$/i, ', PR')
    location_str.sub!(/^(Dist(\.|rict)? of Columbia)$/i, 'Washington, DC')
    location_str.sub!(/(Dist(\.|rict)? of Columbia|D.C.)$/i, 'DC')
    location_str.sub!(/ DC, DC/i, ' DC')
    location_str.sub!(/^Dist(\.|rict)? of Columbia( County)?/i, 'Washington')
    location_str.sub!(/^Washington DC Metro Area/i, 'Washington Metro Area')
    location_str.sub!(/Washington DC$/i, 'Washington, DC')
    abbreviate_state_name(location_str)
  end

  def abbreviate_state_name(location_str)
    state_name = location_str.rpartition(',').last.strip
    if State.member?(state_name)
      abbreviation = State.normalize(state_name)
      if abbreviation != state_name
        return location_str.sub(/#{state_name}/, abbreviation)
      end
    end
    location_str
  end

  def required_properties
    return [
      'hiringOrganization',
      'datePosted', 
      'url'
    ]
  end
end
