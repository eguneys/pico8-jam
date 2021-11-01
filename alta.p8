pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

dbg = ""
function _init()
 player = {
  x=50,
  y=50,
  itheta=0,
  daccel=0,
  theta=0
 }
end

function update_player()

 local ix, iy = 0, 0
 if btn(0) then
  ix = -1
 end
 if btn(1) then
  ix = 1
 end
 if btn(2) then
  iy = -1
 end
 if btn(3) then
  iy = 1
 end

 local intheta = atan2(-ix, -iy)
 local diftheta = player.theta - intheta
 local absdiftheta = abs(diftheta)

 if ix ~= 0 or iy ~= 0 then
  player.theta = appr(player.theta, intheta, 0.08)

  if absdiftheta < 0.25 then

   player.daccel = appr(player.daccel, 3.0 - absdiftheta * 20, 0.1 + 0.1 - 0.1 * absdiftheta)
  else
   player.daccel = appr(player.daccel, 0, absdiftheta * 3)
  end
 else
  player.daccel = appr(player.daccel, 0, 0.2)
 end

 player.theta %= 1
 player.itheta = flr((player.theta) * 12)

 px = -cos(player.theta)
 py = -sin(player.theta)


 player.x += px * player.daccel
 player.y += py * player.daccel

end

-- spr, flipx, flipy
-- 0 - 1 / 8
FLIPS = {
 { 2, true, true },
 { 3, true, true },
 { 1, true, true },
 { 1, false, true },
 { 3, false, true },
 { 2, false, true },
 { 2, false, false },
 { 3, false, false },
 { 1, false, false },
 { 1, true, false },
 { 3, true, false },
 { 2, true, false },
}

function draw_player()


 local flips = FLIPS[player.itheta + 1]

 pal(12, 0)
 spr(flips[1], player.x + 1, player.y + 1, 1, 1, flips[2], flips[3])
 pal()
 spr(flips[1], player.x, player.y, 1, 1, flips[2], flips[3])
end

function _update()
 update_player()
end


function _draw()
  cls()

  rectfill(0, 0, 128, 128, 9)


  draw_player()

  print(dbg, 0)
end

-->8

function is_between(value, _min, _max)
 return value >= _min and value < _max
end

function appr(value, target, by)
 return (value < target) and min(target, value + by) or max(target, value - by)
end


function acos(x)
 return atan2(x,-sqrt(1-x*x))
end

function asin(y)
 return atan2(sqrt(1-y*y),-y)
end

-->8
function v_new(x, y)
 return { x=x, y=y }
end

function v_length(v)
 return sqrt(v.x * v.x + v.y * v.y)
end

function v_scale(v, k)
 return v_new(v.x * k, v.y * k)
end

function v_normal(v)
 return v_scale(v, 1/v_length(v))
end

function v_add(v1, v2)
 return v_new(v1.x + v2.x,
 v1.y + v2.y)
end

function v_sub(v1, v2)
  return v_new(v1.x - v2.x,
  v1.y - v2.y)
end

function v_mid(v1, v2)
 return v_scale(v_add(v1, v2), 1/2)
end

function v_distance(v1, v2)
 local dx, dy = v1.x - v2.x,
 v1.y - v2.y
 return sqrt(dx * dx + dy * dy)
end


function v_rotate(v1, angle)
 return v_new(
 cos(angle) * v1.x - sin(angle) * v1.y,
 sin(angle) * v1.x + cos(angle) * v1.y)
end

function v_mod(v1, mod)
 return v_new(v1.x % mod, v1.y % mod)
end

function v_dot(v1, v2)
 return v1.x * v2.x + v1.y * v2.y
end

function v_angle(va, vb)
 return atan2(vb.x - va.x, vb.y - va.y)
end

__gfx__
00000000000cc0000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccc000cccc000000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000cc0c00ccccccc00cccc0cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000cc0ccc0c0cc0cccccc000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000ccc0cc0cc00c0ccccc0ccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ccc0cc0ccccccc0cc0ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc0ccc00cccc0000ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccc000000000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
