pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

dbg = nil

side_player = {
   name="p1",
   bg=7,
   score_delay=0,
   shake=0
}

side_ai = {
   name="ai",
   bg=15,
   score_delay=0,
   t=0,
   idea={}
}

function _init()
   poke(0x5f2c, 3)
   cls()

   scene=scene_title

   init_scene_intro()
end

function update_player(player)
   -- ⬆️⬇️⬅️➡️❎🅾️

   local game = player.game

   if btnp(⬅️) then
      game_left(game)
   elseif btnp(➡️) then
      game_right(game)
   end

   if btnp(⬆️) then
      game_up(game)
   elseif btnp(⬇️) then
      game_down(game)
   end

   if btnp(❎) then
      game_shift(game)
   end

   dbg = game.combo

   if player.shake > 0 then
      player.shake -= 1
   elseif game.combo > 1 then
      player.shake = game.combo
   end
end

function update_game_score(a, b)
   if a.score_delay > 0 then
      a.score_delay -= 1
      if a.score_delay == 3 then
         a.score += a.game.add_score
         a.game.add_score = 0
      end
   elseif a.game.add_score > 0 then
      begin_roll(b.game)
      if a.name == "ai" then
         begin_roll(b.game)
         begin_roll(b.game)
      end
      a.score_delay = 10
   end

   if a.game.over then
      a.game_result = "lose"
      b.game_result = "win"
      init_scene_over()
      scene = scene_over
   end
end

function update_scene_play()
   update_player(side_player)
   update_ai(side_ai)

   update_game(side_player.game)
   update_game(side_ai.game)

   update_game_score(side_player, side_ai)
   update_game_score(side_ai, side_player)

   if side_player.game.sfx != nil then
      sfx(side_player.game.sfx)
   elseif side_ai.game.sfx != nil and maybe(0.2) then
      sfx(side_ai.game.sfx)
   end
end

function draw_scene_play()

   draw_side(side_player, 0)
   draw_side(side_ai, 32)
end

function init_scene_play()
   scene = scene_play
end

scene_play = {
   update=update_scene_play,
   draw=draw_scene_play
}

function update_scene_intro()
   scene_intro_data.t += 1

   if scene_intro_data.t < 30 * 3 then
      if scene_intro_data.t % 30 == 1 then
         sfx(4)
      end
   elseif scene_intro_data.t % 30 == 1 then
      sfx(5)
      sfx(6)
   end

   if scene_intro_data.t == 30 * 4 then
      init_scene_play()
   end
end

function draw_scene_intro()
   draw_side(side_player, 0)
   draw_side(side_ai, 32)   

   local _t = scene_intro_data.t / (30 * 3)

   circfill(32 + 1, 32 + 1, 16, 1)
   circfill(32, 32, 16, 13)

   if _t < 1 then
      local i = flr(_t * 3)
      sspr(i * 16, 32, 16, 16, 24, 24)
   else
      _t = (scene_intro_data.t - (30 * 3)) / 30

      sspr(3 * 16, 32, 16, 16, 16, 24)
      sspr(4 * 16, 32, 16, 16, 32, 24)
   end

end

function init_scene_intro()

   side_player.score=0
   side_ai.score = 0

   side_player.game = init_game_data(1)
   side_ai.game = init_game_data(1)

   scene_intro_data = {
      t = 0
   }

   scene = scene_intro
end

scene_intro = {
   update=update_scene_intro,
   draw=draw_scene_intro
}

function update_scene_title()
   if btnp(❎) then
      init_scene_intro()
   end

   scene_title_data.t += 1
end

function draw_scene_title()

   local t = scene_title_data.t % 30 / 30

   sspr(0, 64, 32, 32, 8, 8 + sin(t + 0.2) * 8, 16, 16)
   sspr(32, 64, 32, 32, 8 + 4 + 8 * 2, 8 + sin(sin(sin(t) * 0.5) * 0.25) * 8, 16, 16)
   sspr(32 * 2, 64, 32, 32, 8 + 8 + 8 * 4, 8 + sin(sin(t + 0.7) * 0.5) * 8, 16, 16)

   print("marbles", sin(t) * 8 + 24 + 1, 33, 1)
   print("marbles", sin(t) * 8 + 24, 32, 7)

   print("press ❎", 16, 32 + 16, 1)
