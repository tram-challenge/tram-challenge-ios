require 'json'
require 'ruby_dig'
require 'base64'

   query = %(
    {
      routes(modes: "TRAM") {
        id
        agency {
          id
        }
        shortName
        longName
        desc
        patterns {
          code
          trips {
            serviceId
          }
          stops {
            id
            gtfsId
            name
            code
            lat
            lon
          }
        }
      }
    }
    )
 endpoint_url = "https://api.digitransit.fi/routing/v1/routers/finland/index/graphql"

    resp = %x{curl -d '#{query}' -H "Content-Type: application/graphql" #{endpoint_url}}

    data = JSON.load(resp)

    # Delete the #5 tram since it doesn't exist yet
    # FIXME: reinstate it in the future
    data["data"]["routes"].delete_if { |r| r["shortName"] == "5" }
		
   data["data"]["routes"].each do |route|
      route["patterns"].sort_by! {|p| p["trips"].length }.reverse!
      if route["shortName"] == "6T"
        route["stops"] = route["patterns"][1]["stops"]
      else
        route["stops"] = route["patterns"][0]["stops"]
      end
    end

    stops = {}

    data.dig("data", "routes").each do |route|
      route["stops"].each_with_index do |s, index|
        stops[s["name"]] ||= {
          coordinates: [],
          hsl_ids: [],
          stop_numbers: [],
          routes: [],
          stop_positions: {},
          active: true
        }
        stops[s["name"]][:coordinates] << [s["lat"], s["lon"]]
        stops[s["name"]][:hsl_ids] << Base64.decode64(s["id"])
        stops[s["name"]][:stop_numbers] << s["code"]
        stops[s["name"]][:routes] << route["shortName"]
        stops[s["name"]][:stop_positions][route["shortName"]] = index

        stops[s["name"]].each do |k, v|
          v.uniq! if v.respond_to?(:uniq!)
        end
      end
    end

    p stops.count
    stops.collect {|k,v| k}.sort.each {|s| p s}