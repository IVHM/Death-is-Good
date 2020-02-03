--- DEATH IS GOOD
--    ___           _   _        _____                             _ 
--   /   \___  __ _| |_| |__     \_   \___    __ _  ___   ___   __| |
--  / /\ / _ \/ _` | __| '_ \     / /\/ __|  / _` |/ _ \ / _ \ / _` |
-- / /_//  __/ (_| | |_| | | | /\/ /_ \__ \ | (_| | (_) | (_) | (_| |
--/___,' \___|\__,_|\__|_| |_| \____/ |___/  \__, |\___/ \___/ \__,_|
--                                           |___/                   
--
-- A Nokia 3310 Game Jam Submission
-- Created 1/31/20
-- By Hendrik M

-- Entity libraries
require("Enemy")
require("Player")
require("Sprite_sheets")



function love.load()
	-- WINDOW DATA
	screen_width = 84    --The base screen size
	screen_height = 48
	padding = 3          --How far off the screen enemies can move
	scaled = true
	scale = 6            --Scaling factor for readability
	screen_size = {["w"]=screen_width*scale, --Scaled screen size
				   ["h"]=screen_height*scale} 
	
	screen_center = {["x"]=screen_width/2, ["y"]= screen_height/2}
	love.window.setMode(screen_size.w, screen_size.h) -- sets the screen size
	
	print("Window stats:\n"..screen_center.x.." : "..screen_center.y)

	-- COLORS AND FONT
	color = {{0.78, 0.94,0.85},{0.26,0.32,0.24}}	

	enemies = {}
	max_enemies = 10
	tot_enemies = 0
	enemy_spawn_delay = 1.5
	last_spawn_time = love.timer.getTime()
	--table.insert(enemies, 1, Enemy:new(nil))
	--enemies[1]:init_values({x=10,y=10}, {x=0,y=-1}, "base")
	for i = 1, max_enemies, 1 do
		spawn_enemy(true)
	end

	-- Lives_counter 
	lives_counter_pos = {x=6,y=screen_height-5}

end


function love.update( ... )
	mov_vec = {x=0,y=0}
	bullet_vec = {x=0,y=0}
	crnt_time = love.timer.getTime()
	


	-- MOVEMENT CONTROLS
	if crnt_time - Player.last_move_time >= Player.move_cooldown then -- constrains movement to frame ticks
		if (love.keyboard.isDown("w") and Player.pos.y>1) then
			mov_vec.y = -1
		elseif (love.keyboard.isDown("s") and Player.pos.y<screen_height-Player.size/2) then
			mov_vec.y = 1	
		elseif (love.keyboard.isDown("a") and Player.pos.x>1) then	
			mov_vec.x = -1
		elseif (love.keyboard.isDown("d") and Player.pos.x<screen_width-Player.size/2) then
			mov_vec.x = 1
		end
		
		if mov_vec.x ~= 0 or mov_vec.y ~= 0 then
			Player.last_move_time = crnt_time
			Player:move(mov_vec)
		end

		--PLAYER?ENEMY COLLISION HANDELING
		if #enemies > 0 then
			local exploding = false
			for k, c_enemy in pairs(enemies) do 
				if Player:check_collision(c_enemy.body) then
					if Player:was_hit() then
						enemies[k] = nil
						exploding = true
					end
					print("collision detected")
				end
			end

			-- KAMIKAZE MECHANIC
			if exploding then
				for i = -1, 4, 1 do 
					for j = -1, 4,1 do 
						for k, crnt_enemy in pairs(enemies) do
							local t_p = {x = Player.pos.x + i,
										 y = Player.pos.y + j}
							if crnt_enemy:check_collision(t_p) then
								enemies[k] = nil
							end
						end 
					end
				end
			end
		end
	end


	-- FIRING CONTROLS
	if crnt_time - Player.last_shot_time >= Player.shoot_cooldown then
		if love.keyboard.isDown("up") then
			bullet_vec.y = -1
		elseif love.keyboard.isDown("down") then
			bullet_vec.y = 1
		elseif love.keyboard.isDown("right") then
			bullet_vec.x = 1
		elseif love.keyboard.isDown("left") then
			bullet_vec.x = -1
		end

		if bullet_vec.x ~= 0 or bullet_vec.y ~= 0 then
			Player.last_shot_time = crnt_time
			local bul_len = nil
			local bul_end_pos = nil
			if Player.ammo > 0 then
				bul_len, bul_end_pos = bullet_collision(Player.pos, bullet_vec)
				Player:shoot(bullet_vec, bul_len)
			end 
		end
	end	

	for k,v in pairs(enemies) do
		v:move()
	end

	-- ENEMY SPAWN CONTROLS
	if tot_enemies < max_enemies then
		if crnt_time - last_spawn_time > enemy_spawn_delay then
			spawn_enemy(true)
		end
	end
end


function love.draw( ... )
	
	love.graphics.push()
	love.graphics.scale(scale,scale)
	Player:show()
	
	for k,v in pairs(enemies) do
		v:show()
	end

	draw_lives_counter(lives_counter_pos, Player.lives)
	love.graphics.pop()
end


function spawn_enemy(random, new_pos_in, new_normal_in, new_variant)
	
	if random then
		local new_pos = {x=math.random(0, screen_width),
						 y=math.random(0, screen_height)}
		
		-- RANDOMLY SELECT A VARIANT USING THE ENEMY SPAWN WEIGHT CHART
		local new_variant = nil
		local t_rand = math.random()
		local t_crnt_STAGE = 1
		for k,v in pairs(variant_ratios) do
			if t_rand <= v[t_crnt_STAGE] then
				new_variant = k
			end
		end
		local new_normal = {x=0,y=-1}
		table.insert(enemies, Enemy:new())
		enemies[#enemies]:init_values(new_pos, new_normal, new_variant)  
	else 
		table.insert(enemies, Enemy:new())
		enemies[#enemies]:init_values(new_pos_in, new_normal_in, new_variant_in)  
	end

	local colliding = true

	while colliding do
		if Player:check_collision(enemies[#enemies].body) then
			new_pos = {x=math.random(0, screen_width),
					   y=math.random(0, screen_height)}
			enemies[#enemies].pos = new_pos
		else
			colliding = false
			break
		end
	end 


	tot_enemies = tot_enemies + 1     
end



function bullet_collision(start_pos, bull_vec_in)
	local distance_traveled = 0
	print("start_pos:", start_pos.x,start_pos.y)
	print("bullet_vec:", bull_vec_in.x,bull_vec_in.y)
	local crnt_pos = {x = start_pos.x + 1 + bull_vec_in.x,
					  y = start_pos.y + 1 + bull_vec_in.y}
	local calculating = true

	while calculating do
		-- Increment the ray path and distance measurement 
		crnt_pos = {x = crnt_pos.x + bull_vec_in.x,
					y = crnt_pos.y + bull_vec_in.y}
		distance_traveled = distance_traveled + 1

		for k,v in pairs(enemies) do
			if v:check_collision(crnt_pos) then
				print("enemy Hit")
				enemies[k] = nil
				Player:add_life()
				calculating = false
				tot_enemies = tot_enemies - 1
				break
			end
		end

		if calculating then
			if crnt_pos.x < -5 or crnt_pos.x > screen_width + 5 or
			   crnt_pos.y < -5 or crnt_pos.y > screen_height + 5 then
			 	print("NO enemy hit")
			 	calculating = false
			end
		end

	end

	return distance_traveled, crnt_pos


end

