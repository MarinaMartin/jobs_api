require 'spec_helper'

describe SchemaDotOrgJsonData do
  let(:ttl) { "30d" }
  
  describe "import" do
    before do
      @position_openings = 
        [
          {
            :type=>"position_opening",
            :source=>"Schema JSON Test",
            :tags=>["private"],
            :external_id=>nil,
            :locations=>[{:city=>"Kirkland", :state=>"WA"}],
            :_ttl=>"30d",
            :position_title=>"Software Engineer",
            :organization_id=>"abc,_inc.",
            :organization_name=>"ABC, Inc.",
            :start_date=>Date.current,
            :end_date=>Date.current + 30.days,
            :date_posted=>Date.current.to_s,
            :url=>'www.testurl01.com',
            :external_id=>'www.testurl01.com'
          }
      ]
    end
    
    it "should load positions from a JSON string" do
      @json = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/schema_dot_org_json_with_all_required_elements.json")
      @parsed_json = JSON.parse(@json)
      @parsed_json.first["datePosted"] = Date.current
      @json = @parsed_json.to_json
      PositionOpening.should_receive(:import).with(@position_openings)
      importer = SchemaDotOrgJsonData.new(@json, 'Schema JSON Test')
      importer.import
    end

    it "should not load positions from a JSON string missing required properties" do
      @json = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/schema_dot_org_json_missing_required_elements.json")
      PositionOpening.should_receive(:import).with([])
      importer = SchemaDotOrgJsonData.new(@json, 'Schema JSON Test')
      importer.import
    end

  end
end  

