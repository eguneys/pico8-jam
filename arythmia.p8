pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
dbg=""
pmax=2
paccel=0.3
daccel=0.5
pdeccel=1

function init_play(play)
   sfx_delay = 0
   init_delay = 0
   end_delay = 0

   edges={}

   fsobjects={}
   objects={}

   fshelpers={}
   helpers={}

   t=0

   init_level(stats.current)
   init_player()

   nbobjects = #fsobjects

   init_edge(1,0)
   init_edge(-1,0)
   init_edge(0,1)
   init_edge(0,-1)

   shake = 0
   shakex = 0
   shakey = 0

   music(levels[stats.current * 4])

end

function init_helper(st, si, x, y, w, h)
   local res = {
      t=0,
      st=st,
      x=x,
      y=y,
      si=si,
      w=w,
      h=h
   }
   add(fshelpers, res)
   return res
end

function update_helper(hel)
   hel.t += 1

   if hel.t > 30 then
      del(helpers, hel)
   end
end

function draw_helper(hel)
   local sx = (hel.si % 16) * 8
   local sy = flr((hel.si + 64) / 16) * 8

   if hel.t % 12 < 4 then

      for i=0,hel.w,8 do

         for j=0,hel.h,8 do
            sspr(sx, sy, 8, 8, 
                 i+hel.x-hel.w/2, j+hel.y-hel.h/2,
                 8, 8) 
         end
      end  
   end
end

function sweeph_prefab(st, x1, x2, duration)
   local frames = {
      init_keyframe(m_pos, 0, duration,
                    {x1, 64}, {x2, 64}),
      init_keyframe(m_scale, 0, 1,
                    {0, 16}, {0, 16})
   }

   init_object(st + 30, 9, frames)

   init_helper(st, 25, x1<0 and 0 or 120, 64, 8, 128)
end

function sweepv_prefab(st, y1, y2, duration)
   local frames = {
      init_keyframe(m_pos, 0, duration,
                    {64, y1}, {64, y2}),
      init_keyframe(m_scale, 0, 1,
                    {16, 0}, {16, 0})
   }

   init_object(st + 30, 9, frames)

   init_helper(st, 25, 64, y1<0 and 0 or 120, 128, 8)
end

function edgeh_prefab(st, y)
   local frames = {
      init_keyframe(m_pos, 0, 120,
                    {64, y}, {64, y}),
      init_keyframe(m_scale, 0,60,
                    {16,-1}, {16,8}),
      init_keyframe(m_scale, 90,30,
                    {16,8}, {16,-1})
   }
   
   init_object(st, 9, frames)
end

function edgev_prefab(st, x)
   local frames = {
      init_keyframe(m_pos, 0, 120,
                    {x, 64}, {x, 64}),
      init_keyframe(m_scale, 0,60,
                    {-1, 16}, {8, 16}),
      init_keyframe(m_scale, 90,30,
                    {8,16}, {-1,16})
   }
   
   init_object(st, 9, frames)
end

function boss_frames()
   local frames = {
      init_keyframe(m_pos, 0, 10,
                    {64,64},{64,64}),
      init_keyframe(m_scale, 0, 10,
                    {-1,-1},{1, 1})
   }

   local _st = 10

   append(frames, boss_beat_frames(_st, 1,2, 0))
   _st += 30
   append(frames, boss_beat_frames(_st, 2,1, 1))
   _st += 30
   append(frames, boss_beat_frames(_st, 1,3, 2))
   _st += 30
   append(frames, boss_beat_frames(_st, 3,1,3))
   _st += 30

   append(frames, 
          boss_dash_frames(_st,64,64,64,0))
   _st += 100
   append(frames, 
          boss_dash_frames(_st,64,64,128,64))
   _st += 100
   append(frames, 
          boss_dash_frames(_st,64,64,0,64))
   _st += 100
   append(frames, 
          boss_dash_frames(_st,64,64,64,128))
   _st += 100

   append(frames,
          boss_attack_frames(_st,64, 100))

   _st += 160

   append(frames,
          boss_attack_frames(_st, 20, 20))
   _st += 160

   append(frames,
          boss_attack_frames(_st, 100, 64))
   _st += 160

   append(frames,
          boss_attack_frames(_st, 20, 100))
   _st += 160

   return frames
end


function boss_prefab(st)
   init_object(st, 9, boss_frames())

   while st < 1200 do
      st += 30
      if maybe(0.3) then
         laserh_prefab(st, 9, rnd()*128)
      else
         laserv_prefab(st, 9, rnd()*128)
      end
      st += 10 + rnd()*30
   end
end

function boss_attack_frames(_st, x2,y2)
   local frames = {}

   append(frames, 
          boss_move_frames(_st,64,64,x2,y2))
   _st += 80

   append(frames, boss_scale_frames(_st, 1,5))
   _st += 30

   append(frames, boss_scale_frames(_st, 5,1))
   _st += 30

   append(frames, 
          boss_move_frames(_st,x2,y2,64,64))

   return frames
end

function boss_scale_frames(st, s1,s2)
   return {
      init_keyframe(m_scale, st, 16,
                    { s1,s1 }, {s2,s2})
   }
end

function boss_move_frames(st, x1,y1,x2,y2)
   return {
      init_keyframe(m_pos, st, 16,
                    {x1,y1},{x2,y2})
   }
end

function boss_dash_frames(st, x1,y1,x2,y2)
   return {
      init_keyframe(m_pos, st, 16,
                    {x1,y1},{x2,y2}),
      init_keyframe(m_pos, st+24, 32,
                    {x2,y2},{x1,y1})
   }
end

function boss_beat_frames(st, sc_from, sc_to, r)
   return {
      init_keyframe(m_scale, st, 8,
                    { sc_from,sc_from }, {sc_to + 4,sc_to + 4}),
      init_keyframe(m_rot, st, 4,
                    {r,0}, {r+1,0}),
      init_keyframe(m_scale, st + 8, 4,
                    { sc_from + 4,sc_from + 4 }, {sc_to,sc_to}),
   }
end

