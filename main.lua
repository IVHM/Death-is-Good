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
require("UTIL")



function love.load()
	-- WINDOW DATA
	screen_width = 84    --The base screen size
	screen_height = 48
	scaled = true
	scale = 6          --Scaling factor for readability
	screen_size = {["w"]=screen_width * scale, --Scaled screen size
				   ["h"]=screen_height * scale} 
	
	screen_center = {["x"]=screen_width/2, ["y"]= screen_height/2}
	love.window.setMode(screen_size.w, screen_size.h) -- sets the screen size
	
	print("Window stats:\n"..screen_center.x.." : "..screen_center.y)

	-- COLORS AND FONT
	color = {{0.78, 0.94,0.85},{0.26,0.32,0.24}}	

	enemies = {}
	table.insert(enemies, 1, Enemy:new(nil))
	enemies[1]:init_values({10,10}, {0,-1}, "base")
end


function love.update( ... )
	local mov_vec = {x=0,y=0}
	local bullet_vec = {x=0,y=0}
	local crnt_time = love.timer.getTime()
	
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
				if Player:check_collisions(c_enemy.body) then
					print("player collision detected TABLE")
				end
				--if Player:check_collisions({Player.pos.x, Player.pos.y}) then
			    --	print("player collision detected POINT")
				--end
				--if c_enemy:check_collisions(Player:get_body()) then
				--	print("Enemy collision detected TABLE")
				--end
				--if c_enemy:check_collisions({10,9}) then
				--	print("Enemy collision detected POINT")
				--end
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
--			print(Player.pos.x+1+bullet_vec[1])
			calculate_player_bullet(bullet_vec,{Player.pos.x+1+bullet_vec.x,
												Player.pos.y+1+bullet_vec.y})
			Player:shoot(bullet_vec)


		end
	end	
end


-- Responsible for putting everything on the screen
-- ALL love.graphics calls must be called in thsi scope to render
function love.draw( ... )
	
	--Scaled graphics go here
	love.graphics.push()
	love.graphics.scale(scale,scale)
	Player:show()
	enemies[1]:show()
	love.graphics.pop()
end

function calculate_player_bullet(bul_vec, start_pos)
	
	local bul_vec = bul_vec      --what direction the bullet is heading in
	local start_pos = start_pos  -- where the bullet begins it's path
	start_pos = indexed_to_vector(start_pos)
	local crnt_pos = start_pos   -- Where the bullet is now in calculations
	local dis_traveled = 0  	 -- How many steps the bullet has travelled so far
	local calculating = true     -- Whether the algorithm has reached finish

	-- Iterates over enemies list and checks for collisions
	while calculating do
		for k,v in pairs(enemies) do
			if dis_between(crnt_pos, v.pos) < 1.5 then
				if v:check_collisions(crnt_pos) then
					enemies[k] = nil
					calculating = false
					print("enemy :"..k.." hit by bullet")
				end
			end
		end

		--if no collision detected increment the raycast 
		if calculating then
			crnt_pos.x, crnt_pos.y = crnt_pos.x + bul_vec.x,
					   				  crnt_pos.y + bul_vec.x
			dis_traveled = dis_traveled + 1
		end

		if crnt_pos.x < -5 or crnt_pos.x > screen_width + 5 or
		   crnt_pos.y < -5 or crnt_pos.y > screen_height + 5 then
		   	calculating = false	
		end
	end

	return dis_traveled, crnt_pos
end



