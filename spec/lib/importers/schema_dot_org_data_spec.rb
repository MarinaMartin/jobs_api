require 'spec_helper'

describe SchemaDotOrgData do
  let(:ttl) { "30d" }
  
  describe "import" do
    before do
      @html = File.read(Rails.root.to_s + "/spec/resources/schema_dot_org/test.html")
      @html.gsub!(/DATE-PLACEHOLDER/, Date.current.to_s)
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
    
    it "should load positions from an HTML string containing microdata" do
      PositionOpening.should_receive(:import).with(@position_openings)
      schema_dot_org_data = SchemaDotOrgData.new
      schema_dot_org_data.import(@html, 'Schema Test')
    end

    it "should not load positions from an HTML string missing required properties" do
      @html.gsub!(/<span itemprop=\"datePosted\">.*<\/span>/, "")
      PositionOpening.should_receive(:import).with([])
      schema_dot_org_data = SchemaDotOrgData.new
      schema_dot_org_data.import(@html, 'Schema Test')
    end

  end
end  