end

scene_title_data = {
   t = 0
}

scene_title = {
   update=update_scene_title,
   draw=draw_scene_title
}

function update_scene_over()

   scene_over_data.t += 1

   if scene_over_data.fill_delay > 0 then
      scene_over_data.fill_delay -= 1
   end

   if scene_over_data.t > 30 then
      if btnp(❎) then
         init_scene_intro()
      end
   end

end

function draw_result(side, x)
   local t = (1.0 - scene_over_data.fill_delay / 10)
   local _x = x + 16 - t * 16
   local _w = t * 32

   rectfill(_x, 32, _x + _w, 32 + 6, side.bg)

   rectfill(_x, 32 + 16, _x + _w, 32 + 16 + 6, side.bg)

   if t == 1 then
      t = (scene_over_data.t % 10) / 10
      local offx = sin(t) * 0.2
      local offy = cos(t) * 0.2

      print(side.game_result, x + offx + 8, 32 + offy + 1, 1)

      if scene_over_data.t > 30 and scene_over_data.t % 10 < 7 then
         print("press ❎", 16, 32 + 16 + 1, 1)
      end
   end
end

function draw_scene_over()
   draw_side(side_player, 0)
   draw_side(side_ai, 32)

   draw_result(side_player, 0)
   draw_result(side_ai, 32)
end

function init_scene_over()
   scene_over_data = {
      fill_delay=10,
      t=0
   }
end

scene_over = {
   update=update_scene_over,
   draw=draw_scene_over
}

function draw_side(side, x)

   rectfill(x, 0, x + 32, 64, side.bg)

   local game = side.game

   local i = game.i

   for stack in all(game.stacks) do
      draw_stack(game, stack, x)
   end

   camera()

   rectfill(x, 0, x + 32, 4, 1)
   print(side.name, x, 0, side.bg)
   print(side.score, x + 16, 0, side.bg)

   

   local _x

   if side.name == "p1" then
      _x = x + (side.score_delay / 10) * 32
   else
      _x = x + 32 - (side.score_delay / 10) * 32
   end

   rectfill(_x, 0, _x + (side.score_delay / 10) * 32, 4, side.bg)

   rect(x, 32, x + 31, 32 + 6, 1)

   rect(x + 1 + i * 6, 32, x + 1 + i * 6 + 5, 32 + 6, 10)
end

function _update()
   scene.update()
end

function _draw()
   cls()

   scene.draw()

   print(dbg, 0, 64 - 5, 1)
end

-->8

game_template = {
   i=3,
   over=false,
   add_score=0,
   shift_delay=0,
   sfx_timer=0,
   sfx=nil,
   combo=0,
   combo_delay=0
}

function init_game_data(height)
   local data = {}
   merge(data, game_template)

   data.stacks = {}

   for i=1,5 do
      local stack = {
         i=i,
         top={},
         bottom={},
         center=make_marble(),
         move_delay=0,
         lose_delay=0,
         fall_delay=0,
         short_delay=0,
         roll_delay=0
      }

      for i=1,height do
         add(stack.top, make_marble())
         add(stack.bottom, make_marble())
      end

      data.stacks[i] = stack
   end
   
   return data
end

max_move_delay = 10
max_roll_delay = 10
top_height = 5

match_indexes = {
   { 1, 2, 3, 4, 5 },
   { 1, 2, 3, 4 },
   { 2, 3, 4, 5 },
   { 1, 2, 3 },
   { 2, 3, 4 },
   { 3, 4, 5 }
}

