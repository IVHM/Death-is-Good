
numbers_atlas = {
	{-1,-2}, {0,-2}, {1,-2}, --| 1| 2| 3|
	{-1,-1}, {0,-1}, {1,-1}, --| 4| 5| 6|
	{-1, 0}, {0, 0}, {1, 0}, --| 7| 8| 9|
	{-1, 1}, {0, 1}, {1, 1}, --|10|11|12|
	{-1, 2}, {0, 2}, {1, 2}  --|13|14|15|
}


number_sprites = {
	{2,5,8,11,14},               --(1)
	{1,2,6,8,9,10,13,14,15},     --(2)
	{1,2,6,8,12,13,14},			 --(3)
	{1,3,4,6,8,9,12,15},		 --(4)
	{1,2,3,4,7,8,12,13,14},	 	 --(5)
	{2,4,7,8,10,12,14},			 --(6)
	{1,2,3,6,8,11,14},			 --(7)
	{2,4,6,8,10,12,14},			 --(8)
	{2,4,6,8,9,12,15},			 --(9)
	{2,4,6,7,9,10,12,14}		 --(0)

}


function draw_lives_counter(sprite_pos, number_in)
	local score_display = false

	if number_in > 99 then score_display = true end
	if number_in < 0 then number_in = number_in * -1 end

	if not score_display then
		local ones_place = number_in % 10
		local tens_place = (number_in - ones_place) / 10

		if ones_place == 0 then ones_place = 10 end
		if tens_place == 0 then tens_place = 10 end
		
		love.graphics.setColor(color[2])
		love.graphics.rectangle("fill",sprite_pos.x - 2, sprite_pos.y -3, 9, 7)
		love.graphics.setColor(color[1])
		-- print(tens_place,ones_place)
		-- Draw the pixels for the tens place
		for k,v in pairs(number_sprites[tens_place]) do
			local t_p = {x = numbers_atlas[v][1] + sprite_pos.x,
						 y = numbers_atlas[v][2] + sprite_pos.y}
			love.graphics.rectangle("fill",t_p.x, t_p.y, 1, 1)
		end

		-- Draw the pixels for the ones place
		for k,v in pairs(number_sprites[ones_place]) do
			local t_p = {x = numbers_atlas[v][1] + sprite_pos.x + 4,
						 y = numbers_atlas[v][2] + sprite_pos.y}
			love.graphics.rectangle("fill", t_p.x, t_p.y, 1, 1)
		end
	
	else
		local number_places = {}
		local crnt_number = number_in
		local tens_inc = 1

		while true do
			local t_n = crnt_number % 10
			if t_n == 0 then t_n = 10 end

			table.insert(number_places,1, t_n)
			crnt_number = (crnt_number - t_n) /10
			
			if crnt_number < 0 then break end
		end

		for k,v in pairs(number_places) do
			for key,p in pairs(number_sprites[v]) do
				local t_p = {x = numbers_atlas[p][1] + sprite_pos.x + 4*(k-1),
							 y = numbers_atlas[p][2] + sprite_pos.y}

				love.graphics.rectangle("fill", t_p.x, t_p.y,1,1)

			end
		end
	end



end



