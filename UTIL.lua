--utility scripts

function dis_between(pos1_in, pos2_in)
	local pos1 = pos1_in
	local pos2 = pos2_in
	pos1 = indexed_to_vector(pos1)
	pos2 = indexed_to_vector(pos2)

	local distance_between = math.sqrt((math.abs(pos1.x - pos2.x)^2 + 
			 		  	               (math.abs(pos1.y - pos2.y))^2)) 
	return distance_between
end


-- MUST TAKE IN A  
function indexed_to_vector(table_in)
	local table_out = {}
	local key_type = nil
	for k,v in pairs(table_in) do key_type = type(k) break end
	if key_type == "number" then
		table_out.x, table_out.y = table_in[1], table_in[2]
	else 
		table_out = {x= table_in.x, y=table_in.y}
	end
	return table_out
end	


-- WILL NOT WORK ON NESTED TABLES
function get_keys_to(table_in)
	local key_ring = {}
	local n = 0

	for k,v in table_in do 
		n = n + 1
		key_ring[n] = k
	end
	return key_ring
end	