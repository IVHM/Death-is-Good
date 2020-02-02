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



function love.load()
	-- WINDOW DATA
	screen_width = 84    --The base screen size
	screen_height = 48
	scaled = true
	scale = 6          --Scaling factor for readability
	screen_size = {["w"]=screen_width*scale, --Scaled screen size
				   ["h"]=screen_height*scale} 
	
	screen_center = {["x"]=screen_width/2, ["y"]= screen_height/2}
	love.window.setMode(screen_size.w, screen_size.h) -- sets the screen size
	
	print("Window stats:\n"..screen_center.x.." : "..screen_center.y)

	-- COLORS AND FONT
	color = {{0.78, 0.94,0.85},{0.26,0.32,0.24}}	

	enemies = {}
	table.insert(enemies, 1, Enemy:new(nil))
	enemies[1]:init_values({x=10,y=10}, {x=0,y=-1}, "base")
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

		if #enemies > 0 then
			for k, c_enemy in pairs(enemies) do 
				if Player:check_collision(c_enemy.body) then
					print("collision detected")
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
			local bul_len, bul_end_pos = bullet_collision(Player.pos, bullet_vec)
			Player:shoot(bullet_vec)
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
	love.graphics.pop()
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
				calculating = false
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