function update_stack(game, stack)

   if stack.move_delay > 0 then
      stack.move_delay -= 1
      if stack.move_delay == 0 then
         move_stack(game, stack)
      end
   end

   if stack.lose_delay > 0 then
      stack.lose_delay -= 1
      if stack.lose_delay == 0 then
         begin_fall_after_lose_stack(game, stack)
      end
   end

   if stack.fall_delay > 0 then
      stack.fall_delay -= 1
      if stack.fall_delay == 0 then
         fall_stack(game, stack)
      end
   end

   if stack.short_delay > 0 then
      stack.short_delay -= 1
      if stack.short_delay == 0 then
      end
   end

   if stack.roll_delay > 0 then
      stack.roll_delay -= 1
      if stack.roll_delay == 0 then
         stack.ry -= 1
         stack.roll_delay=max_roll_delay
      end

      local ry = stack.ry - (1.0 - stack.roll_delay/max_roll_delay)

      if stack.ray == 1 then
         local y = stack_top_y(stack)
         if ry <= y+1 then
            add(stack.top, stack.rm)
            stack.roll_delay = 0
         end
      else
         local y = stack_bottom_y(stack)
         if ry <= y+1 then
            add(stack.bottom, stack.rm)
            stack.roll_delay = 0
         end
      end

   end

end

function draw_stack(game, stack, x)

   local j = stack.i - 1
   local mx = x + 1 + j * 6

   local my = 32

   local fally = 0
   local movey = 0
   local shiftx = 0

   local flash_hide = false

   local fall_animy = 0
   local shift_animy = 0
   local move_animy = 0

   if stack.move_delay > 0 then
      movey = (1.0 - stack.move_delay/max_move_delay) * 6 * stack.dy * -1
      move_animy = stack.move_delay/max_move_delay
   end

   if game.shift_delay > 0 then
      shiftx = (1.0 - game.shift_delay/10) * 6
      shift_animy = game.shift_delay/10
   end

   if stack.fall_delay > 0 then
      fally = (1.0-stack.fall_delay/10) * 6
      fall_animy = stack.fall_delay/10
   end

   if stack.short_delay > 0 then
      flash_hide = stack.short_delay % 3 == 0
   end


   my += movey

   if stack.lose_delay > 0 then

      draw_losing_marble(stack.center, mx + 1, my + 1, stack.lose_delay/10)

   elseif stack.fall_delay == 0 then

      if shift_animy != 0 then
         stack.center.s = (stack.center.s + 0.07) % 1
      end

      draw_marble(stack.center, mx + shiftx + 1, my + 1, shift_animy)
   end

   for i, marble in pairs(stack.top) do
      my = 32 - i * 6

      my += movey

      if move_animy != 0 then
         marble.s = (marble.s + 0.09) % 1
      end

      if stack.fy == 1 then
         my += fally

         if fall_animy != 0 then
            marble.s = (marble.s + 0.07) % 1
         end

      end

      if flash_hide and
         stack.sy == 1 and
      i == #stack.top then
      else
         draw_marble(marble, mx + 1, my + 1, 0)
      end
   end

   for i, marble in pairs(stack.bottom) do
      my = 32 + i * 6

      my += movey

      if move_animy != 0 then
         marble.s = (marble.s + 0.09) % 1
      end

      if stack.fy == -1 then
         my += fally * -1

         if fall_animy != 0 then
            marble.s = (marble.s + 0.07) % 1
         end
      end

      if flash_hide and
         stack.sy == -1 and
      i == #stack.bottom then
      else
         draw_marble(marble, mx + 1, my + 1, 0)
      end
   end


   if stack.roll_delay > 0 then
      my = 32 + stack.ry * stack.ray * 6 * -1

      fally = (1.0-stack.roll_delay/max_roll_delay) * 6 * stack.ray 

      my += fally

      stack.rm.s = (stack.rm.s + 0.07) % 1

      draw_marble(stack.rm, mx + 1, my + 1, 0)
   end
end

function draw_losing_marble(marble, x, y, delay)
   sspr(8 * 5 + flr((1.0-delay) * 4) * 4, 5 * marble.c, 4, 5, x, y)
end

