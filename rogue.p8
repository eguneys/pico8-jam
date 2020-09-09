pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
dbg = ""

function noop() end

function _init()

	objects = {}

	t=0
end

base_template = {
	init=noop,
	update=noop,
	draw=noop
}

function init_object(template, x, y, arg)
	local obj = {}
	
	obj_merge(base_template, obj)
	obj_merge(template, obj)
	
	obj.x = x
	obj.y = y
	
	obj.init(obj, arg)
	
	add(objects, obj)
	return obj
end

function ai_update()
	
	t+=1
	
	if t%30*5==0 then
		init_object(proj_spawn, 
			rnd(64), rnd(64), maybe())
	end
		
end

function player_update(p)

	local input_x = 0
	local input_y = 0
	
	local input_f = 0

	if btn(⬆️) then
		input_y = -1
	elseif btn(⬇️) then
		input_y = 1
	end
	
	if btn(⬅️) then
		input_x = -1
	elseif btn(➡️) then
		input_x = 1
	end
	
	
end

function player_draw(p)

	rectfill(p.x, p.y, 
		p.x + p.w, 
		p.y + p.h, 7)
		
end

function player_init(p, arg)
	
end

player = {
	x=60,
	y=60,
	w=8,
	h=8,
	init=player_init,
	update=player_update,
	draw=player_draw
}

function projectile_init(p, spawn)
	p.dx = spawn.dx
	p.dy = spawn.dy
end

function projectile_update(p)
	p.w -= 0.2
	if p.w < 0.5 then
		destroy_object(p)
	end
end

function projectile_draw(p)
	if p.w > 0.5 then
		if p.dx==1 then		
			for i=0,p.l do
				local w = p.w
		 	line(p.x+i, p.y-w,
			 			p.x+i,
			 			p.y+w, 7)
			end
		else
			for i=0,p.l do
				local w = p.w
		 	line(p.x-w, p.y+i,
			 			p.x+w,
			 			p.y+i, 7)
			end
		end
	end

end

projectile={
	x=60,
	y=60,
	dx=0,
	dy=0,
	l=60,
	w=4,
	init=projectile_init,
	update=projectile_update,
	draw=projectile_draw
}

function proj_spawn_update(p)
	p.t += 1/30*8
	
	if p.t > 8 then
		init_object(projectile,p.x,p.y, p)
		destroy_object(p)
	end	
end

function proj_spawn_draw(p)
	if p.dy == 1 then
		for i=0,p.l-p.t%4,2 do
			local w = p.w
	 	line(p.x-w, p.y+i+p.t%4,
		 			p.x-w,
		 			p.y+i+p.t%4, 7)
			line(p.x+w, p.y+i+p.t%4,
				p.x+w,
					p.y+i+p.t%4, 7)
					
	 	line(p.x, p.y+i+p.t%4,
		 			p.x,
		 			p.y+i+p.t%4, 7)
		end
	else
		for i=0,p.l-p.t%4,2 do
			local w = p.w
	 	line(p.x+i+p.t%4,p.y-w,
		 			p.x+i+p.t%4,p.y-w,7)
			line(p.x+i+p.t%4,p.y+w,
					p.x+i+p.t%4,p.y+w,7)
					
	 	line(p.x+i+p.t%4,p.y,
		 			p.x+i+p.t%4,p.y,7)
		end
	end
end

function proj_spawn_init(p, dx)
	if dx then
		p.dx=1
		p.dy=0
	else
		p.dx=0
		p.dy=1
	end
end

proj_spawn = {
	x=60,
	y=60,
	dx=1,
	dy=0,
	l=60,
	w=4,
	t=0,
	init=proj_spawn_init,
	update=proj_spawn_update,
	draw=proj_spawn_draw
}

function _update()

	ai_update()

	for obj in all(objects) do
		obj.update(obj)
	end
end


function _draw()
	cls()
	
	rectfill(0, 0, 128, 128, 8)
	
	for obj in all(objects) do
		obj.draw(obj)
	end
	
	print(dbg,0,120)
end

function destroy_object(obj)
	del(objects, obj)
end
-->8
function maybe()
	return rnd()<0.5
end

function obj_merge(base, obj)
	for key,value in pairs(base) do
		obj[key]=value
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
