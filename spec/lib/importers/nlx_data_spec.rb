require 'spec_helper'

describe NlxData do
  let(:ttl) { "28d" }
  
  describe "import" do
    before do
      @start_time = 2.days.ago
      @start_date = @start_time.to_date
      @nlx_json = ERB.new(File.read(Rails.root.to_s + "/spec/resources/nlx/jobs.json.erb")).result(self.send(:binding))
      @position_openings = [
        {type: 'position_opening', source: 'alliedbarton', external_id: "59D6C80902EC4FC88EF01BADBB990FBB", _ttl: ttl,
         position_title: 'Manufacturing Engineer', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Tijuana', state: 'MD'}],
         start_date: @start_date, end_date: @start_date + 30.days,
         url: "http://eaton-veterans.jobs/59D6C80902EC4FC88EF01BADBB990FBB24" },
        {type: 'position_opening', source: 'alliedbarton', external_id: "E48345D53CF44992AFF406CFFFF2BB42", _ttl: ttl,
         position_title: 'Service Sales Engineer', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Nanterre', state: 'TX'}],
         start_date: @start_date, end_date: @start_date + 30.days,
         url: "http://eaton-veterans.jobs/E48345D53CF44992AFF406CFFFF2BB4224" 
        },
        {type: 'position_opening', source: 'alliedbarton', external_id: "C4677B65BBEB47B7AF7923DBCDC81B38", _ttl: ttl,
         position_title: 'Production Technician - Glendale Heights, IL', tags: %w(federal),
         organization_id: 'AB', organization_name: 'Allied-Barton',
         locations: [{city: 'Glendale Heights', state: 'IL'}],
         start_date: @start_date, end_date: @start_date + 30.days,
         url: "http://eaton-veterans.jobs/C4677B65BBEB47B7AF7923DBCDC81B3824" 
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