function bomb_prefab(st, si, x, y)

   init_helper(st, 25, x, y, 8, 8)
   init_helper(st, 25, x+8, y, 8, 8)
   init_helper(st, 25, x, y+8, 8, 8)
   init_helper(st, 25, x, y, 8, 8)
   init_helper(st, 25, x-8, y, 8, 8)
   init_helper(st, 25, x, y-8, 8, 8)

   st += 30

   local beat_frames = {
      init_keyframe(m_pos, 0, 60, {x,y}, {x,y}),
      init_keyframe(m_scale, 0, 4, {-1,-1}, {1,1}),
      init_keyframe(m_scale, 4, 30, {1,1}, {-1,-1})
   }

   init_object(st, 37, beat_frames)


   init_object(st + 4, si, 
               any_bullet_frames(x,y,-8,y, 20))

   init_object(st + 4, si, 
               any_bullet_frames(x,y,-8,y, 20))

   init_object(st + 4, si, 
               any_bullet_frames(x,y,x,-8, 20))
   init_object(st + 4, si, 
               any_bullet_frames(x,y,x,136, 20))
   init_object(st + 4, si, 
               any_bullet_frames(x,y,136,y, 20))


   init_object(st + 8, si, 
               any_bullet_frames(x,y,-8,136, 20))
   init_object(st + 8, si, 
               any_bullet_frames(x,y,136,-8, 20))
   init_object(st + 8, si, 
               any_bullet_frames(x,y,-8,-8, 20))
   init_object(st + 8, si, 
               any_bullet_frames(x,y,136,136, 20))
   
end

function laserv_prefab(st, si, x)
   init_object(st+30, si, laserv_frames(x))
   init_helper(st, si, x, 64, 16, 128)
end

function laserh_prefab(st, si, y)
   init_object(st+30, si, laserh_frames(y))
   init_helper(st, si, 64, y, 128, 16)
end

function bulleth_prefab(st, si, x)
   init_object(st, si, bulleth_frames(x))
end

function bulletv_prefab(st, si, y)
   init_object(st, si, bulletv_frames(y))
end

function bulletd_prefab(st, si, x, y)
   init_object(st, si, bulletd_frames(x,y))
end

function bigscale_prefab(st, si, x, y)
   local frames = {
      init_keyframe(m_pos, 0, 60, {x,y}, {x,y}),
      init_keyframe(m_scale, 0, 10, {-1,-1},{8,8}),
      init_keyframe(m_sfx, 0, 4, {5,0},{5,2}),
      init_keyframe(m_scale, 56, 4, {8,8},{-1,-1})
   }
   
   init_object(st + 30, si, frames)

   init_helper(st, si, x, y, 64, 64)
end

function laserv_frames(x)
   local res = {}

   append
   (res, {
       init_keyframe(m_pos, 0, 120, 
                     {x, 64}, {x, 64}),
       init_keyframe(m_scale, 0,10,
                     {-1, 16}, {2, 16}),
       init_keyframe(m_sfx, 0, 4, 
                     {6,0},{6,2}),
       init_keyframe(m_scale, 15,10,
                     {2,16}, {-1, 16})
   })
   return res
end

function laserh_frames(y)
   local res = {
      init_keyframe(m_pos, 0, 120, 
                    {64,y}, {64,y}),
      init_keyframe(m_scale, 0,10,
                    {16,-1}, {16, 2}),
      init_keyframe(m_sfx, 0, 4, 
                    {6,0},{6,2}),
      init_keyframe(m_scale, 15,10,
                    {16,2}, {16, -1})
   }
   return res
end

function bulletd_frames(x, y)
   return any_bullet_frames(x,y,x<0 and 136 or -8,
                            y<0 and 136 or -8, 120)
end

function bulletv_frames(x)
   return any_bullet_frames(x, -20, x, 136, 120)
end

function bulleth_frames(y)
   return any_bullet_frames(-20,y, 136,y, 120)
end

function any_bullet_frames(x1, y1, x2, y2, duration)
   local res = {}

   append(res, {
             init_keyframe(m_pos, 0, duration, {x1,y1}, {x2,y2}),
             init_keyframe(m_rot, 0, duration, {0,0}, {10,0})
   })
   append(res, beat_frame(duration/4,4))
   append(res, beat_frame(duration/4+4,4))
   append(res, beat_frame(duration/2,4))
   append(res, beat_frame(duration/2+4,4))
   append(res, beat_frame(duration*0.75,4))
   append(res, beat_frame(duration*0.75+4,4))

   return res
end

function beat_frame(st, l)
   return {
      init_keyframe(m_scale, st, l, {0,0}, {1,1}),
      init_keyframe(m_sfx, st, l, {7,0}, {7,2}),
      init_keyframe(m_scale, st+l+2, l, {1,1}, {0,0}),
   }
end

function init_object(st, si, fss)
   local obj = {
      st=st,
      si=si,
      t=0,
      x=0,
      y=0,
      sx=1,
      sy=1,
      r=0,
      cbox={
         x=0,
         y=0,
         w=0,
         h=0
      },
      i= {
         x=0,
         y=0,
         sx=0,
         sy=0,
         si=0,
         sfx=0,
         sfy=0
      },
      fss=fss,
      fs={},
   }

   add(fsobjects, obj)
   return obj
end

function update_object(obj)

   obj.t += 1

   for fs in all(obj.fss) do
      if fs.st <= obj.t then

         del(obj.fss, fs)
         add(obj.fs, fs)
      else
         break
      end
   end

   for fs in all(obj.fs) do
      update_keyframe(fs)

      fs.fmodify(obj.i, fs.value)

      if fs.t >= fs.tl then
         del(obj.fs, fs)
      end
   end

   if sfx_delay == 0 and obj.i.sfy == 1 then
      sfx_delay=4
      --sfx(obj.i.sfx)
   end

   if sfx_delay > 0 then
      sfx_delay -= 1
   end

   if #obj.fss == 0 and
      #obj.fs == 0 then
      del(objects, obj)
   end
end

