pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	new_objects={}
	objects = {}
	whites={}
	
	init_object(60,60)
end

function init_object(x,y)
	local obj = {
		whites={}
	}
	
	obj.x = x
	obj.y = y
	
	add(new_objects, obj)
	return obj
end

function init_white(obj,x,y)
	local white={
		x=x,
		y=y,
		ix=x<4 and x-2-rnd(4) or x+2+rnd(4),
		iy=y<4 and y-2-rnd(4) or y+2+rnd(4)
	}
	add(obj.whites,white)
end

function update_object(obj)
	for white in all(obj.whites) do
		update_white(obj, white)
	end
end

function _update()
	for obj in all(objects) do
		update_object(obj)
	end
end

function update_white(obj, white)
	white.ix = appr(white.x,white.ix,0.1)
	white.iy = appr(white.y,white.iy,0.1)
end

function draw_white(obj, white)
	pset(obj.x+white.ix,obj.y+white.iy,7)
end

function draw_object(obj)
	for white in all(obj.whites) do
		draw_white(obj, white)
	end
end

function _draw()

	cls()
	
	for new in all(new_objects) do
		spr(1, 0,0)
	
		for i=0,8 do
			for j=0,8 do
				if pget(i,j)==7 then
				 init_white(new, i,j)
				end
			end
		end
		
		add(objects, new)
	end
	
	if #new_objects>0 then
 	new_objects={}
 end
 	
	cls()
	
	rectfill(0,0,128,128,8)
	
	for obj in all(objects) do
		draw_object(obj)
	end
	
end
-->8
function appr(target, value, amount)
	if target<value then
		return max(target,value-amount)
	else
		return min(target,value+amount)
	end 
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
