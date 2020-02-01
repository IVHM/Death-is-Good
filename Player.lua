--Player File

Player = {
	
	--Stats
	health = 5,
	ammo = 6,
	lives = 10,
	size = 3,

	--Location
	pos = {x=42, y=24},

	--Cooldowns 
	move_cooldown = .06,
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
	bullet_prop = {x=0, y=0, w=1, h=1}
}

--Updates players position
function Player:move(mov_vec)
	self.pos.x = self.pos.x + mov_vec.x 
	self.pos.y = self.pos.y + mov_vec.y
end

function Player:get_pos()
	return self.pos 
end
--Takes in a directional vector and intialize the bullet's properties
function Player:shoot(shot_vec)
	print("firing along vector :("..shot_vec.x..", "..shot_vec.y..")")
	self.firing = true
	self.fired_time = love.timer.getTime()
	self.bullet_prop.x, self.bullet_prop.y = self.pos.x+1 + shot_vec.x,
											 self.pos.y+1 + shot_vec.y 

	self.bullet_prop.w, self.bullet_prop.h = (self.bullet_length * shot_vec.x) + 1,
											 (self.bullet_length * shot_vec.y) + 1
	
	print("bullet_prop:"..self.bullet_prop.x..",".. self.bullet_prop.y..","..
											self.bullet_prop.h..",".. self.bullet_prop.w)											 
end

-- Checks if the player is colliding with a certain 
function Player:check_collisions(...)
	local collision_detected = false
	local pos_in = {...}
	if type(pos_in[1][1]) ~= "number" then
		pos_in = pos_in[1]
	end

	for k, p in pairs(pos_in) do
		for i = 0, self.size - 1, 1 do
			for j = 0, self.size -1, 1 do 
				t_p = {self.pos.x + i, self.pos.y + j}
				--print( "t_p:",t_p[1], t_p[1],"  p:", p[1],p[2])
				if p[1] == t_p[1] and p[2] == t_p[2] then
					collision_detected = true
				end
			end
		end
	end

	return collision_detected
end

function Player:show()
	love.graphics.setColor(color[1])
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.size, self.size)

	if self.firing == true then
		if love.timer.getTime() - self.fired_time > self.bullet_life then
			self.firing = false
		else
			love.graphics.setColor(color[1])
			love.graphics.rectangle("fill", self.bullet_prop.x, self.bullet_prop.y,
											self.bullet_prop.w, self.bullet_prop.h)
		end
	end   
end

--Returns all the point thatmake up the pixels in the players sprite
function Player:get_body()
	local t_body = {}
	for i = 0, self.size - 1, 1 do
		for j = 0, self.size -1, 1 do 
			local t_p = {self.pos.x + i, self.pos.y + j}
			table.insert(t_body, {t_p[1], t_p[2]})
		end
	end

	return t_body
end


