--Player File
require("UTIL")

Player = {
	
	--Stats
	gameover = false
	alive = true,
	health = 5,
	ammo = 6,
	max_ammo = 6,
	lives = 9,
	size = 3,

	--Location
	pos = {x=42, y=24},

	--Cooldowns 
	move_cooldown = .03,
	shoot_cooldown = .2,
	--Timers
	last_move_time = love.timer.getTime(),
	last_shot_time = love.timer.getTime(),

	--Bullet properties
	firing = false,
	fired_time = 0,
	bullet_life = .08,
	bullet_vec = {x=0, y=0},
	bullet_length = 40,
	bullet_prop = {x=0, y=0, w=1, h=1},

	--Respawn control
	respawn_anim_delay = .2,
	last_respawn_time = 0,
	respawn_anim_cntr = 0,
	respawn_anim_amt = 4 
}

Player_animations = {
	melee ={ { }

	}


}


function Player:move(mov_vec)
	if self.alive then
		self.pos.x = self.pos.x + mov_vec.x 
		self.pos.y = self.pos.y + mov_vec.y
	end
end



function Player:add_life()
	if self.lives < 9 then
		self.lives = self.lives + 1
	end
end

function Player:lose_life()
	self.live = self.lives -1
	if self.lives == 0 then 
		self.gameover = true
	end
end


--Takes in a directional vector and intialize the bullet's properties
function Player:shoot(shot_vec, bullet_len_in)
	
	if self.ammo > 0 and self.alive then
		--print("firing along vector :("..shot_vec.x..", "..shot_vec.y..")")
		self.firing = true
		self.fired_time = love.timer.getTime()
		self.bullet_length = bullet_len_in
		self.bullet_prop.x, self.bullet_prop.y = self.pos.x+1 + shot_vec.x,

											 self.pos.y+1 + shot_vec.y 

		self.bullet_prop.w, self.bullet_prop.h = (self.bullet_length * shot_vec.x) + 1,
											 (self.bullet_length * shot_vec.y) + 1
	

		--print("bullet_prop:"..self.bullet_prop.x..",".. self.bullet_prop.y..","..
		--								self.bullet_prop.h..",".. self.bullet_prop.w)											 

		self.ammo = self.ammo - 1
	end


end



-- Checks if the player is colliding with a certain 
function Player:check_collisions(...)
	local collision_detected = false
	local pos_in = {...}
	if type(pos_in[1][1]) ~= "number" then
		pos_in = pos_in[1]
	end


	for k, p in pairs(pos_in) do --Loop through the table of points
		for i = 0, self.size - 1, 1 do --
			for j = 0, self.size -1, 1 do 
				t_p = {x = self.pos.x + i, y = self.pos.y + j}
				if p.x == t_p.x and p.y == t_p.y then
					collision_detected = true

				end
			end
		end
	end

	return collision_detected
end


function Player:show()
	if self.alive then
		Player:draw_sprite()
	else
		if love.timer.getTime() - self.last_respawn_time > self.respawn_anim_delay then
			self.respawn_anim_cntr = self.respawn_anim_cntr + 1
			if self.respawn_anim_cntr % 2 == 0 then
				Player:draw_sprite()
			end
			if self.respawn_anim_cntr == self.respawn_anim_amt then
				self.alive = true
				self.respawn_anim_cntr = 0
			end
		end
	end

	--BULLET RENDERING CONTROL
	if self.firing == true then
		if love.timer.getTime() - self.fired_time > self.bullet_life then
			self.firing = false
		else
			love.graphics.setColor(color[1])
			love.graphics.rectangle("fill", self.bullet_prop.x, self.bullet_prop.y,
											self.bullet_prop.w, self.bullet_prop.h)
		end
	end

	--AMMO COUNTER DISPLAY
	for i = 1, self.ammo, 1 do 
		local t_x = 32 + (4 * i) 
		t_y = 44
		love.graphics.rectangle("fill", t_x , t_y , 2,3)
	end   
end


function  Player:was_hit()
	local exploding = false
	if self.alive then
		self.alive = false
		self.lives = self.lives - 1
		exploding = true
		self.last_respawn_time = love.timer.getTime()
		self.ammo = self.max_ammo
	end
	return exploding
end

function Player:draw_sprite()
	love.graphics.setColor(color[1])
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size, self.size)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y - 1, 1,1)
	love.graphics.rectangle("fill", self.pos.x + 2, self.pos.y - 1, 1,1)
	love.graphics.rectangle("fill", self.pos.x + 3, self.pos.y + 2, 1, 1)
end
--Returns all the point thatmake up the pixels in the players sprite
function Player:get_body()
	local t_body = {}
	local n = 0
	for i = 0, self.size - 1, 1 do
		for j = 0, self.size -1, 1 do 
			local t_p = {self.pos.x + i, self.pos.y + j}
			n = n + 1
			t_body[n] = {x = t_p[1], y = t_p[2]}
		end
	end

	return t_body
end



