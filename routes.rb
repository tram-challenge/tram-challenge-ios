route_ids = File.readlines("route_ids.txt").collect(&:chomp)

route_ids.each do |route_id|

  trips = %x{grep -m 1 "^#{route_id}" trips.txt}
  initial_shape_id = trips.split(",")[5]
  if route_id !~ /^1007/
    shape_ids = [initial_shape_id, initial_shape_id.gsub(/1$/, "2")]
  else
    shape_ids = [initial_shape_id]
  end
  File.open(initial_shape_id.gsub(/^100?/, "").gsub(/_.*/, "") + ".coords.txt", "w") do |f|
    f.write("{\"line\": [\n")
    shape_ids.each do |shape_id|
      shape_data = %x{grep "^#{shape_id}" shapes.txt}
      shape_data.split("\n").each do |line|
        line_data = line.split(",")
        lat = line_data[1]
        lon = line_data[2]
        f.write("  [#{lat}, #{lon}],\n")
      end
    end
    f.write("]\n}\n")
  end
end
