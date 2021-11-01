pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

dbg = ""
function _init()
 ps = {}
 ls = {}
 ts = {}
 add_t = 0



 local p1 = v_new(0, 1.5)
 local p2 = v_new(-1, 0)
 local p3 = v_new(1, 0)

 dbg = v_angle(p1, p2, p3)
end

function genp()
 local x, y = rnd(128), rnd(128)
 return { x = x, y = y, t = 0, p = rnd(20) + 10, r = rnd(6) - 3, basex = x, basey = y }
end

function genl()
 local p1,p2 = rnd(ps), rnd(ps)

 local mag = v_length(v_sub(p1, p2))
 local d1 = v_normal(v_sub(p1, p2))
 local d1mag = v_scale(d1, 4*mag / 128)


 del(ps, p1)
 del(ps, p2)


 return {
  t=0,
  p1=p1,
  p2=p2,
  d1=d1,
  mag=mag,
  d1mag=d1mag
 }
end

function gent(p1)
 local l1 = rnd(ls)


 del(ps, p1)
 del(ls, l1)

 local p2, p3 = l1.p1, l1.p2

 local midp = v_mid(v_mid(p1, p2), p3)

 return {
  p1=p1,
  p2=p2,
  p3=p3,
  midp=midp,
  t=0
 }
end

function updatep(p)
 p.t += 1
 p.x = p.basex
 p.y = p.basey


 if p.x < 0 or p.x > 128 or
 p.y < 0 or p.y > 128 then
  del(ps, p)
 end
end

function updatel(l)
 l.t += 1

 l.p1 = v_mod(v_add(l.p1, l.d1mag), 128)
 l.p2 = v_mod(v_add(l.p2, l.d1mag), 128)


 if #ls > 5 then
  del(ls, l)
  return
 end

 if l.t < 60 or #ts >= 2 then
  return
 end
 

 for p in all(ps) do
  if v_angle(l.p1, p, l.p2) > 0.4 then
   local _ts = gent(p)
   add(ts, _ts)
   break
  end
 end

end

function updatet(t)
 t.t += 1
 local theta = abs(sin(t.t/30/2)/30)
 t.p1 = v_add(v_rotate(v_sub(t.p1, t.midp), theta), t.midp)
 t.p2 = v_add(v_rotate(v_sub(t.p2, t.midp), theta), t.midp)
 t.p3 = v_add(v_rotate(v_sub(t.p3, t.midp), theta), t.midp)
end


function _update()
 add_t += 1

 if add_t % 10 == 0 then
  if #ps >= 3 then
   local _ls = genl()
   add(ls, _ls)
  end
 end

 if add_t % 30 == 0 then
  add(ps, genp())
 end


 for p in all(ps) do
  updatep(p)
 end

 for l in all(ls) do
  updatel(l)
 end

 for t in all(ts) do
  updatet(t)
 end

end


function _draw()
  cls()


  rectfill(0, 0, 128, 128, 9)


  for p3 in all(ps) do
   circfill(p3.x, p3.y, 1, 7)
  end 

  for l2 in all(ls) do
   circfill(l2.p1.x, l2.p1.y, 2, 4)
    line(l2.p1.x, l2.p1.y, l2.p2.x, l2.p2.y, 7)
  end


  for t3 in all(ts) do
   circfill(t3.p1.x, t3.p1.y, 2, 0)
   circfill(t3.p2.x, t3.p2.y, 2, 0)
   circfill(t3.p3.x, t3.p3.y, 2, 0)
   circfill(t3.midp.x, t3.midp.y, 2, 1)
   line(t3.p1.x, t3.p1.y, t3.p2.x, t3.p2.y, 7)
   line(t3.p2.x, t3.p2.y, t3.p3.x, t3.p3.y, 7)
   line(t3.p1.x, t3.p1.y, t3.p3.x, t3.p3.y, 7)
  end

  print(dbg)
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

function v_angle(va, vb, vc)

 local ab = atan2(va.x - vb.x, va.y - vb.y)
 local bc = atan2(vc.x - vb.x, vc.y - vb.y)

 return ab - bc
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
