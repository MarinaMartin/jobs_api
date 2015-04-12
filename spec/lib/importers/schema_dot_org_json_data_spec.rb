require 'spec_helper'

describe SchemaDotOrgJsonData do
  let(:ttl) { "30d" }
  
  describe "import" do
    before do
      @json = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/test.json")
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
            :url=>nil
          }, 
          {
            :type=>"position_opening",
            :source=>"Schema JSON Test",
            :tags=>["private"],
            :external_id=>nil,
            :locations=>[{:city=>"Nowhere", :state=>"MD"}],
            :_ttl=>"30d",
            :position_title=>"Software Engineer Too",
            :organization_id=>"schema_json_test",
            :organization_name=>"Schema JSON Test",
            :start_date=>Date.current,
            :end_date=>Date.current + 30.days,
            :url=>nil
          }
      ]
    end
    
    it "should load positions from a JSON string" do
      PositionOpening.should_receive(:import).with(@position_openings)
      importer = SchemaDotOrgJsonData.new(@json, 'Schema JSON Test')
      importer.import
    end
  end
end  

