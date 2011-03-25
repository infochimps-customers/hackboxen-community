#!/usr/bin/env ruby
require 'rubygems'
require 'ken'
require 'json/pure' # because the Ext emitter is buggier

# Our Freebase MQL query
$typequery={"id" => nil,
           "name" => nil,
           "type" => "/type/type",
           "properties" =>  [{ "id" => nil,
                               "optional" => true,
                               "name" => nil,
                               "expected_type" => { 
                                 "optional" => true, 
                                 "id" => nil,
                                 "name" => nil 
                               }
                             }
                            ]
}

                              
         
class FreebaseSchema

  def initialize(workdir)
    @workdir = workdir
    @types=[]
  end

  def get_all_types
    @types=Ken.session.mqlread([$typequery],:cursor => true)
  end

  def save_all_types
    File.open("#{@workdir}/FREEBASE_SCHEMA.json",'w') { |f| f.write(@types.to_json) }
  end
end

def run 
  fbs=FreebaseSchema.new '.'
  puts "Getting type schema fields from Freebase API...."
  fbs.get_all_types
  puts "Saving type schema...."
  fbs.save_all_types
  return
end


if __FILE__ == $0
  run
end

  



