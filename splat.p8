pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--setup
--웃

splats={}
cheese={}
switches={}
gates={}
crates={}
t_flow = 28
player={}
trans={}
debug=false
level=4
next_level=1
init_lvl=false
fin={}
steps=0

function _init()
	trans.x = 0
	trans.y = -128
	trans.vis= false
	trans.t_s = 0
	trans.init = false
	
	player.x = 48
	player.y = 48
	player.m = false
	player.x_m = 48
	player.y_m = 48
	player.t_s = 0
	player.e = 3
	fin.x = 0
	fin.y = 0
	fin.a = 10
	
	load_lvls()
	init_lvl(level)
end

function _update()
	if (time() % 1 == 0.1) then
		flow()
		distribute_flow()
	end
	
	player_movement()
	check_fin()
	check_cheese()
	check_switches()
	check_gates()
	check_crates()
end


function _draw()
	set_splats()
	draw_bg()
	
	draw_fin()
	draw_cheese()
	draw_switches()
	draw_gates()
	draw_crates()
	draw_player()
	
	draw_trans()
	draw_ui()
	draw_debug()
	
	if btnp(4) then
		start_trans(false)
	end
	
	
end

function draw_bg()

	rectfill(0,0,128,128,0)
	
	for i=0,120, 8 do
		for j=0,120, 8 do
			spr(14,i,j)
		end
	end
	
	
	map(0, 0, 0, 0)
end

function draw_ui()

	--DRAW LEVEL UI
	
	for i=8,104,8 do
		spr(37,120,i)
	end
	
	spr(40,120,0)
	
	for i=8,112,8 do
		spr(53,i,0)
	end
	
	spr(38,0,0)
	
	for i=8,104,8 do
		spr(37,0,i)
	end
	
	spr(21,0,112)
	
	for i=8,112,8 do
		spr(39,i,112)
		spr(55,i,120)
	end
	
	spr(54,0,120)
	spr(5,120,112)
	spr(56,120,120)
	
	--CHEESE
	spr(27,102,116)
	print(player.e,114,118,1)
	print(player.e,114,117,7)
	
	--STEPS
	print("웃 ", 75, 118, 1)
	print("웃 ", 75, 117, 12)
	print(steps, 86, 118,1)
	print(steps, 86, 117,7)
	
	--LEVEL
	print("LEVEL ".. level,8,118,1)
	print("LEVEL ".. level,8,117,7)

end

function draw_fin()
	spr(fin.a, fin.x,fin.y)
	
	if ((time() * 16) % 1 == 0) then
		fin.a+=1
	end
	
	if fin.a > 13 then
		fin.a = 10
	end
end

function draw_crates()
	for i=1,#crates do
		if crates[i].g == false then
			spr(24,crates[i].x,crates[i].y)
		end
	end
end

