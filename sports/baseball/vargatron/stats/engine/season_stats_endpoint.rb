module Sports
  module Baseball
    module Vargatron
      class SeasonStatsEndpoint < Endpoint

        extends Connection::HBaseConnection

        self.precooked_response_type :json

        SEASON_TABLE = 'sports_baseball_vargatron'
        SEASON_CF    = 'base'

        handles('lookup') do |params, app, responder|
          raise Apeyeye::RequestValidationError, "Both team_id and season need parameters!" unless params[:team_id] and params[:season]
          row_key = 'season:' + params[:team_id].to_s.upcase + ':' + params[:season].to_s
          results = hbase_db.get_row(SEASON_TABLE, SEASON_CF, row_key)
          responder.new(results)
        end

      end
    end
  end
end
