pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

dbg = ""
function _init()
 player = {
  x = 0,
  y = 0,
  t_dashgrace=0,
  t_dash=0,
  itheta=0,
  daccel=0,
  theta=0
 }

 homings = {}

 lines = {}

 shards = {}

end


-- dx, dy
ATTACKS = {
 { 0, 3 },
 { 0, 8 },
 { 4, 8 },
 { 4, 8 },
 { 8, 8 },
 { 8, 8 },
 { 8, 4 },
 { 8, 0 },
 { 4, 0 },
 { 4, 0 },
 { 0, 0 },
 { 0, 0 },
 { 0, 0 },
}

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




function update_player()


 local idash = 0
 if btn(5) then
  idash = 1
 end

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


 player.t_dashgrace = appr(player.t_dashgrace, 10 * idash, 1) 


 if player.t_dash == 0 then
  if player.t_dashgrace > 0 then
   player.t_dashgrace = 0
   player.t_dash = 10
  end
 end

 player.t_dash = appr(player.t_dash, 0, 1)


 if player.t_dash > 7 then
  player.daccel = appr(player.daccel, 50, 5 * (player.t_dash / 10))
 elseif player.t_dash > 0 then
  player.daccel = appr(player.daccel, 1, 1)
 end

 if ix ~= 0 or iy ~= 0 then
  player.theta = appra(player.theta, intheta, 0.08)

  if absdiftheta < 0.25 then

   player.daccel = appr(player.daccel, 4.0 - absdiftheta * 20, 0.1 + 0.1 - 0.1 * absdiftheta)
  else
   player.daccel = appr(player.daccel, 3 * (1 - absdiftheta), absdiftheta * 3)
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


 if player.x < -4 then
  player.x = -4
 end
 if player.x > 124 then
  player.x = 124
 end
 if player.y < -4 then
  player.y = -4
 end
 if player.y > 124 then
  player.y = 124
 end


 player.hit = v_new(player.x + ATTACKS[player.itheta + 1][1],
 player.y + ATTACKS[player.itheta + 1][2])



 local ixy = v_scale(v_new(
 cos(player.theta), sin(player.theta)), 8)

 player.hit2 = v_sub(player.hit, ixy)
 player.hit = v_add(player.hit, ixy)

end

function draw_player()


 local flips = FLIPS[player.itheta + 1]

 pal(12, 0)
 spr(flips[1], player.x + 1, player.y + 1, 1, 1, flips[2], flips[3])
 pal()
 spr(flips[1], player.x, player.y, 1, 1, flips[2], flips[3])


 --line(player.hit.x, player.hit.y, player.hit2.x, player.hit2.y, 7)
end

function add_homing(x, y)
 if #homings > 8 then
  return
 end
 local dist = rnd(homings)
 local hom = {
  x = x,
  y = y,
  t=0,
  ref=0,
  atimer=0,
  dist=dist,
  theta=sin(rnd(1)) * 0.1,
  daccel=0
 }

 add(homings, hom)
end