function add_crate(x,y)

	local c = {}
		c.x=x
		c.y=y
		c.g=false
		crates[#crates+1] = c
end

function check_crates()
	for i=1,#crates do
		for j=1,#switches do
			if crates[i].x == switches[j].x and 
			   crates[i].y == switches[j].y and 
			   crates[i].g == false then
				crates[i].g = true
				add_splat(crates[i].x,crates[i].y,8,8,4)
			end
		
		end
	end

end

function draw_cheese()

	for i=1,#cheese do
		if cheese[i].eaten == false then
			spr(26,cheese[i].x,cheese[i].y)
		end
	end

end

function add_cheese(x,y,n)
	local c = {}
		c.x=x
		c.y=y
		c.n=n
		c.eaten = false
		cheese[#cheese+1] = c
end

function check_cheese()
	
	for i=1,#cheese do
		if cheese[i].eaten == false and player.x == cheese[i].x and player.y == cheese[i].y then
			cheese[i].eaten = true
			player.e += cheese[i].n
			sfx(2)
			--cheese yum sound
		end
	end
end

function draw_switches()
	for i=1,#switches do
		if switches[i].on == true then
			spr(43,switches[i].x,switches[i].y)
		else
			spr(42,switches[i].x,switches[i].y)
		end
	end
end

function add_switch(x,y,n)
	local s = {}
	s.x = x
	s.y = y
	s.n = n
	s.on = false
	switches[#switches+1] = s
end

function check_switches()
	for i=1,#switches do
		if is_splat(switches[i].x,switches[i].y) == true then
			switches[i].on = true
		else
			switches[i].on = false
		end
	end
end

function draw_gates()
	for i=1,#gates do
		if gates[i].open == true then
			spr(58,gates[i].x,gates[i].y)
		else
			spr(57,gates[i].x,gates[i].y)
		end
	end
end

function add_gate(x,y,n)
	local g = {}
	g.x = x
	g.y = y
	g.n = n
	g.open = false
	gates[#gates+1] = g
end

function check_gates()
	for i=1,#gates do
		for j=1, #switches do
			if gates[i].n == switches[j].n and switches[j].on == true and gates[i].open == false then
				sfx(4)
				gates[i].open = true
			elseif gates[i].n == switches[j].n and switches[j].on == false then
				gates[i].open = false
			end
		end
	end
end

function check_fin()

	if player.x == fin.x and
		player.y == fin.y then
			start_trans(true)
	end
end

function draw_trans()

	if trans.vis == true then
		
		local timer=(time()-trans.t_s )
			/1%1
			
			if timer > 0.95 then
				trans.vis = false
				trans.t_s = 0
			end
			
			if timer > 0.5 and
				trans.init == false then
				
				init_lvl(level)
				trans.init = true
				
			end
			
			trans.y = lerp(-136,
			128,smooth_step(timer))
			
			build_trans()
	end
	
end

function build_trans()
	rectfill(0,trans.y,
				128,trans.y+128,8)
				
	for i=0,128,8 do
		spr(59,i,trans.y-8)
		spr(59,i,trans.y+128,
			1,1,false,true)
	end
end

function start_trans(comp)
	if trans.vis == false then
		trans.vis = true
		trans.t_s = time()
		trans.init = false
		if comp == true then
			level = level + 1
		end
	end
end

function set_splats()
	for i=1,#splats do
		splat(splats[i])
	end
end


function splat(sp)

	local spr_ind = 
		splat_spr(sp.x,sp.y)
	
	local t_x = 
		((sp.x - (sp.x % 8)) / 8)
	local t_y = 
		((sp.y - (sp.y % 8)) / 8)
	
	mset(t_x,t_y,spr_ind)
	
end

function splat_spr(x,y)

	local spr_ind
	local top = false
	local bot = false
	local left = false
	local right = false

	if is_splat(x,y+8)==true then
		bot = true
	end
	if is_splat(x,y-8)==true then
		top = true
	end
	if is_splat(x-8,y)==true then
		left = true
	end
	if is_splat(x+8,y)==true then
		right = true
	end
	
	local w_top = false
	local w_bot = false
	local w_left = false
	local w_right = false
	
	if is_wall(x,y+8)==true then
		w_bot = true
	end
	if is_wall(x,y-8)==true then
		w_top = true
	end
	if is_wall(x-8,y)==true then
		w_left = true
	end
	if is_wall(x+8,y)==true then
		w_right = true
	end
	
	
	
	if top == true 
		and bot == true 
		and left == true 
		and right == true then
		
		spr_ind = 4
	elseif left==true 
		and right==true
		and bot==true then
		
		spr_ind=3
	elseif top==true 
		and bot==true
		and left==true then
		
		spr_ind=19
	elseif left==true 
		and right==true
		and top==true then
		
		spr_ind=35
	elseif top==true 
		and bot==true
		and right==true then
		
		spr_ind=51
	elseif left==true
		and bot == true then
		
		spr_ind = 2
		
	elseif right==true
		and bot==true then
		
		spr_ind = 18
	elseif top==true 
		and right==true then
		
		spr_ind = 34
	elseif top==true
		and left==true then
		
		spr_ind =50
	elseif top==true
		and bot==true then
		
		spr_ind =20
	elseif left==true
		and right==true then
		
		spr_ind =36
		
	elseif w_top==true
		and w_right==true
		and w_left==true
		and bot==true then
		
		spr_ind =52
		
	elseif w_right==true
		and w_top==true
		and w_bot==true
		and left==true then
		
		spr_ind =16
		
	elseif w_bot==true
		and w_left==true
		and w_right==true
		and top==true then
		
		spr_ind =32
		
	elseif w_left==true
		and w_top==true
		and w_bot==true
		and right==true then
		
		spr_ind =48
		
	elseif bot==true then
		spr_ind=1
	elseif left==true then
		spr_ind=17
	elseif top==true then
		spr_ind=33
	elseif right==true then
		spr_ind=49
	else
		spr_ind = 6
	end
	
	
	return spr_ind
	
end

function is_splat(x,y)

	local t_x = 
		((x - (x % 8)) / 8)
	local t_y = 
		((y - (y % 8)) / 8)
		
		
	s_s = {1,2,3,4,5,6,18,34,
		17,33,49,50,3,19,35,51,20,36,
		52,16,32,48}
		
		
	for i=1,#s_s do
		if mget(t_x,t_y) == s_s[i] 
			then
			return true
		end
	end
	return false
 
end


function is_wall(x,y)

	local t_x = ((x - (x % 8)) / 8)
	local t_y = ((y - (y % 8)) / 8)
	
	

	if mget(t_x,t_y) ==7 or
		mget(t_x,t_y) == 8 or
		mget(t_x,t_y) == 23 then
		return true
	else
		for i=1,#gates do
			if gates[i].x == x and gates[i].y == y and gates[i].open == false then
				return true
			end
		end
		
		if is_crate(x,y) == true then
			return true
		end
		
		return false
 end
 
end


function is_crate(x,y)
	for i=1,#crates do
		if crates[i].x == x and crates[i].y == y then
			return true
		end
	end
	return false
end

function move_crate(x,y,x_m,y_m)
	for i=1,#crates do
		if crates[i].x == x and crates[i].y == y then
			crates[i].x = x_m
			crates[i].y = y_m
			return 
		end
	end
	return
end



function add_splat(x,y,si,c,f)
	if is_splat(x,y)==false then
		local s = {}
		s.x=x
		s.y=y
		s.s=si
		s.c=c
		s.f=f
		
		splats[#splats+1] = s
		splat(s)
		t_flow-=1
	end
end

function get_splat(x,y)
	local s = "null"
	for i=1,#splats do
	
		local spl = splats[i]
			
		if spl.x == x and spl.y == y then
			s = spl
		end
	end
	return s
end


-->8
--flow
function flow()

	for i=1,#splats do
	
		local spl = splats[i]
		
		if t_flow > 0 then
		
  	if is_wall(spl.x,spl.y+8)
  	==false then
  		add_splat(spl.x,spl.y+spl.s,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x,spl.y-8)
  	==false then
  		add_splat(spl.x,spl.y-spl.s,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x-8,spl.y)
  	==false then
  		add_splat(spl.x-spl.s,spl.y,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x+8,spl.y)
  	==false then
  		add_splat(spl.x+spl.s,spl.y,
					spl.s,spl.c,spl.f-1)
  	end
				
				spl.f = spl.f - 1
				
		end
	end

end


function distribute_flow()

	local ed_spl 
		= get_edge_splats()
		
	local flow = drain_flow()
	
	local new_f 
		= flr(flow / #ed_spl)
	
	for i=1,#ed_spl do
		local spl = ed_spl[i]
		spl.f=new_f
	end
	
end



function get_edge_splats()

	local ed_spl = {}

	for i=1,#splats do
	
		local spl = splats[i]
		local w_no = 
			count_walls(spl.x,spl.y)
		local s_no = 
			count_splats(spl.x,spl.y)
			
		if w_no + s_no != 4 then
			ed_spl[#ed_spl+1] = spl
		end
	end
	
	return ed_spl

end

function drain_flow()

	local f=0
	
	for i=1,#splats do
		local spl=splats[i]
		
		if spl.f>0 then
			f += spl.f
		end
		
		spl.f = 0
		
	end
	
	return f

end



function count_walls(x,y)
	local w = 0
	if is_wall(x,y+8)==true then
		w = w + 1
	end
	if is_wall(x,y-8)==true then
		w = w + 1	
	end
	if is_wall(x+8,y)==true then
		w = w + 1
	end
	if is_wall(x-8,y)==true then
		w = w + 1	
	end
	return w
end

function count_splats(x,y)

	local s = 0
	
	if is_splat(x,y+8)==true then
 	s += 1
 end
 if is_splat(x,y-8)==true then
 	s += 1	
 end
 if is_splat(x+8,y)==true then
 	s += 1
 end
 if is_splat(x-8,y)==true then
 	s += 1	
 end
 
 return s

end




function get_sur_splats(x,y)

	local l_splats = {}
	local i = 1
	local t_s = get_splat(x,y-8)
	local b_s = get_splat(x,y+8)
	local l_s = get_splat(x-8,y)
	local r_s = get_splat(x+8,y)
	
	if t_s !="null" then
		l_splats[i] = t_s
		i = i + 1
	end
	
	if b_s !="null" then
		l_splats[i] = b_s
		i = i + 1
	end
	
	if l_s !="null" then
		l_splats[i] = l_s
		i = i + 1
	end
	
	if r_s !="null" then
		l_splats[i] = r_s
		i = i + 1
	end
	
	return l_splats
	
end

function get_splat(x,y)

	for i=1,#splats do
	 local spl = splats[i]
	
		if spl.x == x and
			spl.y == y then
			
			return spl
			
		end
	end
	
	return "null"

end
-->8
--player
function draw_player()
	spr(25, player.x,player.y)
end

function player_movement()

	if player.x == player.x_m
			or player.y == player.y_m 
			then
 	if btnp(0) and
 		player.m == false then
 		try_move(player.x-8,player.y)
 	end
 	if btnp(1) and
 		player.m == false then
 		try_move(player.x+8,player.y)
 	end
 	if btnp(2) and
 		player.m == false then
 		try_move(player.x,player.y-8)
 	end
 	if btnp(3) and
 		player.m == false then
 		try_move(player.x,player.y+8)
 	end
	end

	if player.x != player.x_m
			or player.y != player.y_m 
			then
			
			player.m = true
		
		local timer=(time()-player.t_s )
			/0.2%1
			
			if timer==1then
				return
			end
		
		player.x = lerp(player.x,
			player.x_m,ease_out(timer))
			
		player.y = lerp(player.y,
			player.y_m,ease_out(timer))
	else
		player.m = false
	end

end

function try_move(x,y)
	if is_wall(x,y)==false then
		if is_crate(x,y) == false then
			player.x_m=x
			player.y_m=y
			player.m=true
			sfx(0)
			player.t_s=time()
			steps+=1
			return true
		end
	else
		if is_crate(x,y) == false then
			break_wall(x,y)
		else 
			local x_m =  (x - player.x) + x
			local y_m =  (y - player.y) + y
			
			if is_wall(x_m,y_m) == false and is_splat(x_m,y_m) == false then
				sfx(3)
				move_crate(x,y,x_m,y_m)
			end
		end
		return false
	end
end

function break_wall(x,y)
	if player.e <= 0 then
		return
	end
	
	for i=1,#gates do
		if gates[i].x == x and gates[i].y == y and gates[i].open == false then
			return true
		end
	end
	
	local b_x = 
		((x - (x % 8)) / 8)
	local b_y = 
		((y - (y % 8)) / 8)
		
	if (mget(b_x,b_y) == 7) then
		sfx(1)
		mset(b_x,b_y,23)
	elseif 
		(mget(b_x,b_y) 	== 8) then
	else 
		sfx(1)
		player.e -= 1
		mset(b_x,b_y,0)
	end
	
end

function lerp(a,b,t)

	if b<a then
		return flr(a + (b-a)*t)
	else 
		return ceil(a + (b-a)*t)
	end
end

function ease_out(t)
	return 1-(1-t)^2
end

function smooth_step(t)
	return (t^2)*(1-t) +
		(1-(1-t)^2)*t;
end
-->8
--debug
function draw_debug()
	if debug==true then
		print(player.x .. " " ..
		player.y,16,16,10)
		print(fin.x .. " " ..
		fin.y,16,24,10)

		
	end
end
-->8
--particle fx
-->8
--level creation

levels={}

function load_lvls()

	levels[1] = lvl_1()
	levels[2] = lvl_2()
	levels[3] = lvl_3()
	levels[4] = lvl_4()
	levels[5] = lvl_5()
	levels[6] = lvl_6()
	levels[99] = test_lvl()

end


function test_lvl()

	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	lvl_a = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,
			 2,1,1,0,0,0,0,0,0,0,0,0,0,2,
	         2,1,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,1,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,1,1,1,0,0,0,0,0,0,0,0,0,2,
	         2,1,0,1,0,0,0,0,0,0,0,0,1,2,
	         2,1,1,1,0,0,0,0,0,0,0,1,1,2,
	         2,2,2,2,2,2,2,2,2,2,2,2,2,2}
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=11*8
		player.y_m=11*8
		fin.x=12*8
		fin.y=3*8
		add_splat(8*5,8*6,8,8,4)
		
		add_splat(8*10,8*6,8,8,4)
		--add_switch(8,24,1)
		--add_cheese(48,48)
		--add_gate(8,32,1)
		--add_splat(72,64,8,8,4)

	end
		
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end



function lvl_1()

	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	lvl_a = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,
			 2,1,1,0,0,0,2,2,0,0,0,1,1,2,
	         2,1,0,0,0,0,2,2,0,0,0,0,1,2,
	         2,0,0,0,0,0,2,2,0,0,0,0,0,2,
	         2,0,0,0,0,0,2,2,0,0,0,0,0,2,
	         2,0,0,0,0,0,1,1,0,0,0,0,0,2,
	         2,0,0,0,0,0,1,1,0,0,0,0,0,2,
	         2,0,0,0,0,0,1,1,0,0,0,0,0,2,
	         2,0,0,0,0,0,2,2,0,0,0,0,0,2,
	         2,0,0,0,0,0,2,2,0,0,0,0,0,2,
	         2,1,0,0,0,0,2,2,0,0,0,0,1,2,
	         2,1,1,0,0,0,2,2,0,0,0,1,1,2,
	         2,2,2,2,2,2,2,2,2,2,2,2,2,2}
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=7*8
		player.y_m=7*8
		fin.x=12*8
		fin.y=7*8
		--add_splat(8,8,8,8,4)
		--add_switch(8,24,1)
		--add_cheese(48,48)
		--add_gate(8,32,1)
		--add_splat(72,64,8,8,4)

	end
		
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_2()

	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	lvl_a = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,
			 1,1,1,0,0,0,1,1,0,0,0,1,1,1,
	         1,1,0,0,0,0,0,0,0,0,0,0,1,1,
	         1,0,0,0,0,0,0,0,0,0,0,0,0,1,
	         1,0,0,0,0,0,0,0,0,0,0,0,0,1,
	         1,0,0,0,0,0,0,0,0,0,0,0,0,1,
	         1,0,0,0,0,0,0,0,0,0,0,0,0,1,
	         1,1,0,0,0,0,0,0,0,0,0,0,1,1,
	         1,1,1,0,0,0,0,0,0,0,0,1,1,1,
	         1,1,1,1,0,0,0,0,0,0,1,1,1,1,
	         1,1,1,1,1,0,0,0,0,1,1,1,0,1,
	         1,1,0,1,1,1,0,0,1,1,1,0,0,1,
	         1,1,1,1,1,1,1,1,1,1,1,1,1,1}
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=12*8
		player.y_m=12*8
		fin.x=13*8
		fin.y=12*8
		add_cheese(4*8,4*8,3)
		--add_splat(8,8,8,8,4)
		--add_splat(72,64,8,8,4)
	end
	
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_3()

	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	lvl_a = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,
			 2,0,0,0,1,1,1,1,1,1,0,0,0,2,
	         2,0,0,0,1,1,1,1,1,1,0,0,0,2,
	         2,0,0,0,1,1,1,1,1,1,0,0,0,2,
	         2,1,1,1,1,1,1,1,1,1,1,1,1,2,
	         2,1,1,0,0,0,0,0,0,0,0,0,0,2,
	         2,1,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,0,0,0,0,2,
	         2,0,0,0,0,0,0,0,0,2,2,0,2,2,
	         2,0,0,0,0,0,0,0,0,2,0,0,0,2,
	         2,1,0,0,0,0,0,0,0,2,0,0,0,2,
	         2,1,1,0,0,0,0,0,0,2,0,0,0,2,
	         2,2,2,2,2,2,2,2,2,2,2,2,2,2}
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=9*8
		player.y_m=9*8
		fin.x=12*8
		fin.y=11*8
		add_splat(2*8,3*8,8,8,4)
		add_switch(12*8,3*8,1)
		add_gate(12*8,9*8,1)
		add_cheese(6*8,7*8,3)
		add_cheese(7*8,7*8,3)
		add_cheese(8*8,7*8,3)
		--add_cheese(4*8,4*8,3)
	end
	
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_4()
	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	
	--       1 2 3 4 5 6 7 8 9 0 1 2 3 4
	lvl_a = {0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 1
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 2
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 3
			 1,0,0,0,0,0,0,0,0,0,0,0,0,2, -- 4
			 1,1,0,0,0,0,0,0,0,0,0,0,2,2, -- 5
			 1,1,1,0,0,0,0,0,0,0,0,2,2,2, -- 6
			 0,1,0,1,0,0,0,0,0,0,0,0,0,0, -- 7
			 1,1,1,0,0,0,0,0,0,0,0,2,2,2, -- 8
			 1,1,0,0,0,0,0,0,0,0,0,0,2,2, -- 9
			 1,0,0,0,0,0,0,0,0,0,0,0,0,2, -- 10
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 11
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 12
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- 13
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=12*8
		player.y_m=12*8
		fin.x=14*8
		fin.y=7*8
		--add_splat(2*8,7*8,8,8,4)
		add_gate(12*8,7*8,1)
		add_gate(11*8,7*8,2)
		add_crate(7*8,3*8)
		add_switch(1*8,7*8,1)
		add_switch(3*8,7*8,2)
		--add_cheese(4*8,4*8,3)
	end
	
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_5()
	local lvl = {}
	local r_p = {}
	local r_d = {}
	box_lvl(r_p)
	
	--       1 2 3 4 5 6 7 8 9 0 1 2 3 4
	lvl_a = {0,1,0,1,0,1,0,1,0,2,2,2,2,2, -- 1
			 1,1,1,1,1,1,1,1,1,2,0,0,0,2, -- 2
			 0,1,0,1,0,1,0,0,0,2,0,0,0,2, -- 3
			 1,1,1,1,1,1,1,1,0,2,2,0,2,2, -- 4
			 0,1,1,0,1,0,0,1,0,2,2,0,2,2, -- 5
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 6
			 0,0,1,0,1,0,0,0,0,0,0,0,0,0, -- 7
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 8
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 9
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 10
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 11
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0, -- 12
			 0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- 13
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	local function setup()
		
		player.x=3*8
		player.x_m=3*8
		player.y=11*8
		player.y_m=11*8
		fin.x=12*8
		fin.y=2*8
		add_splat(3*8,3*8,8,8,4)
		
		add_gate(12*8,4*8,1)
		add_switch(9*8,3*8,1)
		
		add_gate(12*8,5*8,2)
		add_switch(7*8,3*8,2)
		
		add_gate(5*8,3*8,3)
		add_switch(2*8,6*8,3)
		
		add_crate(10*8,9*8)
		
		add_cheese(5*8,1*8,3)
		
		--add_cheese(4*8,4*8,3)
	end
	
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_6()
	local lvl = {}
	local r_p = {}
	local r_d = {}
	box_lvl(r_p)
	
	--       1 2 3 4 5 6 7 8 9 0 1 2 3 4
	lvl_a = {1,0,0,0,0,2,2,2,0,0,0,0,0,1, -- 1
			 0,0,0,0,0,0,0,2,0,0,0,0,0,0, -- 2
			 0,0,0,0,0,2,2,2,0,0,0,0,0,0, -- 3
			 0,0,0,0,1,2,2,2,1,0,0,0,0,0, -- 4
			 0,0,0,1,1,2,2,2,1,1,0,0,0,0, -- 5
			 0,0,1,1,1,2,2,2,0,1,1,0,0,0, -- 6
			 0,0,1,1,1,0,0,2,0,1,1,0,0,0, -- 7
			 0,0,0,1,1,2,2,2,1,1,0,0,0,0, -- 8
			 0,0,0,0,1,1,1,1,1,0,0,0,0,0, -- 9
			 0,0,0,0,0,1,1,2,0,0,0,0,0,0, -- 10
			 0,0,0,0,0,0,0,2,0,0,0,0,0,0, -- 11
			 0,0,0,0,0,2,0,2,0,0,0,0,0,0, -- 12
			 1,0,0,0,0,2,0,0,0,0,0,0,0,1} -- 13
			 
	add_array_ob(lvl_a,r_d,r_p)
	
	local function setup()
		
		player.x=2*8
		player.x_m=2*8
		player.y=11*8
		player.y_m=11*8
		fin.x=7*8
		fin.y=7*8
		add_splat(9*8,7*8,8,8,4)
		
		add_gate(6*8,2*8,1)
		add_gate(6*8,7*8,1)
		add_switch(4*8,9*8,1)
		
		add_crate(12*8,11*8)
		
		add_cheese(9*8,6*8,3)
		add_cheese(7*8,2*8,3)
		
		--add_cheese(4*8,4*8,3)
	end
	
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end





function add_ob(x,y,lst)
	local ob = {}
	ob.x = x
	ob.y = y
	lst[#lst+1] = ob
end

function add_array_ob(a,r_d,r_p)
	local lst = {}
	local x = 1
	local y = 1
	for i=1,#a do
		if a[i] == 1 then 
			local ob = {}
			ob.x = x
			ob.y = y
			r_d[#r_d+1] = ob
		elseif a[i] == 2 then
			local ob = {}
			ob.x = x
			ob.y = y
			r_p[#r_p+1] = ob
		end
		x+=1
		if (x >14) then
			x=1
			y+=1
		end
	end
	return lst
end


function box_lvl(lst)

	for i=0,14 do
		add_ob(0,i,lst)
	end
	
	for i=0,15 do
		add_ob(i,0,lst)
	end
	
	for i=0,15 do
		add_ob(i,14,lst)
	end
	
		for i=0,15 do
		add_ob(i,15,lst)
	end
	
	for i=0,14 do
		add_ob(15,i,lst)
	end

end


function init_lvl(lvl)
		
	local r_p = levels[lvl].r_p
	local r_d = levels[lvl].r_d
	
	clear_map()
	
	splats={}
	cheese={}
	crates={}
	switches={}
	gates={}
	t_flow=28
	steps=0
	
	init_st_obs(8,r_p)
	init_st_obs(7,r_d)
	
	levels[lvl].s()
	player.e = 3

end

function clear_map()

	for x=0,15 do
  for y=0,15 do
   mset(x, y, 0)
		end	
	end
end

function init_st_obs(ind,obs)

	for i=1,#obs do
		
		mset(obs[i].x,obs[i].y,ind)
		
	end
	
end

function init_splats(spls)


end




__gfx__
00000000000000000000000000000000888888881dddddd600888800011111101111111100000000900000009000000090000000900000000000000000000000
0000000000000000888880008888888888888888ddddddd6088888801dddddd61ddddddd00000000600bb00060bb00006bb00b006b00bb000000000000000000
0000000000000000888888008888888888888888ddddddd6888888881dddddd61ddddddd000000006bbbbb006bbbbb006bbbbb006bbbbb000000000000000000
0000000000000000888888808888888888888888ddddddd6888888881dddddd61ddddddd000000006bbbbb006bbbbb006bbbbb006bbbbb000000100000000000
0000000000888800888888808888888888888888ddddddd6888888881dddddd61ddddddd000000006bb33b006b33bb00633bb30063bb33000000000000000000
0000000008888880888888808888888888888888ddddddd6888888881dddddd61ddddddd00000000633003006300330060033000603300000000000000000000
0000000008888880888888808888888888888888ddddddd6088888801dddddd61ddddddd00000000600000006000000060000000600000000000000000000000
0000000008888880888888808888888888888888ddddddd600888800066666601ddddddd00000000500000005000000050000000500000000000000000000000
00000000000000000000000088888880088888801dddddd6000000000dd101d002222220000000000a0000000000000000000000000000000000000000000000
88888800888000000008888888888880088888801ddddddd000000001ddd0dd62eeeeeef0cc00cc0000000a00000000000000000000000000000000000000000
88888880888800000088888888888880088888801ddddddd0000000001d1ddd52eeeeeef0ceccec0009900000099000000000000000000000000000000000000
88888880888800000888888888888880088888801ddddddd000000001d11dd102eeeeeef001c1c0000aa990000aa990000000000000000000000000000000000
88888880888800000888888888888880088888801ddddddd00000000ddd111d52eeeeeef00c1cc0000aaaa9000aaaa9000000000000000000000000000000000
88888880888800000888888888888880088888801ddddddd00000000dddd1dd62eeeeeef00cccc0ca0aaaaa000aaaaa000000000000000000000000000000000
88888800888000000888888888888880088888801ddddddd00000000ddd1ddd62eeeeeef00ccccc0000000000000000000000000000000000000000000000000
00000000000000000888888888888880088888801ddddddd00000000065056600ffffff0000ccc0000000a000000000000000000000000000000000000000000
08888880088888800888888888888888000000001dddddd611111111111111111111111100000000000000000000000000000000000000000000000000000000
08888880088888800888888888888888888888881dddddd61dddddddddddddddddddddd600000000000110000009900000000000000000000000000000000000
08888880088888800888888888888888888888881dddddd61dddddddddddddddddddddd600000000001100000099000000000000000000000000000000000000
08888880008888000888888888888888888888881dddddd61dddddddddddddddddddddd600000000011111100999999000000000000000000000000000000000
08888880000000000888888888888888888888881dddddd61dddddddddddddddddddddd600000000000011000000990000000000000000000000000000000000
08888880000000000088888888888888888888881dddddd61dddddddddddddddddddddd600000000000110000009900000000000000000000000000000000000
00888800000000000008888888888888888888881dddddd61dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001dddddd61dddddd6dddddddd6dddddd600000000000000000000000000000000000000000000000000000000
0000000000000000888888800888888800000000111111111dddddddddddddddddddddd611111111000000000000000000000000000000000000000000000000
0088888800000888888888800888888800888800dddddddd1dddddddddddddddddddddd61dddddd6011111100000000000000000000000000000000000000000
0888888800008888888888800888888808888880dddddddd1dddddddddddddddddddddd61d1111d6011111100808080800000000000000000000000000000000
0888888800008888888888800888888808888880dddddddd1dddddddddddddddddddddd61d1dd6d6011001108080808000000000000000000000000000000000
0888888800008888888888800888888808888880dddddddd1dddddddddddddddddddddd61d1dd6d6011001100808080800000000000000000000000000000000
0888888800008888888888000888888808888880dddddddd1dddddddddddddddddddddd61d1666d6011111108080808000088000000000000000000000000000
0088888800000888888880000888888808888880dddddddd1dddddddddddddddddddddd61dddddd6011111100888088880888808000000000000000000000000
00000000000000000000000008888888088888806666666616666666666666666666666616666666000000008888888888888888000000000000000000000000
00000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000008750087500975009750097500a7500b7500c7500e7500410005100031000310003100051000010017000190001b0001c0001d0001e0001e0001e0001e0001e000040000400003000030000200002000
0001000010650126501365011750127501375014750147501475017750127500f6500d6500a6500e6501165000600006000000000000000000000000000000000000000000000000000000000000000000000000
0001000013650166501c4501f45022450214501b4501445006650033500b3500c3502d1502f150321500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000265003650016500060001600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001124014740172301b2401f7402223026240297402c2302b70033700347000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000014050170501905021050260502a05030050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 43424344

