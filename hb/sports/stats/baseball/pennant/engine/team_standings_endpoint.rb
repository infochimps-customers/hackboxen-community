# -*- coding: utf-8 -*-
module Sports
  module Stats
    module Baseball
      class PennantTeamStandingEndpoint < Endpoint

        extend Connection::MysqlConnection

        BASEBALLPENNANT_DB = 'sports_stats_baseball'
        BASEBALLPENNANT_TABLE = 'pennant_team_standings'

        handles('team_standings') do |params, app, responder|
          conditions   = {
            'team_name' => params[:team_name],
            'record_year' => params[:record_year]
          }
          raw_results = mysql_db.get_row_as_hash(BASEBALLPENNANT_DB, BASEBALLPENNANT_TABLE, conditions) || {}
          responder.new(raw_results)
        end

      end
    end
  end
end
