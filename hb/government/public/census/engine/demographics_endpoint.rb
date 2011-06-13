module Government
  module Public
    module Census
      class DemographicsEndpoint < Endpoint

        extend Connection::HbaseGeoConnection

        #
        # Returns pre-cooked json
        #
        self.precooked_response_type = :json

        handles('places') do |params, app, responder|
          row_path = "demo.census"
          results  = hbase_db.geo_fetch('geo_location_infochimps_place', row_path, params)
          results
        end

      end
    end
  end
end
