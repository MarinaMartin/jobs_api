require 'spec_helper'

describe SchemaDotOrgData do
  let(:ttl) { "30d" }
  
  describe "import" do
    before do
      @html = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/test.html")
      @position_openings = [
        {type: 'position_opening', source: 'Schema Test', _ttl: ttl,
         position_title: 'Job Title', tags: %w(federal schema_test),
         organization_id: 'schema_test', organization_name: 'Schema Test',
         locations: [{city: 'Arlington', state: 'VA'}],
         start_date: Date.current, end_date: Date.current + 30.days, external_id: nil
        }
      ]
    end
    
    it "should load positions from a JSON string" do
      PositionOpening.should_receive(:import).with(@position_openings)
      schema_dot_org_data = SchemaDotOrgData.new
      schema_dot_org_data.import(@html, 'Schema Test')
    end
  end
end  
