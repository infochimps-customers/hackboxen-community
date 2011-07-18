module Sports
  module Baseball
    module Vargatron
      class TeamStats < Endpoint

        extend Connection::ElasticSearchConnection

        TEAM_ES_INDEX    = 'sports_baseball_vargatron'
        TEAM_ES_OBJ_TYPE = 'team_record'

        handles('search') do |params, app, responder|
          query = "team_name:#{params[:team_name]} OR team_loc:#{params[:team_name]}"
          results = elastic_search_db.standard_search(TEAM_ES_INDEX, TEAM_ES_OBJ_TYPE, query, params)
          responder.new(results)
        end

      end
    end
  end
end