function draw_marble(marble, x, y, animy)

   local shakex = 0
   local shakey = 0

   if side_player.shake > 0 then
      shakex=sin(rnd() * 0.6 + side_player.shake/3 * 0.4) * 0.5
      shakey=cos(rnd() * 0.6 + side_player.shake/3 * 0.4) * 0.5
   end

   camera(shakex, shakey)

   --print(marble, x, y, 1)
   sspr(8 + flr(marble.s * 3) * 4, 5 * marble.c, 4, 5, x, y)
end

function fall_stack(game, stack)
   if stack.fy == 1 then
      stack.center = stack.top[1]
      deli(stack.top, 1)

      if #stack.top < 2 then
         add(stack.top, make_marble())
         stack.sy = 1
         stack.short_delay=10
      end
   else
      stack.center = stack.bottom[1]
      deli(stack.bottom, 1)

      if #stack.bottom < 2 then
         add(stack.bottom, make_marble())
         stack.sy = -1
         stack.short_delay=10
      end
   end
end

function move_stack(game, stack)
   if stack.dy < 0 then
      add(stack.bottom, stack.center, 1)
      stack.center = stack.top[1]
      deli(stack.top, 1)
   else
      add(stack.top, stack.center, 1)
      stack.center = stack.bottom[1]
      deli(stack.bottom, 1)
   end
end

function begin_fall_after_lose_stack(game, stack)
   if #stack.top >= #stack.bottom then
      stack.fy = 1
   else
      stack.fy = -1
   end
   stack.fall_delay=10
end

function psfx(game, sfx)
   if game.sfx_timer == 0 then
      game.sfx = sfx
   end
end

function asfx(game, sfx)
   game.sfx_timer = 10
   game.sfx = sfx
end

function update_game(game)

   game.sfx = nil

   if game.sfx_timer > 0 then
      game.sfx_timer -= 1
   end

   local full_stacks = true
   local free_stacks = true

   for stack in all(game.stacks) do
      update_stack(game, stack)

      if stack.move_delay == 8 then
         psfx(game, 0)
      end

      if stack.lose_delay == 8 then
         if game.combo == 1 then
            asfx(game, 1)
         elseif game.combo == 2 then
            asfx(game, 2)
         else
            asfx(game, 3)
         end
      end

      if stack.move_delay != 0 or
         stack.lose_delay != 0 or
      stack.fall_delay != 0 then
            free_stacks = false
      end

      if #stack.top < 5 or #stack.bottom < 5 then
         full_stacks = false
      end
   end

   if full_stacks then
      game.over = true
   end


   if game.shift_delay > 0 then
      game.shift_delay -= 1
      if game.shift_delay == 0 then
         shift_marbles(game)
      end
   end

   if game.shift_delay == 9 then
      psfx(game, 0)
   end


   local free_to_match = game.shift_delay == 0 and
      free_stacks
   
   if free_to_match then

      for mi in all(match_indexes) do
         local nomatch = false
         local m = center_marble(game, mi[1])
         
         for i in all(mi) do
            if not marble_equal(center_marble(game, i),  m) then
               nomatch = true
               break
            end
         end

         if not nomatch then
            for i in all(mi) do
               game.stacks[i].lose_delay=10
            end
            game.combo += 1
            game.add_score=#mi * game.combo
            game.combo_delay = 3
            break
         end
      end

      if game.combo_delay > 0 then
         game.combo_delay -= 1
         if game.combo_delay == 0 then
            game.combo = 0
         end
      end
   end

   if free_to_match then
      local stack = game.stacks[game.i+1]

      if game.input_y == 1 then
         if #stack.top == 5 then
            asfx(game, 7)
         end
         if #stack.bottom > 0 and 
         #stack.top < 5 then
            stack.dy=1
            stack.move_delay=max_move_delay
         end
      elseif game.input_y == -1 then
         if #stack.bottom == 5 then
            asfx(game, 7)
         end
         if #stack.top > 0 and
         #stack.bottom < 5 then
            stack.dy=-1
            stack.move_delay=max_move_delay
         end
      end

      if game.input_x then
         game.shift_delay=10
      end
   end

   game_input_clear(game)