function add_line()

 if #homings < 2 or #lines > 5 then
  return
 end

 local p1, p2 = homings[1 + flr(rnd(#homings - 2))],
 homings[#homings -1]


 if p1 == p2 then
  -- TODO special
  return
 end

 p1.ref += 1
 p2.ref += 1

 local li = {
  p1 = p1,
  p2 = p2,
  t=0,
  life=200+rnd(100)
 }

 add(lines, li)

end

function update_line(li)

 li.t += 1


 if li.t > li.life then
  del_line(li)
 end

 if player.t_dash > 0 then
  if line_line(li.p1, li.p2, player.hit, player.hit2) then
   del_line(li)
   add_shard(li, 0.5)
   add_shard(li, 1)
   return
  end
 end
end

function del_line(li)
 del(lines, li)
 li.p1.ref -= 1
 li.p2.ref -= 1
 if li.p1.ref == 0 then
  li.p1.ref -= 1
 end
 if li.p2.ref == 0 then
  li.p2.ref -= 1
 end
end

function draw_line(li)
 line(li.p1.x, li.p1.y, li.p2.x, li.p2.y, 7)
end

function update_homing(homing)

 homing.t += 1
 homing.daccel = appr(homing.daccel, 0.5, 0.02)


 local outside = is_outside(homing)


 if outside or homing.ref < 0 then
  del(homings, homing)
 end

 local active = (homing.t % 300) < 100
 local mult = active and 2 or 1
 
 if player.t_dash > 0 then
  if homing.atimer == 0 then
   homing.atimer = 10 + rnd(10) + rnd(26)  + rnd(20)
  end
 end

 homing.atimer = appr(homing.atimer, 0, 1)

 if homing.atimer > 0 then
  mult *= 2
 end

 local vtarget = active and v_new(player.x, player.y) or v_new(128, 128)
 local targettheta = -v_angle(vtarget, v_new(homing.x, homing.y))

 homing.theta = appra(homing.theta, targettheta, 0.01 * mult)
 local thetadiff = homing.theta - targettheta

 homing.daccel = appr(homing.daccel, player.daccel, (1-thetadiff)*0.04)

 local px, py = -cos(homing.theta) * mult,
 sin(homing.theta) * mult

 homing.x = appr(homing.x, homing.x + px, homing.daccel * mult)
 homing.y = appr(homing.y, homing.y + py, homing.daccel * mult)

 if homing.dist ~= nil and homing.dist.ref > 0 then

  local vp = v_normal(v_sub(homing, homing.dist))

 homing.x = appr(homing.x, homing.x + vp.x, homing.daccel * mult * 0.5)
 homing.y = appr(homing.y, homing.y + vp.y, homing.daccel * mult * 0.5)


 end

 for h2 in all(homings) do
  if h2 ~= homing then
   if v_distance(h2, homing) < 4 then
    del(homings, h2)
    del(homings, homing)
   end
  end
 end
end

function draw_homing(homing)

 circfill(homing.x, homing.y, 1, 0)

 local vx, vy = cos(homing.theta), sin(homing.theta)

 line(homing.x, homing.y, homing.x + vx * 4, homing.y + vy * 4, 0)

end

function add_shard(li, mult)

 local m = v_m(li.p1, li.p2)
 local l = v_distance(li.p1, li.p2)

 local split = l / 3
 local lshard = rnd(split)
 l = l - lshard
 local p_0 = li.p1
 local p_1 = v_point_atdistance(p_0, li.p2, lshard)
 for i=1,20 do
  lshard = rnd(split - rnd(split))
  l = l - lshard
  p_0 = p_1
  p_1 = v_point_atdistance(p_0, li.p2, lshard)

  if l < 0 then
   break
  end
  local thetaoff = i < 10 and (10 - i) or (i - 10)
  local theta = player.theta + rnd(thetaoff / 10)*0.25


  local vmid = v_mid(p_0, p_1)
  local _thetaoff2 = rnd(thetaoff/10 * 0.4) - rnd(thetaoff/10 * 0.2)

  local sh = {
   p1=v_rotatea(p_0, _thetaoff2, vmid),
   p2=v_rotatea(p_1, _thetaoff2, vmid),
   theta=theta,
   thetaoff=rnd(thetaoff / 10),
   vd=v_new(-cos(theta), -sin(theta)),
   daccel=rnd((1-(thetaoff/10))* 2) * 2 * mult * player.daccel * 2 - (lshard / l) * player.daccel * 0.2,
   ddaccel=2+rnd(1-thetaoff/10) * 1,
  }
  add(shards, sh)
 end
end

function update_shard(sh)

 sh.ddaccel = appr(sh.ddaccel, 0.1, 0.1)
 sh.daccel = appr(sh.daccel, -15, sh.ddaccel)
 if sh.daccel > 0 then
  sh.p1 = v_add(sh.p1, v_scale(sh.vd, sh.daccel))
  sh.p2 = v_add(sh.p2, v_scale(sh.vd, sh.daccel))
 end

 if sh.daccel < 0 then
  sh.thetaoff = appr(sh.thetaoff, 0, 0.01)
 end

 if sh.daccel <= -15 then
  del(shards, sh)
 end
end

function draw_shard(sh)
 local col = sh.daccel <= 0 and sh.thetaoff < 0.2 and 6 or 7
 line(sh.p1.x, sh.p1.y, sh.p2.x, sh.p2.y, col)
end

function _update()

 dbg = #lines
 if rnd() < 0.02 then
  add_homing(0, 0)
 elseif rnd() < 0.05 then
  add_homing(0, rnd(128))
 end


 if rnd() < 0.1 then
  add_line()
 end

 update_player()

 for hom in all(homings) do
  update_homing(hom)
 end

 for li in all(lines) do
  update_line(li)
 end

 for sh in all(shards) do
  update_shard(sh)
 end

end


function _draw()
 cls()

 rectfill(0, 0, 128, 128, 9)

 draw_player()

 for edge in all(edges) do
  draw_edge(edge)
 end

 for hom in all(homings) do
  draw_homing(hom)
 end

 for li in all(lines) do
  draw_line(li)
 end

 for sh in all(shards) do
  draw_shard(sh)
 end



 print(dbg, 0)
end

-->8

function is_outside(value)
 return not (is_between(value.x, -10, 138)and 
 is_between(value.y, -10, 138))
end

function is_between(value, _min, _max)
 return value >= _min and value < _max
end

function appr(value, target, by)
 return (value < target) and min(target, value + by) or max(target, value - by)
end

-- https://gamedev.stackexchange.com/a/197698/41229
function wrap_value(value, from, to)
  local range = to - from
  return value - (range * flr((value - from) / range))
end

function angle_diff(from, to)
  return wrap_value(to - from, -0.5, 0.5)
end

function appra(value, target, by)
  local diff = angle_diff(value, target)
  local sign = (diff > 0 and 1 or -1)
  local offset = min(abs(by), abs(diff)) * sign
  return wrap_value(value + offset, 0, 1)
end

function line_line(l1, l2, c1, c2)

 local x1, x2, x3, x4 = l1.x, l2.x, c1.x, c2.x
 local y1, y2, y3, y4 = l1.y, l2.y, c1.y, c2.y

 local tover = (x1 - x3)*(y3-y4)-(y1-y3)*(x3-x4)

 local tunder = (x1 - x2)*(y3-y4) - (y1-y2)*(x3-x4)

 local t = tover/tunder

 local uover = (x1 - x3)*(y1-y2)-(y1-y3)*(x1-x2)

 local uunder = (x1 - x2)*(y3-y4) - (y1-y2)*(x3-x4)

 local u = uover/uunder

 return t >= 0 and t <= 1.0 and u >= 0 and u <= 1.0


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

function v_rotatea(v1, angle, vo)
 return v_add(
 v_rotate(v_sub(v1, vo), angle),
 vo)
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

function v_m(va, vb)
 return (vb.y - va.y) / (vb.x - va.x)
end


function v_point_atdistance(va, vb, d)
 local u = v_normal(v_sub(vb, va))

 return v_add(va, v_scale(u, d))

end

__gfx__
00000000000cc0000000000000000cc00000000000000000cccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000
0000000000cccc000cccc000000ccccc000000000000000000000000cc0000cccc0c00ccccc00cccccccccccccccc00000000000000000000000000000000000
0070070000cc0c00ccccccc00cccc0cc000000000000000000000000c00000c0cc00c0cccc0000cccccccccc0000000000000000000000000000000000000000
000770000cc0ccc0c0cc0cccccc000c0000000000000000000000000000000000c00000cc0000000cccccccc0000000000000000000000000000000000000000
000770000ccc0cc0cc00c0ccccc0ccc00000000000000000000000000000000000000000000000000c0cc0c00000000000000000000000000000000000000000
007007000ccc0cc0ccccccc0cc0ccc00000000000000000000000000000000000000000000000000000cc0000000000000000000000000000000000000000000
000000000cc0ccc00cccc0000ccccc00000000000000000000000000000000000000000000000000000cc0000000000000000000000000000000000000000000
0000000000cccc000000000000ccc0000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000
