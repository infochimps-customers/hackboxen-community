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
          lng        = params[:lng]
          lat        = params[:lat]
          zoom       = params[:zoom]
          max_pages  = (params[:_limit] || 10)
          start_page = (params[:_from]  || 0)

          row_path = "demo.census"
          hbase_db.geo_fetch('geo_location_infochimps_place', lng, lat,
            row_path, start_page, max_pages, zoom)
        end

      end
    end
  end
end
