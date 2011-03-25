#!/usr/bin/env ruby
require 'json/pure'
require 'open-uri'

APIPREFIX = 'http://api.infochimps.com/encyclopedic/freebase/lists/wildcard/list'
APIKEY = 'api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469'

# Convert the freebase ID for a type into an API endpoint ID
def to_endpoint id
  t=id.split('/')
  domain = t[1..-2].join('_')
  type = t[-1]
  "freebase_tsv_#{domain}__#{type}"
end

class FreebaseAPI

  def initialize schemafilename
    @schemafilename = schemafilename  # We need to use the Freebase schema we crawled
    @linkto = {}
    # ingest our freebase schema
    if @schemafilename
      ingest_schema 
    end
  end

  def ingest_schema
    File.open(@schemafilename) { |f| JSON.parse(f.read()) }.each do |rec|
      t={}
      rec['properties'].each do |prop|
        if prop['name'] and prop['expected_type'] and not prop['expected_type']['id'].start_with? '/type/'
          propname=prop['id'].split('/')[-1]
          # p propname,prop['expected_type']['id']
          t[propname]=to_endpoint(prop['expected_type']['id'])
        end
      end
      @linkto[to_endpoint(rec["id"])]=t
    end
  end

  def get_freebase_topics type,keyfield,value,depth=0
    url = "#{APIPREFIX}?freebase_type=#{type}&#{keyfield}=#{value}&apikey=#{APIKEY}" 
    result=[]
    open(url) do |fh|
      resp = JSON.parse(fh.read[20..-2])
      if depth > 0
        resp['results'].each do |hit|
          hit.keys.each do |field|
            if ['name','id'].include?(field)
              next  # These are not really part of the type
            end
            expected = @linkto[type][field]
            if expected
              subtopics=hit[field].split(',')  # Because Freebase IDs come comma separated
              subresults=[]
              subtopics.each do |st|
                subresults << get_freebase_topics(expected,"id",st,depth-1)
              end
              hit[field] = subresults
            end
          end
        end
      end
      return resp['results']
    end
  end
end

if __FILE__ == $0
  schemafilename = ARGV[0] || schemafilename = './FREEBASE_SCHEMA.json'
  fapi=FreebaseAPI.new schemafilename
  # Find out the movies that Alan Rickman was in.
  # Depth argument indicates how many sublevels to descend
  t = fapi.get_freebase_topics("freebase_tsv_film__actor","name","Alan%20Rickman",1)
  p t
end

    

