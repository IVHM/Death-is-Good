--utility scripts

function dis_between(pos1, pos2)
	  

end


-- MUST TAKE IN A  
function indexed_to_vector(table_in)
	local table_out
	local keys = get_keys_to(table_in)
	if type(keys[1]) == "number" then
		table_out.x, table_out.y = table_in[1], table_in[2]
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