end

function begin_roll(game)
   local addi = smallest_height_i(game)
   local stack = game.stacks[addi]

   stack.rm = make_marble()
   stack.ry = 6

   if #stack.top == #stack.bottom then
      stack.ray=maybe(0.5) and 1 or -1
   elseif #stack.top < #stack.bottom then
      stack.ray=1
   else
      stack.ray=-1
   end

   if stack.roll_delay > 0 then
      return
   end

   stack.roll_delay=max_roll_delay
end

function stack_top_y(stack)
   local move_y = 0

   if stack.move_delay > 0 then
      move_y = (1.0-stack.move_delay/max_move_delay) * stack.dy
   end

   return #stack.top + move_y
end

function stack_bottom_y(stack)
   local move_y = 0

   if stack.move_delay > 0 then
      move_y = (1.0-stack.move_delay/max_move_delay) * stack.dy * -1
   end

   return #stack.bottom + move_y
end

function smallest_height_i(game)
   local smallest_i = 1
   local smallest_v = stack_height(game, smallest_i)

   for i=2,5 do

      if game.stacks[i].roll_delay > 0 then
         
      else
         local v = stack_height(game, i)
         if (v == smallest_v and maybe(0.5)) or
         v < smallest_v then
            smallest_i = i
            smallest_v = v
         end
      end
   end
   return smallest_i
end

function shift_marbles(game)
   for i=4,1,-1 do
      local pre=game.stacks[i+1]
      local cur=game.stacks[i]

      local t = pre.center
      pre.center=cur.center
      cur.center=t
   end
end

function stack_height(game, i)
   return #game.stacks[i].top +
      #game.stacks[i].bottom
end

function center_marble(game, i)
   local stack = game.stacks[i]

   return stack.center
end

function make_marble()
   return {
      c=flr(rnd(3)),
      s=0
   }
end

function marble_equal(a, b)
   return a.c == b.c
end

function game_left(game)
   if game.i != 0 then
      game.i -= 1
   end
end

function game_right(game)
   if game.i != 4 then
      game.i += 1
   end
end

function game_input_clear(game)
   game.input_y=0
   game.input_x=false
end

function game_up(game)
   game.input_y=1
end

function game_down(game)
   game.input_y=-1
end

function game_shift(game)
   game.input_x=true
end

-->8

ai_move_shift = 1
ai_move_up = 2
ai_move_down = 3
ai_move_left = 4
ai_move_right = 5

x_cursor=1
y_cursor=2
shift_cursor=3

function update_ai(ai)

   ai.t += 1

   if ai.t % 15 != 0 then
      return
   end

   local game = ai.game

   local handled = nil

   handled = handled or ai_shift_match(ai, game)
   handled = handled or ai_follow_idea(ai, game)
   handled = handled or ai_two_match(ai, game)
   handled = handled or ai_three_match(ai, game)

   handled = handled or ai_follow_idea(ai, game)

   handled = handled or ai_random_move(ai, game)

   ai_make_move(game, handled)

end

function ai_make_move(game, move)
   if move == ai_move_shift then
      game_shift(game)
   elseif move == ai_move_up then
      game_up(game)
   elseif move == ai_move_down then
      game_down(game)
   elseif move == ai_move_left then
      game_left(game)
   elseif move == ai_move_right then
      game_right(game)
   end
end

function ai_center_match_all(game, mi)
   local m = game.stacks[mi[1]].center
   for i in all(mi) do
      if not marble_equal(game.stacks[i].center, m) then
         return false
      end
   end
   return true
end

function ai_center_match_two(game, mi)
   local m = game.stacks[mi[1]].center
   local m2 = game.stacks[mi[2]].center
   return marble_equal(m, m2)
end

