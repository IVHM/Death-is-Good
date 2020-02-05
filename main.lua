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

	-- GAME STATES
	current_state = {	
		start = true,
		restart = false,
		running = false,
		game_over = false}

	enemies = {}
	default_max_enemies = 10
	max_enemies = 10
	tot_enemies = 0
	default_enemy_spawn_delay = .5
	enemy_spawn_delay = .5
	enemy_spawn_delay_increment = .002

	tot_enemies_increment_delay = 3
	last_tot_enemies_increment = love.timer.getTime()


	last_spawn_time = love.timer.getTime()

	--table.insert(enemies, 1, Enemy:new(nil))
	--enemies[1]:init_values({x=10,y=10}, {x=0,y=-1}, "base")
	for i = 1, max_enemies, 1 do
		spawn_enemy(true)
	end

	-- Lives_counter 
	lives_counter_pos = {x=6,y=screen_height-5}

	--SCORE
	start_time = love.timer.getTime()
	end_time = nil
	elapsed_time = {min=0,sec=0}
	total_score = 0
	score_increment_delay = 3
	last_score_increment = love.timer.getTime()


	--Image rferences
	game_over_image = love.graphics.newImage("Gameover-1.png")
	game_over_image:setFilter("nearest","nearest")
	main_screen = {love.graphics.newImage("Main_screen-1.png"),
				   love.graphics.newImage("Main_screen-2.png")}
	main_screen[1]:setFilter("nearest")
	main_screen[2]:setFilter("nearest")
	main_screen_delay = .25
	crnt_main_screen_frame = 1
	last_main_screen = love.timer.getTime()
end


function love.update( ... )
	local mov_vec = {x=0,y=0}
	local bullet_vec = {x=0,y=0}
	local crnt_time = love.timer.getTime()
	
	if current_state.start then
		if love.keyboard.isDown("r") then
			current_state.start = false
			current_state.running = true
		end
		if crnt_time - last_main_screen > main_screen_delay then
			last_main_screen = crnt_time
			if crnt_main_screen_frame == 1 then
				crnt_main_screen_frame = 2
			else 
				crnt_main_screen_frame =1
			end
		end

	-- RESTART FROM GAMEOVER
	elseif current_state.restart then
		Player:respawn()
		total_score = 0
		start_time = crnt_time
		max_enemies = default_max_enemies
		enemy_spawn_delay = default_enemy_spawn_delay

		for i =1, 10, 1 do 
			spawn_enemy()
		end

		current_state.running = true
		current_state.restart = false

	-- MAIN RUNNING STATE
	elseif current_state.running then

		--SCORE INCREMENTING
		if crnt_time - last_score_increment > score_increment_delay then
			last_score_increment= crnt_time
			total_score = total_score + 1
		end

		-- ENEMEY SPAWN INCREMENTING
		if crnt_time - last_tot_enemies_increment > tot_enemies_increment_delay then
			last_tot_enemies_increment = crnt_time
			max_enemies = max_enemies + 1
			enemy_spawn_delay = enemy_spawn_delay - enemy_spawn_delay_increment
		end

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

			if Player.gameover then
				current_state.game_over = true
			end

			--PLAYER?ENEMY COLLISION HANDELING
			if #enemies > 0 then
				local exploding = false
				for k, c_enemy in pairs(enemies) do 
					if Player:check_collision(c_enemy.body) then
						if Player:was_hit() then
							remove_enemy(k)
							Player:lose_life()
							total_score = total_score - 2
							if total_score < 0 then total_score = 0 end
							if Player.gameover then
								end_time = crnt_time
								get_elapsed_time()
								current_state.game_over = true
								current_state.running = false
							end
							exploding = true
						end
					end
				end

				-- KAMIKAZE MECHANIC
				if exploding then
					for i = -5, 8, 1 do 
						for j = -5, 8,1 do 
							for k, crnt_enemy in pairs(enemies) do
								local t_p = {x = Player.pos.x + i,
											 y = Player.pos.y + j}
								if crnt_enemy:check_collision(t_p) then
									remove_enemy(k)
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
			if v:move() then
				remove_enemy(k)
			end
		end

		-- ENEMY SPAWN CONTROLS
		if tot_enemies < max_enemies then
			if crnt_time - last_spawn_time > enemy_spawn_delay then
				spawn_enemy(true)
			end
		end

		if Player.gameover then
			current_state.game_over = true
		end

	elseif current_state.game_over then
		if love.keyboard.isDown("r") then
			current_state.game_over = false
			current_state.restart = true
		end
		for k,v in pairs(enemies) do
			remove_enemy(k)
		end
	end
end



-- Responsible for putting everything on the screen
-- ALL love.graphics calls must be called in thsi scope to render
function love.draw( ... )
	
	--Scaled graphics go here
	love.graphics.push()
	love.graphics.scale(scale,scale)

	-- START SCREEN
	if current_state.start then
		love.graphics.draw(main_screen[crnt_main_screen_frame],0,0)

	-- MAIN SCREEN
	elseif current_state.running then
		love.graphics.setColor(color[2])
		love.graphics.rectangle("fill",0,0,screen_width, screen_height)	
		Player:show()
		
		for k,v in pairs(enemies) do
			v:show()
		end

		draw_lives_counter(lives_counter_pos, Player.lives)

	-- GAMEOVER SCREEN
	elseif current_state.game_over then
		love.graphics.setColor(color[2])
		love.graphics.rectangle("fill",0,0,84,48)
		love.graphics.draw(game_over_image, 20,10)
		love.graphics.setColor(color[1])
		draw_lives_counter({x=20,y=28},total_score)
		draw_lives_counter({x=20,y=35}, elapsed_time.min)
		draw_lives_counter({x=29,y=35}, elapsed_time.sec)

	end
	love.graphics.pop()
end


function remove_enemy(key_in)
	local t_variant = enemies[key_in].variant
	if variant == "light" then
		total_score = total_score + 2
	elseif variant == "medium" then
		total_score = total_score + 4
	else
		total_score = total_score + 8
	end
	enemies[key_in] = nil
	tot_enemies = tot_enemies - 1

end


function spawn_enemy(random, new_pos_in, new_normal_in, new_variant)
	
	if random then
		local new_pos = {x=math.random(padding, screen_width - padding),
						 y=math.random(padding, screen_height - padding)}
		
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
			new_pos = {x=math.random(padding, screen_width - padding),
  			 		   y=math.random(padding, screen_height - padding)}			
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
	--print("start_pos:", start_pos.x,start_pos.y)
	--print("bullet_vec:", bull_vec_in.x,bull_vec_in.y)
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
				total_score = total_score + 1
				Player:add_life()
				calculating = false
				tot_enemies = tot_enemies - 1
				break
			end
		end

		if calculating then
			if crnt_pos.x < -5 or crnt_pos.x > screen_width + 5 or
			   crnt_pos.y < -5 or crnt_pos.y > screen_height + 5 then
			 	--print("NO enemy hit")
			 	calculating = false
			end
		end

	end

	return distance_traveled, crnt_pos


end

function get_elapsed_time()
	local t_elap = math.ceil(end_time - start_time)
	elapsed_time.sec = t_elap % 60
	elapsed_time.min = (t_elap - elapsed_time.sec)/60

end
