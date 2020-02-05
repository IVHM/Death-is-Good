--Player File
require("UTIL")

firing_anim = {

	up = {},
	down = {},
	left = {},
	right = {}
}

--stores the location relative to player pos 
-- as well as size of rectangle
kamikaze_anim = {
	--frame1
	{{1,0,1,1},{0,1,1,1},{2,1,1,1},{1,2,1,1}},
	--frame2
	{{0,-1,3,1},{3,0,1,1},{-1,1,1,2},{0,3,3,1},{3,2,1,1}},
	--frame3
	{{-1,-3,2,1},{2,-3,2,1},{6,-3,1,1},{5,-1,1,1},{5,1,1,2},
	 {5,4,1,1},{1,5,3,1},{-1,5,1,1},{-3,6,1,1},{-3,3,1,1},
	 {-3,-1,1,3}, {-4,-4,1,1}},
	--frame4
	{{-1,-6,1,1},{5,-6,1,1},{8,-1,1,1},{8,3,1,1},{6,10,1,1},
	 {-1,8,1,1},{-7,6,1,1},{-6,-2,1,1}}
}
	


Player = {
	
	--Stats
	gameover = false,
	alive = true,
	health = 5,
	ammo = 6,
	max_ammo = 6,
	lives = 2,
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
	bullet_life = .1,
	bullet_vec = {x=0, y=0},
	bullet_length = 40,
	bullet_prop = {x=0, y=0, w=1, h=1},

	--Firing Player_animations
	firing_anim_delay = .025, --delay between frames of Player_animations
	last_firing_anim = 0,
	firing_anim_cntr = 0,
	firing_anim_amt = 3,

	laser_beam_shrink = .25,
	laser_inc_amt = {x=0,y=0}, --Is the length of the rect * shrink ratio

	--Kamikaze Animation control
	kamikaze_anim_playing = false,
	kamikaze_anim_delay = .08,
	last_kamikaze_time = 0,
	kamikaze_anim_cntr = 1,
	kamikaze_anim_amt = 4,

	--Respawn control
	respawn_anim_last_frame = 0,
	respawn_anim_delay = .05,
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
	self.lives = self.lives - 1
	print("player lives: ", self.lives, "gameover?:", self.gameover)
	if self.lives < 1 then 
		self.gameover = true
	end
end

function Player:respawn()
	self.alive = true
	self.gameover = false
	self.lives = 9
	self.ammo = 6
	self.pos = {x=math.floor(screen_height/2),
				y=math.floor(screen_width/2)}
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
		self.laser_inc_amt.x , self.laser_inc_amt.y = self.bullet_length * shot_vec.x * self.laser_beam_shrink,
													  self.bullet_length * shot_vec.y * self.laser_beam_shrink
		self.last_firing_anim = love.timer.getTime()

		print("bullet_prop:"..self.bullet_prop.x..",".. self.bullet_prop.y..","..
										self.bullet_prop.h..",".. self.bullet_prop.w)											 
		print("laser_inc_amt: ", self.laser_inc_amt.x,",",self.laser_inc_amt.y)
		print("shot_vec:", shot_vec.x, shot_vec.y)
		self.ammo = self.ammo - 1
	end 
end


-- Checks if the player is colliding with a certain 
function Player:check_collision(...)
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
	local crnt_time = love.timer.getTime()

	if self.alive then
		Player:draw_sprite()
	--KAMIKAZE ANIMATION CONTROL
	elseif self.kamikaze_anim_playing then
		if crnt_time - self.last_kamikaze_time > self.kamikaze_anim_delay then
			self.last_kamikaze_time = crnt_time
			self.kamikaze_anim_cntr = self.kamikaze_anim_cntr + 1
			
			print("Drawing kamikaze anim frame: ", self.kamikaze_anim_cntr)
			
			

		end
		love.graphics.setColor(color[1])
		for k,v in pairs(kamikaze_anim[self.kamikaze_anim_cntr]) do
				love.graphics.rectangle("fill",self.pos.x + v[1],
											   self.pos.y + v[2],
												v[3],v[4])
		end
		if self.kamikaze_anim_cntr == self.kamikaze_anim_amt then
			self.kamikaze_anim_playing = false
			self.kamikaze_anim_cntr = 1
			self.last_respawn_time = crnt_time
		end
	else 
		if crnt_time - self.last_respawn_time > self.respawn_anim_delay then
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
		if crnt_time - self.last_firing_anim > self.firing_anim_delay then
			self.bullet_prop.x = self.bullet_prop.x + self.laser_inc_amt.x
			self.bullet_prop.w = self.bullet_prop.w - self.laser_inc_amt.x
			self.bullet_prop.y = self.bullet_prop.y + self.laser_inc_amt.y
			self.bullet_prop.h = self.bullet_prop.h - self.laser_inc_amt.y
			self.last_firing_anim = crnt_time
		end

		if crnt_time - self.fired_time > self.bullet_life then
			self.firing = false
		else
			love.graphics.setColor(color[1])
			love.graphics.rectangle("fill", self.bullet_prop.x, self.bullet_prop.y,
											self.bullet_prop.w, self.bullet_prop.h)
		end
	end

	
	--AMMO COUNTER DISPLAY
	for i = 1, 6, 1 do 
		local t_x = 32 + (4 * i) 
		t_y = 44
		if i <= self.ammo then
			love.graphics.setColor(color[1])
			love.graphics.rectangle("fill", t_x , t_y , 2,3)
		else
			love.graphics.setColor(color[1])
			love.graphics.rectangle("line", t_x, t_y,2,3)

		end
	end   
end


function  Player:was_hit()
	local exploding = false
	if self.alive then
		self.alive = false
		exploding = true
		self.kamikaze_anim_playing = true
		self.last_kamikaze_time = love.timer.getTime()
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



