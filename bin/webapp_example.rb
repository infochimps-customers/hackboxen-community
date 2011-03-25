#!/usr/bin/env ruby
require 'sinatra'
require 'cgi'
require File.dirname(__FILE__)+'/freebase_api'

# Set this if you want others to see 
# set :bind, '192.168.1.22'

Template= %{
<html>
<body>

<h3>Freebase API Query</h3>
<form action="/" >
Freebase Type:<input type="text" size="40" name="fbtype" value="<%= fbtype %>"><br/>
Constraint Column:<input type="text" size="40" name="col" value="<%= col %>"><br/>
Constraint Value:<input type="text" size="40" name="val" value="<%= val %>"><br/>
Search Depth:<input type="text" name="depth" value="<%= depth %> "><br/>
<input type="submit" value="Run Query">
</form>

<h3>Result</h3>
<%= result_tree %>

</body>
</html>}


def render_tree t
  if t.class == String
    t
  elsif t.class == Array
    "<ul>"+(t.map {|v| "<li>#{render_tree(v)}</li>\n"  unless v.size==0} ).join("")+"</ul>\n"
  elsif t.class == Hash
    "<ul>"+(t.keys.map {|k| "<li><b>#{k}</b> : #{render_tree(t[k])}</li>\n" unless t[k].size==0 } ).join("")+"</ul>\n"
  else
    "ACK!"
  end
end
    
# Must be global so we don't have to startup for every HTTP request
$fapi = FreebaseAPI.new './FREEBASE_SCHEMA.json'


class FreebaseSearch
  def run
    get '/' do
      if request["fbtype"] and request["col"] and request["val"] and request["depth"]
        result = $fapi.get_freebase_topics(request["fbtype"],
                                           request["col"],
                                           (CGI::escape request["val"]),
                                           request["depth"].to_i)
      else
        result = ""
      end
      locals = {
        :fbtype => request["fbtype"],
        :col => request["col"],
        :val => request["val"],
        :depth => request["depth"],
        :result_tree => render_tree(result)
      }
      erb Template, :locals => locals
    end
  end
end



if __FILE__==$0
  fs=FreebaseSearch.new
  fs.run
end

