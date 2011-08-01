module Sports
  module Baseball
    module Vargatron
      class InningStatsEndpoint < Endpoint

        extends Connection::HBaseConnection

        self.precooked_response_type :json

        INNING_TABLE = 'sports_baseball_vargatron'
        INNING_CF    = 'base'

        handles('lookup') do |params, app, responder|
          raise Apeyeye::RequestValidationError, "Need values for both game_id and inning!" unless params[:game_id] and params[:inning]
          row_key = 'inning:' + params[:game_id].to_s.upcase + ':' + params[:inning].to_s
          results = hbase_db.get_row(INNING_TABLE, INNING_CF, row_key)
          responder.new(results)
        end

      end
    end
  end
end