function draw_object(obj)
   local sx = ((obj.si + obj.i.si) % 16) * 8
   local sy = flr(obj.si / 16) * 8
   local w = (obj.sx + obj.i.sx) * 8
   local h = (obj.sy + obj.i.sy) * 8
   local x = obj.i.x - w / 2
   local y = obj.i.y - h / 2

   obj.cbox.x = x
   obj.cbox.y = y
   obj.cbox.w = w
   obj.cbox.h = h

   sspr(sx, sy, 8, 8, 
        x, y,
        w, h)
end

function m_sfx(i, value)
   i.sfx = value[1]
   i.sfy = value[2]
end

function m_pos(i, value)
   i.x = value[1]
   i.y = value[2]
end

function m_rot(i, value)
   i.si = flr(value[1] % 4)
end

function m_scale(i, value)
   i.sx = value[1]
   i.sy = value[2]
end

function init_keyframe(fmodify, st, tl, svalue, evalue)
   return {
      t=0,
      st=st,
      tl=tl,
      svalue=svalue,
      evalue=evalue,
      value={svalue[1],svalue[2]},
      fmodify=fmodify
   }
end

function update_keyframe(key)
   key.t += 1
   local itime = key.t / key.tl

   itime = ease_outquad(itime)

   key.value[1] = lerp(key.evalue[1], key.svalue[1], itime)
   key.value[2] = lerp(key.evalue[2], key.svalue[2], itime)
end

function init_edge(dx,dy)
   local e = {
      t=0,
      x=dx==0and 0 or dx<0and 128 or -101,
      y=dy==0and 0 or dy<0and 128 or -101,
      w=dx==0and 128 or 100,
      h=dy==0and 128 or 100
   }
   
   add(edges,e)
   return e
end

function update_edge(e)
end

function draw_edge(e)
   rectfill(e.x,e.y,e.x+e.w,e.y+e.h,7)
end

function init_player()

   local life = {
      {x=30,y=30},
      {x=30,y=30},
      {x=30,y=30},
      {x=30,y=30}
   }

   player={
      t=0,
      x=30,
      y=30,
      dx=0,
      dy=0,
      w=8,
      h=8,
      si=17,
      dash_time=0,
      dash_grace=0,
      collide=0,
      particles={},
      inx=0,
      iny=0,
      life=life
   }
end

