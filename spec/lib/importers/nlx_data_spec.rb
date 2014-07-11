require 'spec_helper'

describe NlxData do
  let(:ttl) { "28d" }
  
  describe "import" do
    before do
      @nlx_json = File.read(Rails.root.to_s + "/spec/resources/nlx/jobs.json")
      @position_openings = [
        {type: 'position_opening', source: 'alliedbarton', external_id: "59D6C80902EC4FC88EF01BADBB990FBB", _ttl: ttl,
         position_title: 'Manufacturing Engineer', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Tijuana', state: 'MD'}],
         start_date: Date.parse('2014-07-09'), end_date: Date.parse('2014-07-09') + 30.days },
        {type: 'position_opening', source: 'alliedbarton', external_id: "E48345D53CF44992AFF406CFFFF2BB42", _ttl: ttl,
         position_title: 'Service Sales Engineer', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Nanterre', state: 'TX'}],
         start_date: Date.parse('2014-07-09'), end_date: Date.parse('2014-07-09') + 30.days 
        },
        {type: 'position_opening', source: 'alliedbarton', external_id: "C4677B65BBEB47B7AF7923DBCDC81B38", _ttl: ttl,
         position_title: 'Production Technician - Glendale Heights, IL', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Glendale Heights', state: 'IL'}],
         start_date: Date.parse('2014-07-09'), end_date: Date.parse('2014-07-09') + 30.days 
        }         
      ]
    end
    
    it "should load positions from a JSON string" do
      PositionOpening.should_receive(:import).with(@position_openings)
      nlx = NlxData.new(@nlx_json, "alliedbarton", "AB", "Allied-Barton")
      nlx.import
    end
  end
end  