function ai_follow_idea(ai, game)
   local idea = ai.idea[1]
   if idea != nil then
      if idea.a == x_cursor then
         return ai_idea_x_cursor(ai, game, idea)
      elseif idea.a == y_cursor then
         return ai_idea_y_cursor(ai, game, idea)
      elseif idea.a == shift_cursor then
         return ai_idea_shift_cursor(ai, game, idea)
      end
   end      
end

function ai_idea_shift_cursor(ai, game, idea)
   del(ai.idea, idea)
   return ai_move_shift
end

function ai_idea_x_cursor(ai, game, idea)
   local to = idea.to
   if to == game.i+1 then
      del(ai.idea, idea)
      return ai_follow_idea(ai, game)
   elseif to < game.i+1 then
      return ai_move_left
   else
      return ai_move_right
   end
end

function ai_idea_y_cursor(ai, game, idea)
   local to = idea.to
   if to == 0 then
      del(ai.idea, idea)
      return ai_move_up
   elseif to < 0 then
      idea.to += 1
      return ai_move_down
   else
      idea.to -= 1
      return ai_move_up
   end
end

ai_shift_match_search = {
   { 1, 2, 5 },
   { 1, 5, 4 }
}

ai_three_match_search = {
   { 1, 3, 4 },
   { 2, 4, 5 },
   { 3, 1, 5 },
   { 4, 1, 2 },
   { 5, 2, 3 }
}

ai_two_match_search = {
   { 1, 2, 3 },
   { 2, 3, 4 },
   { 2, 3, 1 },
   { 3, 4, 5 },
   { 3, 4, 2 },
   { 1, 3, 2 },
   { 2, 4, 3 },
   { 3, 5, 4 }
}

function ai_two_match(ai, game)
   for mi in all(ai_two_match_search) do
      if ai_center_match_two(game, mi) then
         add(ai.idea, {
                a=x_cursor,
                to=mi[3]
         })
         add(ai.idea, {
                a=y_cursor,
                to=2
         })
         add(ai.idea, {
                a=y_cursor,
                to=-4
         })
         add(ai.idea, {
                a=shift_cursor
         })
         break
      end
   end
end

function ai_three_match(ai, game)
   for mi in all(ai_three_match_search) do
      if ai_center_match_all(game, mi) then
         local upi = mi[1]

         add(ai.idea, {
                a=x_cursor,
                to=upi
         })

         add(ai.idea, {
                a=y_cursor,
                to=0
         })
      end
   end
end

function ai_shift_match(ai, game)
   for mi in all(ai_shift_match_search) do
      if ai_center_match_all(game, mi) then
         return ai_move_shift
      end
   end

   return nil
end

function ai_random_move(ai, game)
   return flr(rnd(5)) + 1
end

-->8

function maybe(v)
   return rnd(1)<v
end

function merge(base, extend)
   for k,v in pairs(extend) do
      base[k] = v
   end
end

function seq_contains(seq, e)
   for a in all(seq) do
      if a == e then
         return true
      end
   end
   return false
end