function update_player(p)

   local input_x=0
   local input_y=0
   local input_b=0
   
   if btn(⬅️) then
      input_x=-1
   elseif btn(➡️) then
      input_x=1
   end
   
   if btn(⬆️) then
      input_y=-1
   elseif btn(⬇️) then
      input_y=1
   end

   if input_x != 0 then
      p.inx = input_x
      p.iny = input_y
   end

   if input_y != 0 then
      p.inx = input_x
      p.iny = input_y
   end

   
   if btn(❎) then
   	input_b = 1
   end

   local d_full=5
   local d_half=d_full*0.707

   if p.dash_grace==0 and input_b==1 then
      sfx(1)
      p.dash_grace = 15
      p.dash_time = 4
      stats.dash += 1

      if p.inx!=0 then
         if p.iny!=0 then
            p.dx=d_half*p.inx
            p.dy=d_half*p.iny
         else
            p.dx=d_full*p.inx
            p.dy=0
         end
      elseif p.iny!=0 then
         p.dx=0
         p.dy=d_full*p.iny
      end

      p.dash_accel=1
      p.dashx = 4
      p.dashy = 4
   end

   if p.dash_grace > 0 then
      p.dash_grace -= 1
   end

   if p.dash_time > 0 then
      p.dash_time -= 1

      p.dx=appr(p.dashx*p.inx,p.dx,p.dash_accel)
      p.dy=appr(p.dashy*p.iny,p.dy,p.dash_accel)
   else

      local _pmax = pmax

      if input_y != 0 and input_x != 0 then
         _pmax *= 0.714
      end

      p.dx=appr(_pmax*input_x,p.dx,
                paccel)

      p.dy=appr(_pmax*input_y,p.dy,
                paccel)
   end

   p.x += p.dx
   p.y += p.dy

   stats.distance += _vlength(p.dx, p.dy)

   p.t+=1

   if p.x < -4 then
      p.x = -4
      p.dx = 0
   end
   if p.y < -4 then
      p.y = -4
      p.dy = 0
   end

   if p.x > 124 then
      p.x = 124
      p.dx = 0
   end

   if p.y > 124 then
      p.y = 124
      p.dy = 0
   end
   -- p.x = clamp(-4, 124, p.x)
   -- p.y = clamp(-4, 124, p.y)

   if p.collide > 0 then
      p.collide -= 1
      if p.collide == 0 then
         deli(p.life, #p.life)

         stats.flawless = false

         if #p.life == 0 then
            music(-1)
            sfx(4)
            init_delay=60

            stats.death += 1

         end
      end
   end

   for _p in all(p.particles) do
      _p.dx = appr(0, _p.dx, 0.1)
      _p.dy = appr(0, _p.dy, 0.1)
      _p.x += _p.dx
      _p.y += _p.dy
      _p.r -= rnd() * 0.5
      if _p.dx == 0 and _p.dy == 0 then
         del(p.particles,_p)
      end
   end

   if p.dash_time > 0 then
      for i=0,3 do
         add(p.particles, {
                x=player.x+4,
                y=player.y+4,
                dx=p.dx * 0.2*i,
                dy=p.dy * 0.2*i,
                r=rnd()*4
         })
      end
   end
   
   p.flipx = input_x==0 and p.flipx
      or input_x < 0
   
   p.flipy = input_y==0 and p.flipy
      or input_y > 0

   if input_x == 0 then
      if input_y != 0 then
         p.si = 17
      end
   else
      if input_y != 0 then
         p.si = 19
      else
         p.si = 18
      end
   end
end

function collide_player(obj)
   local r = box_intersect_ratio(player,obj)

   if r >= 0.5 and
      player.collide == 0 and
      player.dash_grace < 4 then

      player.collide = 20
      shake=10
      sfx(0)
      for i=0,20 do
         add(player.particles, {
                x=player.x+4,
                y=player.y+4,
                dx=cos(rnd())*1.8,
                dy=sin(rnd())*1.8,
                r=rnd()*4
         })
      end
   end
end

function draw_player(p)

   if p.dash_time % 4 == 1 then
      spr(49,p.x,p.y,1,1)
      pal(7,8)
      spr(p.si,p.x,p.y,1,1,p.flipx,p.flipy)
      pal()
   else
      spr(p.si,p.x,p.y,1,1,p.flipx,p.flipy)
   end


   for p in all(p.particles) do
      for a=0,1,0.1 do
         for r=0,p.r do
            pset(p.x + cos(a)*r,p.y+sin(a)*r,pget(p.x,p.y)==7 and 8 or 7)
         end
      end
   end
   
   local last={x=p.x,y=p.y}
   local i=1.5
   for l in all(p.life) do
      if vdist(l,last) > 10 then
         l.x = lerp(last.x,l.x,0.1)
         l.y = lerp(last.y,l.y,0.1)
      end
      circfill(l.x,l.y,i,7)
      i-=0.5
      last={x=l.x,y=l.y}
   end
end

function update_play(play)

   if shake > 0 then
      shake -= 1

      shakex = lerp(2-rnd()*4,shakex,rnd()*2)
      
      shakey = lerp(2-rnd()*4,shakey,rnd()*2)
   end

   shakex = appr(0,shakex,rnd())
   shakey = appr(0,shakey,rnd())

   t+=1

   for obj in all(fsobjects) do
      if obj.st <= t then
         del(fsobjects, obj)
         add(objects, obj)         
      else
         --break
      end
   end

   for hel in all(fshelpers) do
      if hel.st <= t then
         del(fshelpers, hel)
         add(helpers, hel)         
      end
   end

   for hel in all(helpers) do
      update_helper(hel)
   end

   for obj in all(objects) do
      update_object(obj)
      collide_player(obj.cbox)
   end

   if #objects == 0 and #fsobjects == 0 then
      if end_delay == 0 then
         music(-1)
         end_delay = 60
      end
   end

   if end_delay > 0 then
      end_delay -= 1
      if end_delay == 0 then
         transition(end_scene, stats)
      end
   end

   for e in all(edges) do
      update_edge(e)
      collide_player(e)
   end

   if init_delay > 0 then
      init_delay -= 1
      if init_delay == 0 then
         init_play()
      end
   else
      if end_delay == 0 then
         update_player(player)
      end
   end
end

function draw_play(play)
   cls()

   if abs(shakex) > 1 or abs(shakey) > 1 then
      pal(7, 8)
      pal(8, 7)
   end

   camera(shakex,shakey)
   
   rectfill(0,0,128,128,8)
   
   for hel in all(helpers) do
      draw_helper(hel)
   end

   for obj in all(objects) do
      draw_object(obj)
   end

   for e in all(edges) do
      draw_edge(e)
   end
   
   draw_player(player)
   
   if init_delay > 0 then
      if init_delay < 5 then
         rectfill(0,0,128,(1.0 - init_delay/5)*128,8)
      end
   end

   local pt = 1.0-#fsobjects/nbobjects
   rectfill(0,126,128,126,7)
   rectfill(0,127,pt*128,127,7)

   pal()
   camera()
   --print(dbg,0,120,2)
end

-->8

e_next_beat = 0
e_laserh = 1
e_laserv = 2
e_bulleth = 3
e_bulletv = 4
e_bulletd = 5
e_bomb = 6
e_bigscale=7
e_edgeh=8
e_edgev=9
e_sweeph=10
e_sweepv=11
e_boss=12

level1 = {
   bpm=60,
   oss={
      0,3,25,10,3,25,40,3,25,50,0,
      7,5,30,30,0,
      7,5,90,90,0,0,
      8,0,8,128,0,
      9,0,9,128,0,
      2,9,60,0,
      7,5,30,90,7,5,90,30,0,
      1,9,90,2,9,60,2,9,60,0,6,53,60,60,0,
      2,9,30,2,9,120,0,6,41,60,60,0,
      1,9,30,0,0,
      1,9,90,3,5,10,3,5,100,0,6,53,60,60,0,
      1,9,60,4,5,10,4,5,100,0,6,41,60,60,0,
      1,9,30,5,37,-8,-8,5,37,136,-8,0,
      10,-8,136,100,0,
      10,136,-8,100,0,
      11,-8,136,100,0,
      11,136,-8,50,11,136,-8,100,0,
      7,37,64,64,0,
      3,53,20,3,53,60,3,53,100,0,
      9,0,8,0,0,
      9,0,9,128,0,0,
      0,4,25,60,4,25,30,4,25,90,0,
      0,3,53,100,3,53,80,3,53,70,0,
      0,3,53,20,3,53,60,0,
      0,3,21,100,0,0
   }
}

level2 = {
   bpm=10,
   oss={
      0,0,0,0,
      10,-8,136,100,0,
      11,136,-8,100,0,0,
      4,5,60,0,4,5,30,0,4,5,90,0,
      3,37,100,0,3,37,30,0,3,37,90,0,0,
      11,-8,136,100,0,11,-8,136,100,0,
      10,136,-8,100,0,0,
      3,37,30,0,3,37,100,0,3,37,90,0,0,
      4,5,90,0,4,5,30,0,4,5,60,0,
      10,136,-8,100,0,10,-8,136,100,0,
      8,0,4,5,90,0,4,5,30,0,4,5,60,0,
      9,0,9,128,0,
      3,37,30,0,3,37,100,0,3,37,90,0,0,
      0,0,0,0,
      2,9,60,0,0,2,9,80,0,0,1,9,60,1,9,90,0,
      1,9,90,0,0,1,9,20,0,0,1,9,50,1,9,70,
      
      0,0,0,0,0
   }
}

level3 = {
   bpm = 40,
   oss={
      12,0
   }
}

levels = {
   level1, "dark earth", 6,10,
   level2, "rapture", 5,5,
   level3, "foreigner", 21,16,
}

function init_level(level)
   level = levels[level * 4 - 3]

   local t = 0
   local i = 1

   while i < #level.oss do

      local os = level.oss[i]

      if os == e_next_beat then
         t += level.bpm
         i += 1
      elseif os == e_laserh then
         laserh_prefab(t, level.oss[i+1],
                       level.oss[i+2])
         i += 3
      elseif os == e_laserv then
         laserv_prefab(t, level.oss[i+1],
                       level.oss[i+2])
         i += 3
      elseif os == e_bulleth then
         bulleth_prefab(t, level.oss[i+1],
                        level.oss[i+2])
         i += 3
      elseif os == e_bulletv then
         bulletv_prefab(t, level.oss[i+1],
                        level.oss[i+2])
         i += 3
      elseif os == e_bulletd then
         bulletd_prefab(t, level.oss[i+1],
                        level.oss[i+2],
                        level.oss[i+3])
         i += 4
      elseif os == e_bomb then
         bomb_prefab(t, level.oss[i+1],
                     level.oss[i+2],
                     level.oss[i+3])
         i += 4
      elseif os == e_bigscale then
         bigscale_prefab(t, level.oss[i+1],
                         level.oss[i+2],
                         level.oss[i+3])

         i += 4
      elseif os == e_edgeh then
         edgeh_prefab(t, level.oss[i+1])
         i+= 2
      elseif os == e_edgev then
         edgev_prefab(t, level.oss[i+1])
         i+= 2         
      elseif os == e_sweeph then
         sweeph_prefab(t, level.oss[i+1],
                       level.oss[i+2],
                       level.oss[i+3])
         i+= 4
      elseif os == e_sweepv then
         sweepv_prefab(t, level.oss[i+1],
                       level.oss[i+2],
                       level.oss[i+3])
         i+= 4
      elseif os == e_boss then
         boss_prefab(t)

         i+= 1
      else
         i = throw
      end

   end
   
end

-->8

function reset_stats(level)
   stats = {
      current=level,
      flawless=true,
      death=0,
      distance=0,
      dash=0
   }
end

function init_menu(menu)

   local i = menu.data and menu.data.i or 0

   menu.data = {
      t=0,
      i=i,
      spin=0
   }

end

function update_menu(menu)

   menu.data.t += 1

   if btnp(⬆️) then
      sfx(2)
      menu.data.spin=-5
   end

   if btnp(⬇️) then
      sfx(2)
      menu.data.spin=5
   end

   if btnp(❎) then
      reset_stats(menu.data.i + 1)
      transition(play_scene)
   end

   if menu.data.spin < 0 then
      menu.data.spin+=1
      if menu.data.spin == 0 then
         menu.data.t = 0
         menu.data.i-=1
         menu.data.i += #levels/4
         menu.data.i %= #levels/4
      end
   end

   if menu.data.spin > 0 then
      menu.data.spin-=1
      if menu.data.spin == 0 then
         menu.data.t = 0
         menu.data.i+=1
         menu.data.i %= #levels/4
      end
   end

end

function draw_menu(menu)
   cls()

   rectfill(0,0,128,128,8)

   color(7)

   local name = levels[(menu.data.i + 1) * 4 - 2]
   local si = levels[(menu.data.i + 1) * 4 - 1]

   if #completed < 3 then
      sspr(0,32,16,16,48,8,32,32)
   else
      sspr(flr(menu.data.t % 120 / 120 * 8)*16,72,16,16,48,8,32,32)
   end

   local lx = (si % 16) * 8
   local ly = flr(si / 16) * 8

   if (menu.data.t % 30 < 20) then
      sspr(lx,ly,8,8,64,64,32,32)
   end

   if completed[menu.data.i+1] then
      if menu.data.t % 60 > 50 then
         sspr(flr(menu.data.t % 15 / 15 * 4)*8,64,8,8,104,70,16,16)
      else
         sspr(0,64,8,8,104,70+sin(menu.data.t%60/60)*2,16,16)
      end
   end

   color(7)
   print("❎ to select", 8 + sin(menu.data.t % 60 / 60) * 2, 48)
   print("⬆️", 24, 48+8)
   print(".-------.", 10, 48+16)
   print("-", 0, 48+32)

   rectfill(6,
            48+32-4,
            48,
            48+32+8)

   color(8)
   print(name, 28 - (#name/2) * 4, 
         48+32 + 
            (menu.data.spin != 0 and (sgn(menu.data.spin) - menu.data.spin / 5) * 8 or 0))
   color(7)
   print("-", 52,48+32)
   print(",_______,", 10, 48+48)
   print("⬇️", 24, 48+64)

   
end

function init_end(scene, stats)
   dbg=scene
   music(-1)

   sfx(7)

   completed[stats.current] = true

   scene.stats = stats
   scene.data = {
      t=0
   }
end

function update_end(scene)
   scene.data.t += 1

   if scene.data.t > 15 and btnp(❎) then
      transition(menu_scene)
   end
end

function draw_end(scene)
   cls()

   rectfill(0,0,128,56,8)
   rectfill(0,56,128,128,7)
   rectfill(0,40,128,48,7)
   rectfill(0,30,128,34,7)
   rectfill(0,24,128,26,7)

   local name = levels[stats.current * 4 - 2]
   local si = levels[stats.current * 4 - 1]

   print(name, 40 + scene.data.t * 0.8 % 180 - 80, 30, 8)

   print("(*-^) completed *0_0*  completed  (;o;)  completed", scene.data.t * 2 % 320 - 180, 50, 7)


   pal(7,8)
   if scene.data.t % 60 > 50 then
      sspr(flr(scene.data.t % 15 / 15 * 4)*8,64,
           8,8,84,76,32,32)
   else
      sspr(0,64,8,8,
           84,76+sin(scene.data.t%60/60)*2,
           32,32)
   end
   pal()

   if stats.flawless then
      if scene.data.t % 20 < 10 then
         print("-flawless!-", 16, 64, 8)
      else
         rectfill(14, 64, 60,68, 8)
         print("-flawless!-", 16, 64, 7)
      end
   end

   print("death:", 36, 72 + 16, 8)
   print(scene.stats.death, 64, 72 + 16, 8)

   print("distance:", 24, 80 + 16)
   print(flr(scene.stats.distance), 64, 80 + 16, 8)

   print("dash:", 40, 88 + 16)
   print(scene.stats.dash, 64, 88 + 16, 8)

end

-->8

end_scene = {
   init=init_end,
   update=update_end,
   draw=draw_end
}

menu_scene = {
   init=init_menu,
   update=update_menu,
   draw=draw_menu
}

play_scene = {
   init=init_play,
   update=update_play,
   draw=draw_play
}

function _init()
   completed = {}
   scene = menu_scene
   scene.init(scene)
end

function _update()
   scene.update(scene)
end

function _draw()
   scene.draw(scene)
end

function transition(_scene, args)
   scene = _scene
   scene.init(scene, args)
end

-->8
-- https://stackoverflow.com/questions/9324339/how-much-do-two-rectangles-overlap/9325084
function box_intersect_ratio(a,b)
   
   local xa1=a.x
   local xa2=a.x+a.w
   local ya1=a.y
   local ya2=a.y+a.h
   local xb1=b.x
   local xb2=b.x+b.w
   local yb1=b.y
   local yb2=b.y+b.h
   
   local sa = a.w*a.h
   local sb = b.w*b.h

   local si = max(0, min(xa2,xb2)-
                     max(xa1,xb1))*max(0,min(ya2,yb2)-
                                          max(ya1,yb1))
   
   --local su = sa+sb-si
   
   return si/sa
end
-->8
function ease_linear(t)
   return t
end

function ease_inquad(t)
   return t*t
end

function ease_outquad(t)
   return t*(2-t)
end

function ease_incubic(t)
   return t*t*t
end

function lerp(target,value,t)
   return value + (target - value)*t
end

function appr(target,value,amount)
   if target<value then
      return max(target, value-amount)
   else
      return min(target, value+amount)
   end
end

function clamp(_min, _max, value)
   return max(_min, min(_max, value))
end

function sign(value)
   return value < 0 and -1 or
      value > 0 and 1 or 0
end

function maybe(r)
   return rnd() < r
end

function avalue(path, t, period)
   return path[flr((t*period)%(#path)+1)]
end

function close(a, b)
   return abs(a-b)<0.0001
end

function append(cs, vs)
   for v in all(vs) do
      add(cs, v)
   end
end

function vdist(v1,v2)
   local dx = v1.x-v2.x
   local dy = v1.y-v2.y
   return sqrt(dx*dx+dy*dy)
end

function _vlength(x,y)
   return sqrt(x*x+y*y)
end
__gfx__
00000000000000000007700000000000000000007777777700777700777777770077770077777777007777007777777700777700000000000000000000000000
00000000077777700077770000000000000000007777700707777770777777770770077077777777077777707777777707777700000000000000000000000000
00700700077777700777777000000000000000007777770777777777777777777777077777777777777777777777777777777007000000000000000000000000
00077000077777707777777700000000000000007777777777777707777777777777777777777777777777770000000077770077000000000000000000000000
00077000077777707777777700000000000000007777777777777007707777777777777777777777777777770000000077700777000000000000000000000000
00700700077777700777777000000000000000007777777777777777700777777777777777777777777777777777777777007777000000000000000000000000
00000000077777700077770000000000000000007777777707777770777777770777777077777777077777707777777700077770000000000000000000000000
00000000000000000007700000000000000000007777777700777700777777770077770077777777007777007777777700777700000000000000000000000000
00000000000000000000000000000000000000000000000000770000000000000000770000077000770000770007700077000077000000000000000000000000
00000000000770000777700000077770000000000007700000777000000000000007770000077000777007770007700077700777000000000000000000000000
00000000007777000077770000777770000000000077770000777770777777770777770000077000077007700007700007700770000000000000000000000000
00000000077777700707777007777770000000000077770000777777777777777777770077777777000770007777777700077000000000000000000000000000
00000000077777700707777070077770000000000777777000777777077777707777770077777777000770007777777700077000000000000000000000000000
00000000077007700077770000707700000000007777777700777770007777000777770000077000077007700007700007700770000000000000000000000000
00000000070770700777700000007000000000007777777700777000007777000007770000077000777007770007700077700777000000000000000000000000
00000000000000000000000000070000000000000000000000770000000770000000770000077000770000770007700077000077000000000000000000000000
00000000000000000000000000000000000000000077770000777700007777000077770000777700007777000007770000077700000000000000000000000000
00000000000000000000000000000000000000000777777007777770077777700777777007777070070000700770077007777770000000000000000000000000
00000000000770000000000000000000000000007777707777777777777777777707777777700007700000707000007077000777000000000000000000000000
00000000007777000000000000000000000000007777777777777777777777777777777777000007770000077000007770000077000000000000000000000000
00000000007777000000000000000000000000007777777777777777777777777777777777000007770000077000007770000077000000000000000000000000
00000000000770000000000000000000000000007777777777777077770777777777777707000007777000777000077707000007000000000000000000000000
00000000000000000000000000000000000000000777777007777770077777700777777007700770077777700707777007000070000000000000000000000000
00000000000000000000000000000000000000000077770000777700007777000077770000777000007770000077770000777700000000000000000000000000
00000000077777700000000000000000000000000007700000777000000000000007770000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000077770000077700000000000077700000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000777777000007770700000070777000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000007770077700000777770000777770000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000007700007700000777777007777770000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000007000000700007770077777700777000000000000000000000000000000000000000000000000000000000000
00000000777777770000000000000000000000000000000000077700007777000077700000000000000000000000000000000000000000000000000000000000
00000000077777700000000000000000000000000000000000777000000770000007770000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000070070000777700777777770077770000700700000000000000000000000000000000000000000000000000
77000000000000070000000000000000000000000070070007777770777777770778877000700700000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000007777777777777777777777777777877777777777000000000000000000000000000000000000000000000000
70077770000000070000000000000000000000000070070077777787777777777777777700700700000000000000000000000000000000000000000000000000
70077070007770070000000000000000000000000070070077777887787777777777777700700700000000000000000000000000000000000000000000000000
70070070000000070000000000000000000000007777777777777777788777777777777777777777000000000000000000000000000000000000000000000000
70077770000000070000000000000000000000000070070007777770777777770777777000700700000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000000070070000777700777777770077770000700700000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000000000000000770000000000000000770000077000000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000000007700000777000000000000007770000077000000000000000000000000000000000000000000000000000
70000000007000070000000000000000000000000070070000777770777777770777770000077000000000000000000000000000000000000000000000000000
70000077777000070000000000000000000000000070070000777777777777777777770000077000000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000000707007000777777077777707777770000077000000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000007070000700777770007777000777770000000000000000000000000000000000000000000000000000000000
70000000000000070000000000000000000000007000770700777000007777000007770000077000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000000000000770000000770000000770000077000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077070000777700007777000077770000777700007777000007770000077700000000000000000000000000
00000000000000000000000000000000000000000700007007777770077777700777777007777070070000700770077007777770000000000000000000000000
00000000000000000000000000000000000000007007700777777777777777777787777777700007700000707000007077000777000000000000000000000000
00000000000000000000000000000000000000000070070777777777777777777777777777000007770000077000007770000077000000000000000000000000
00000000000000000000000000000000000000007070070077777777777777777777777777000007770000077000007770000077000000000000000000000000
00000000000000000000000000000000000000007007700777777877778777777777777707000007777000777000077707000007000000000000000000000000
00000000000000000000000000000000000000000700007007777770077777700777777007700770077777700707777007000070000000000000000000000000
00000000000000000000000000000000000000000070770000777700007777000077770000777000007770000077770000777700000000000000000000000000
00000000000000000000000000000000000000000007700000777000000000000007770000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000070070000077700000000000077700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700007000007770700000070777000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007007700700000777770000777770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000777777007777770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000000700007770077777700777000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000077700007777000077700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000777000000770000007770000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007000000070000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077000000770000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000777000007777000000770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77007770000077707700007077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700007777007000070077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777000077770000000700007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770000007700000007000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77000000000000077770000000000007770000000000000777770000000000077770000000000007770000000000000777770000000000077770000000000007
70000000000000077700000000000007700000000000000777700000000000077700000000000007700000000000000770000000777777077700000000000007
70077770000000077007777000700707700777700077700777000000000000077007777000777707700777700000000770077770700007077077777007777707
70077070007770077007000000077007700770700070700770077770077770077007707000707707700770700077700770077070700007077070007007700707
70070070000000077007000000077007700700700070700770000000000000077007007000700707700700700000000770070070700007077070007007000707
70077770000000077007000000700707700777700077700770000000000000077007777000777707700777700000000770077770700007077070007007000707
70000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000777777077077777007777707
70000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007
70000000000000077000000770000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007
70000000007000077000007007000007700000700000000770000000000000077000000000700007700000000070000770000070000000077000000000700007
70000077777000077000007007000007700000777770000770000000000000077000007777700007700000777770000770000077777000077000077777700007
70000000000000077000000770000007700000000000000770000077777000077000000000000007700000000000000770000000007000077000007770000007
70000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000007770000007
70000000000000077000000000000007700000000000000770000000000000077000000000000007700000000000000770000000000000077000000000000007
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888882282288882288228882228228888888ff888888228888
888882888888888ff8ff8ff88888888888888888888888888888888888888888888888888888888888228882288822222288822282288888ff8f888888222888
88888288828888888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888ff888f888888288888
888882888282888ff8ff8ff888888888888888888888888888888888888888888888888888888888882288822888222222888888222888ff888f888822288888
8888828282828888888888888888888888888888888888888888888888888888888888888888888888228882288882222888822822288888ff8f888222288888
888882828282888ff8ff8ff8888888888888888888888888888888888888888888888888888888888882282288888288288882282228888888ff888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
555555e555577757775555e555555555555665666566555506600600000055555555555555555555565555665566566655506660666000055066606660000555
55555ee555575755575555ee55555555556555656565655500600600000055555555555555555555565556565656565655506060606000055000600060000555
5555eee555575757775555eee5555555556665666565655500600666000055555555555555555555565556565656566655506060606000055006606660000555
55555ee555575757555555ee55555555555565655565655500600606000055555555555555555555565556565656565555506060606000055000606000000555
555555e555577757775555e555555555556655655566655506660666000055555555555555555555566656655665565555506660666000055066606660000555
55555555555555555555555555555555555555555555555500000000000055555555555555555555555555555555555555500000000000055000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555666665777775666665666665555555666666665666666665666666665666666665cccccccc566666666566666666566666666555555555
555556655665666555655665755575655565656565555555666776665666667665666666775667777765cccc777c566766666566766676566677666555dd5555
555565656555565555665665777575666565656565555555667667665666776765666677675667666765cccc7c7c56767666657676767656677776655d55d555
555565656555565555665665755575665565655565555555676666765677666765667766675667666765cccc7c7c57666767657777777756776677655d55d555
55556565655556555566566575777566656566656555555576666667576666667577666667577766677577777c77576667767567676767577666677555dd5555
555566555665565555655565755575655565666565555555666666665666666665666666665666666665cccccccc566666666567666667566666666555555555
55555555555555555566666577777566666566666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555005005005005005dd500566555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555565655665655555005005005005005dd5665665555555dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd555555555
555565656565655555005005005005005775665665555555dddddddd5d55ddddd5dd5dd5dd5ddd55ddd5ddddd5dd5775777775dddddddd5dddddddd555555555
555565656565655555005005005005665775665665555555dddddddd5d555dddd5d55d55dd5dddddddd5dddd55dd57755777755d5d5d5d5d55dd55d555555555
555566656565655555005005005665665775665665555555ddd55ddd5dddd555d5dd55d55d5d5d55d5d5ddd555dd57755577755d5d5d5d5d55dd55d555555555
555556556655666555005005665665665775665665555555dddddddd5ddddd55d5dd5dd5dd5d5d55d5d5dd5555dd5775555775dddddddd5dddddddd555555555
555555555555555555005665665665665775665665555555dddddddd5dddddddd5dddddddd5dddddddd5dddddddd5777777775dddddddd5dddddddd555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600e0e00ccc0000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507000000000600e0e00c000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507700000066600eee00ccc0000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550700000006000000e0000c0000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
5550777000006660000e00ccc000d000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600e0e00ccc000000055000000000000000000000000000005507770000066000e0e00ccc00000005500000000000000000000000000000555
55507000000000600e0e00c00000000055000000000000000000000000000005507000000006000e0e00c0000000005500000000000000000000000000000555
55507700000066600eee00ccc000000055000000000000000000000000000005507700000006000eee00ccc00000005500000000000000000000000000000555
5550700000006000000e0000c00000005500000000000000000000000000000550700000000600000e0000c00000005500000000000000000000000000000555
5550777000006660000e00ccc000d0005500100010001000010000100001000550777000006660000e00ccc000d0005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55507770000066600e0e00ccc00ddd0055000000000000000000000000000005507770000066000e0e00ccc00000005500000000000000000000000000000555
55507000000000600e0e00c0000d000055000000000000000000000000000005507000000006000e0e00c0000000005500000000000000000000000000000555
55507700000066600eee00ccc00ddd0055000000000000000000000000000005507700000006000eee00ccc00000005500000000000000000000000000000555
5550700000006000000e0000c0000d005500000000000000000000000000000550700000000600000e0000c00000005500000000000000000000000000000555
5550777000006660000e00ccc00ddd005500100010001000010000100001000550777000006660000e00ccc000d0005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005501111111aaaaa111111111111111055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005507771111a66aa1e1e11ccc11111105507770000066000e0e00ccc00ddd005500000000000000000000000000000555
555000000000000000000000000000005507171111aa6aa1e1e11c1111111105507000000006000e0e00c0000d00005500000000000000000000000000000555
555000000000000000000000000000005507771111aa6aa1eee11ccc11111105507700000006000eee00ccc00ddd005500000000000000000000000000000555
555000000000000000000000000000005507171111aa6aa111e1111c1111110550700000000600000e0000c0000d005500000000000000000000000000000555
555001000100010000100001000110005507171111a666a111e11ccc111d110550777000006660000e00ccc00ddd005500100010001000010000100001000555
555000000000000000000000001710005501111111aaaaa111111111111111055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000177100550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000177710550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000001777715507770000066000e0e00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000001771105507070000006000e0e00c0000d000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000117105507770000006000eee00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550707000000600000e0000c0000d0055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550707000006660000e00ccc00ddd0055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550010001000100001000010000100055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005500000000000000000000000000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
555000000000000000000000000000005507770707066000e0e00ccc0000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
555000000000000000000000000000005507000777006000e0e00c000000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
555000000000000000000000000000005507700707006000eee00ccc0000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
55500000000000000000000000000000550700077700600000e0000c0000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
55500100010001000010000100001000550700070706660000e00ccc000d000550a1aaa1aaa1aaaa1aaaa1aaaa1aa05500100010001000010000100001000555
555000000000000000000000000000005500000000000000000000000000000550aaaaaaaaaaaaaaaaaaaaaaaaaaa05500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005507770707066000e0e00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005507000777006000e0e00c0000d000055000000000000000000000000000005500000000000000000000000000000555
555000000000000000000000000000005507700707006000eee00ccc00ddd0055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550700077700600000e0000c0000d0055000000000000000000000000000005500000000000000000000000000000555
55500100010001000010000100001000550700070706660000e00ccc00ddd0055001000100010000100001000010005500100010001000010000100001000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
0101000018320113301c350143602136017350133500d3500a3500e350073500e3500933006320083100631009310043500135000400002000020000200002000020000200002000020000200002000020000200
010300000f7540f750137521375200000167541675216755007030070300703007030070300703000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000045501a5501d5501c55020550205502255000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010f00201c2121144510442114451c4411d4451d44121445000002341521441234450040123445234412344500401114451c4411d44500401114451c4411d445000001c4451d4411c445000001c4451d4411c445
010400001605514050160501800012050130501205012050107561105010050180000f0500f0500f03010020180000e0100f010180000c7500e7500c750180001a7500d7501a7500c000187500c7501875000000
011000001c7531c73610755107261c753007060070600706007060070613736137531372613753137260070600706007060070600706007060070600706007060070600706000000000000000000000000000000
010c00001a2551c2551c2551d2551d215002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205002050020500205
011000001c7501d750207502f75024750267502875028710007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700000000000000000
011000002b53100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0a00116331f4111e435116331f4131e415116331f411116331f41321435116331f41100613116331f413116331f4131d435116331f4111d415116331f413116331f41120435116331f41120415204351f411
011e000000700215311e5332353523536007001d5312053323535235360070020531215332353523536007002053121533235352353600000215311e533235352353600000000001d53120536205362053600000
011400001c0201f0201f010000001c010210202102000000210201f0201f010000001f0101c0201c020000001c0201f0201f010000001c010230202302000000230201f0201f0101c0001f0101c0201c02000000
011400001f0100000010010000001f01000000100100000028010000000c0100000023010000000c010000001f0100000010010000002401000000150100000026010000000c010000001f010000000c01000000
010f00001c2121144510442114451c4411d4451d44121445000002341521441234450040123445234412344500401114451c4411d44500401114451c4411d445000001c4451d4411c445000001c4451d4411c445
010f00001d425214421d44511443214251d442214452344121425214412144513441214251d44121445234411d425214411d4451d443214251c44121445214411c425214421c445104411c4251d4411d4451d441
011100001c35500305213552435521355213502135500305243550030521355183551f3551f3501f3550030521355000001f355183551f355000001d355213550000021355000001835521355000002135521355
011100080000000000000000c6310c611006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010000000000000000000000000
01110020133550000000000000001534515345153450000013057000000000000000133551035510315000001d355270071805500000110551305515055000000000000000000000000011355153551131511057
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400001c0101101000000000001c0100000011010000001f0101100000000110101e01000000000000000021010110100000000000200100000011010000002101000000000001101023010000000000000000
__music__
00 02424344
00 41034344
01 0a0b4344
02 0a0b4344
00 41424344
01 0e4a4344
02 0f4e4344
00 41424344
00 41424344
00 41424344
01 0c0d4344
00 0c0d4344
00 0d145044
02 0c424344
00 14154344
03 10514311
03 10124311

