require 'spec_helper'

describe SchemaDotOrgData do
  let(:ttl) { "30d" }
  
  describe "import" do
    before do
      @position_openings = [
        {type: 'position_opening',
         source: 'Schema Test',
         tags: %w(federal schema_test),
         external_id: "http://test.com",
         locations: [{city: 'Kirkland', state: 'WA'}],
         _ttl: ttl,
         position_title: 'Software Engineer',
         organization_id: 'ABC_Company_Inc.', 
         organization_name: 'ABC Company Inc.',
         start_date: Date.current,
         end_date: Date.current + 30.days,
         date_posted: Date.current.to_s,
         url: 'http://test.com'
        }
      ]
    end
    
    it "should load positions from an HTML string containing microdata including all required properties" do
      @html = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/schema_dot_org_html_with_all_required_elements.html")
      @html.gsub!(/DATE-PLACEHOLDER/, Date.current.to_s)
      PositionOpening.should_receive(:import).with(@position_openings)
      schema_dot_org_data = SchemaDotOrgData.new
      schema_dot_org_data.import(@html, 'Schema Test')
    end

    it "should not load positions from an HTML string missing at least one required property" do
      @html = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/schema_dot_org_html_missing_required_elements.html")
      PositionOpening.should_receive(:import).with([])
      schema_dot_org_data = SchemaDotOrgData.new
      schema_dot_org_data.import(@html, 'Schema Test')
    end

  end
end  