__gfx__
00000000088006660880000000000000000000000660088008800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000685446888586000000000000000000006666685485000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700684888884486000000000000000000006666600800000880000000000000000000000000000000000000000000000000000000000000000000000000
00077000468484548888000000000000000000006666468460080000000000000000000000000000000000000000000000000000000000000000000000000000
0007700004806440088000000000000000000000066004a0004a0040000000000000000000000000000000000000000000000000000000000000000000000000
007007000aa006660aa00000000000000000000006600aa00aa00000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a5446aaa5a60000000000000000000066666a54a5000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a4aaaaa44a6000000000000000000006666600a00000aa0000000000000000000000000000000000000000000000000000000000000000000000000
0000000046a4a454aaaa00000000000000000000666646a4600a0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004a064400aa000000000000000000000066004a0004a0040000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc006660cc00000000000000000000006600cc00cc00000000000000000000000000000000000000000000000000000000000000000000000000000
000000006c5446ccc5c60000000000000000000066666c54c5000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006c4ccccc44c6000000000000000000006666600c00000cc0000000000000000000000000000000000000000000000000000000000000000000000000
0000000046c4c454cccc00000000000000000000666646c4600c0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004c064400cc000000000000000000000066004c0004c0040000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111111110000001111111111000000000111110000000000055555555000000055555500000000000000000000000000000000000000000000000000000
01122228888871000012222888887100000001228871000000005599999a66500000599999950000000000000000000000000000000000000000000000000000
11222288888887100122228888888710000011228887100000555999aaaa76550055999999966000000000000000000000000000000000000000000000000000
112228888888887112222228888887100001122888871000055999aaaaaaa76500599999999a7600000000000000000000000000000000000000000000000000
11222800888888811222222202888810000122288888110005999aaaaaaaaa65059999999aaa7750000000000000000000000000000000000000000000000000
0112000008888810122222000028888100112222888100005599aaaaaaaaaaa005999999aaaaaaa5000000000000000000000000000000000000000000000000
000000000888810002222000000288810011220288810000599aaaaa000000005999999aaaaaaaa5000000000000000000000000000000000000000000000000
000000012888100001120000002288810000000288810000599aaaa000555550599999aa09aaaaa5000000000000000000000000000000000000000000000000
000000012888810000000000022888100000000288710000599aaaa005aaa655599999a0009aaa76000000000000000000000000000000000000000000000000
000000000888871000000000228881000000000288710000559aaaa005aa7665599999aa099aaa76000000000000000000000000000000000000000000000000
0111000008888871000000022288100000000002888100005599aaaa00aa77a5599999aaaaaaaaa6000000000000000000000000000000000000000000000000
1112220088888881000000222281000000000022888100000599aaaaaaaaaaa5599999aaaaaaaaa5000000000000000000000000000000000000000000000000
11222288888888810000022228871000000001288887100005599aaaaaaaaaa5599999aaaaaaaaa5000000000000000000000000000000000000000000000000
112222288888881000012222888871000000128888887100005599aaaaaaaaa50599999aaaaaaaa5000000000000000000000000000000000000000000000000
012222888888810001112228888888810001228888888810000559aaaaaaaa500059999aaaaaa760000000000000000000000000000000000000000000000000
001111111111100001111111111111110001228888888810000000aaaaaa55000000059995556600000000000000000000000000000000000000000000000000
00011000001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100100010011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110100001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000011000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000001000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10001000110000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010100101000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010101101000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010011001000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10010000001000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10110000000101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000055888888888800000000000000000000aaaaa666aaaa00000000000000000000cccccccccccc000000000000000000000000000000000000000000
00000008855588888888888880000000000000066aaaaaa6666aaaaaa00000000000000cccccccccccccccccc000000000000000000000000000000000000000
00000088555588888888888888000000000000666aaaaaaa666aaaaaaa000000000000cccccccccccccccccccc00000000000000000000000000000000000000
00000888555888787888888888800000000006666aaaaaaaa66aaaaaaaa0000000000ccccccc7777ccccccccc666000000000000000000000000000000000000
0000888855887777778886666666000000006666aaa77777a66aaaaaaaaa00000000ccccc7777777ccccc6666666000000000000000000000000000000000000
00088888558777777786666666666000000a666aa7777777aaaaaaaaaaaaa000000cccccc7777777cccc66666666c00000000000000000000000000000000000
0088888855777777788666666666660000aa666a777777aaaaaaaaaaaaaaaa0000cccccc777777c555566666cccccc0000000000000000000000000000000000
088888888777778888666666888666600aaa66677777aaaaaaaaaaaaaaaaaaa00ccccc7777777cc5555666ccccccccc000000000000000000000000000000000
088888887777888888666668888866600aaa66777755aaaaaaaaaaaaaaaaaaa00cccc7777777ccc55555ccccccccccc000000000000000000000000000000000
088888877778888855666888888888800aaa67777a555aaaaaaaaaaaaaaaaaa00ccc7777777ccccc5555ccccccccccc000000000000000000000000000000000
88888877775588885566655588888888aaaa77776a5555aaaaaaaaaaaaaaaaaacccc777777cccccc5555cc6666cccccc00000000000000000000000000000000
88888777755558885555555588888888aaaa77766665555aaaaaaaaaaaaaaaaacccc7777ccccccccc555cc6666cccccc00000000000000000000000000000000
88888777855558888555555888888888aaa7776666655555aaaaaaaaaaaaaaaaccccc777cccccccc5555cccc666ccccc00000000000000000000000000000000
88887778855588885555558888888888aaa777a6666555555aaaaaaaaaaaaaaac666777cccccccc55555cccccc6666cc00000000000000000000000000000000
88887788885558885555588888888888aaa77aaaa555555555aaaaaaaaaaaaaa6666777ccccccc5555ccccccccc6666c00000000000000000000000000000000
66687788885558855555888888888866aaaaaaaaa555a555555aaaa555aaaaaa666cccccccccc5555cc55ccccccc666600000000000000000000000000000000
66668788888558855558888888888666aaaaaaaaaaaaaaa55555a55555aaaaaa66cccccccccc55555cc555ccccccc66600000000000000000000000000000000
86666888888888555588888888866666aaaaaaaaaaaaaaaaa555555555aaaaaaccccccccccc55555ccc555cccccccccc00000000000000000000000000000000
88666688888855555888888888866668aaaaaaaaaaaaaaaaaa55555555aaaaaacccccccccc555555cccc555ccccccccc00000000000000000000000000000000
88866666888855558888888888888888aaaaaaaaaaa55a555a55555566aaaaaaccccccccc555555cccc5555ccccc111c00000000000000000000000000000000
88886666668855588888888888888888555aaaaaaa5555555aaaaaaa666aaaaacccccccc55555555ccc5555ccccc111c00000000000000000000000000000000
888888666688555588888888888828885555aaaaaa555555aaaaaaaa6666a99acccccccc55566655cccc55ccccc1111c00000000000000000000000000000000
0888888888885555888888888822288005555aaaaaa555aaaaaa66aaa66699900cccccccccc66655cccccccccc1111c000000000000000000000000000000000
088888888888555558888888822288800a55555aaaaaaaaaaaaa66aaa69999900666cccccc6666cccccccccc111111c000000000000000000000000000000000
088888888866655558888882222888800aaaaaaaaaaaaaaaaaa666aa999999a006666cccc66666ccccccccc111111cc000000000000000000000000000000000
0088888866666555588888222288880000aaaaaaaaaaaaaaaaa6669999996a0000666666c6666ccccccccc111111cc0000000000000000000000000000000000
00086666666688888888222228888000000aaaaaaaaaaaaaaa66999999666000000666666666cccccccc111111ccc00000000000000000000000000000000000
000066666668882222222228888800000000aaaaaaaaaaa999999999aa66600000006666666ccccccc1111111ccc000000000000000000000000000000000000
0000666666888882222222888880000000000aaaaaaaaaa9999999aaaaa0000000000cccccccccc111111111ccc0000000000000000000000000000000000000
00000088888888882228888888000000000000aaaaaaaaa6666aaaaaaa000000000000ccccccccc111115555cc00000000000000000000000000000000000000
000000088888888888888888800000000000000aaaaaaaa666aaaaaaa00000000000000ccccccccccccc555cc000000000000000000000000000000000000000
000000000088888888888800000000000000000000aaaaa66aaaaa00000000000000000000cccccccccc55000000000000000000000000000000000000000000
__sfx__
010200002d7321d72233712247423b732337422b722317122b712297121b7021b7021b702037021a7021970219702007020070200702007020070200702007020070200702007020070200702007020070200702
0005000006050100501e0500d05027050150502f0501c050350502505036050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000d057140572305716057290571f0572605716057300571d05737057360070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
000400000d7571b75727757187572e757107572d75710757277571275731757387572a7573a757007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707
000300002306023060230602303023030230301900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002575025750257502575025750257502575000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200002c0522c0522f05225052290522505221052210521f0521c0521c0521305213052160522c0020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
00020000101501315018150131500a1500d1500815005150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
