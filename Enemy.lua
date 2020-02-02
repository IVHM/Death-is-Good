--enemy class 

--Enemy sprites are created out of individual pixels 
--they are drawn based off of references to a grid atlas
--                                   X
--ie enemy_shape = "up" = {2,4,6} = X X


---------------------
--PIXEL SPRITE TABLES
pixel_atlas = {{-1,-1},{0,-1},{1,-1}, --|1|2|3|
			   {-1, 0},{0, 0},{1, 0}, --|4|5|6|
			   {-1, 1},{0, 1},{1, 1}  --|7|8|9|
			  }

variant_ratios = {
	base   = {.6},
	medium = {.2},
	heavy  = {.1}
}

enemy_pixel_maps = {

	base={ --VARIANT 1
		   up = {2,4,6}, -- this 
		right = {2,6,8},
		 down = {4,6,8},
		 left = {2,4,8}
	},

	medium={
		   up = {1,2,3,4,6}, -- this 
		right = {2,3,6,8,9},
		 down = {4,6,7,8,9},
		 left = {1,2,4,7,8}		

	},

	heavy={
		   up = {1,2,3,4,6,7,9}, -- this 
		right = {1,2,3,6,7,8,9},
		 down = {1,3,4,6,7,8,9},
		 left = {1,2,3,4,7,8,9}
	}
}


--------------------
--ENEMY CLASS
Enemy = {
	pos = {x=0,y=0},
	normal = {x=0,y=-1}
	}

function Enemy:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.pos.x, self.pos.y = 0, 0
	self.normal = {x = 0, x = -1}
	self.direction = "up"
	self.variant = "base"
	self.body = {};
	return o
end

--MUST BE CALLED ON INITIALIZATION OR DATA WILL BE CORRUPTED
function Enemy:init_values(pos_in, normal_in, variant_in)
	self.pos = pos_in
	self.normal = normal_in
	self.variant = variant_in
	self.direction = get_direction(self.normal)
	self.body = get_sprite(self.pos, self.variant, self.direction)
end

--
function Enemy:show()
	-- 
	for k, v in pairs(self.body) do
		--print("v: "..v.x)
		love.graphics.rectangle("fill",v.x, v.y,1,1)
	end
end


function Enemy:check_collision(...)
	local collision_detected = false
	local pos_in = {...}
	print(pos_in[1],pos_in[1][1])
	if type(pos_in[1].x) ~= "number" then
		pos_in = pos_in[1]
	end

	for ky,p in pairs(pos_in)do 
		for k,v in pairs(self.body) do
			if v.x == p.x and v.y == p.y then
				collision_detected = true
			end
		end
	end

	return collision_detected
end


--Translates an enemies normal vector into a string based direction value 
function get_direction(vec_in)
	local direction_out = "up"
	if vec_in.x == 0 then
		if vec_in.x == 1 then
			direction_out = "down"
		end
	elseif vec_in.x == 1 then
		direction_out = "right"
	elseif vec_in.x == -1 then
		direction_out = "left"
	else
		print("Incorrect vector was entered in get_direction()")
	end

	return direction_out 
end


-- Used to create the enemy's sprite from it's current state
function get_sprite(enemy_pos,variant, direction)
	local pixels_out = {}
	local n = 0
	for k, v in pairs(enemy_pixel_maps[variant][direction]) do
		n = n + 1
		pixels_out[n] = {x = enemy_pos.x + pixel_atlas[v][1],
			   		     y = enemy_pos.y + pixel_atlas[v][2]}
	end
	return pixels_out

end


