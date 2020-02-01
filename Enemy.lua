--enemy class

Enemy = {
	pos = {x=0,y=0},
	normal = {0,-1}


	
	}
	 
}

--Enemy sprites are created out of individual pixels 
--they are drawn based off of references to a grid atlas
--                            X
--ie enemy_shape = {2,4,6} = X X


pixel_atlas = {{-1,-1},{0,-1},{1,-1},
			   {-1, 0},{0, 0},{1, 0},
			   {-1, 1},{0, 1},{1, 1}
			  }


enemy_pixel_maps = {

	base={ --VARIANT 1
		   up = {2,4,6}, -- this 
		right = {2,6,8},
		 down = {4,6,8},
		 left = {2,4,8}
	}
}

function Enemy:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.pos.x, self.pos.y = 0, 0
	self.normal = {0,-1}
	self.direction = "up"
	self.variant = "base";

	return o
end

function Enemy:init_values(pos_in, normal_in, variant_in)
	self.pos.x, self.pos.y = pos_in[1], pos_in[2]
	self.normal = normal_in
	self.variant = variant_in
end

function Enemy:show()

	t_pixels = get_sprite(self.pos, self.variant, self.direction)	 

	for k, v in t_pixels do
		love.graphics.rectangle(v[1], v[2],1,1)
	end
end

function get_sprite(enemy_pos,variant, direction)
	local pixels_out = {}

	for k, v in enemy_pixel_maps[variant][direction] do
		t_p = {x = enemy_pos.x + pixel_atlas[v][1],
			   y = enemy_pos.y + pixel_atlas[v][2]
              }
		table.insert(pixels_out, t_p) 
	end
	return pixels_out

end


