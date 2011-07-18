module Sports
  module Baseball
    module Vargatron
      class GameStatsEndpoint < Endpoint

        extends Connection::HBaseConnection

        self.precooked_response_type :json

        GAME_TABLE = 'sports_baseball_vargatron'
        GAME_CF    = 'games'

        handles('lookup') do |params, app, responder|
          raise Apeyeye::RequestValidationError, "Need values for team_id, season and game_id!" unless params[:team_id] and params[:season] and params[:game_id]
          row_key = params[:team_id].upcase + params[:season].to_s + params[:game_id]
          results = hbase_db.get_row(GAME_TABLE, GAME_CF, row_key)
          responder.new(results)
        end

      end
    end
  end
end
