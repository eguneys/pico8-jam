pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

dbg = nil

side_player = {
   name="p1",
   bg=7,
   score=0
}

side_ai = {
   name="ai",
   bg=15,
   t=0,
   idea={},
   score=0
}

function _init()
   poke(0x5f2c, 3)
   cls()

   side_player.game = init_game_data(1)
   side_ai.game = init_game_data(1)
   
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
end

function update_game_score(a, b)
   if a.game.add_score > 0 then
      begin_roll(b.game)
      a.score += a.game.add_score
      a.game.add_score = 0
   end
end

function _update()
   update_player(side_player)
   update_ai(side_ai)

   update_game(side_player.game)
   update_game(side_ai.game)

   update_game_score(side_player, side_ai)
   update_game_score(side_ai, side_player)
end

function draw_side(side, x)

   rectfill(x, 0, x + 32, 64, side.bg)

   local game = side.game

   local i = game.i

   rectfill(x, 0, x + 32, 4, 1)
   print(side.name, x, 0, side.bg)
   print(side.score, x + 16, 0, side.bg)

   rect(x, 32, x + 31, 32 + 6, 1)

   for stack in all(game.stacks) do
      draw_stack(game, stack, x)
   end

   rect(x + 1 + i * 6, 32, x + 1 + i * 6 + 5, 32 + 6, 10)
end

function _draw()
   cls()

   draw_side(side_player, 0)
   draw_side(side_ai, 32)

   print(dbg, 0, 64 - 5, 1)
end

-->8

game_template = {
   i=3,
   add_score=0,
   shift_delay=0
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

   if stack.lose_delay > 0 then
      rectfill(mx + 1, my + 1, mx + 5, my + 5, 2)
   end

   if stack.fall_delay > 0 then
      fally = (1.0-stack.fall_delay/10) * 6
      fall_animy = stack.fall_delay/10
   end

   if stack.short_delay > 0 then
      flash_hide = stack.short_delay % 3 == 0
   end


   my += movey

   if stack.fall_delay == 0 then

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

function draw_marble(marble, x, y, animy)
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

function update_game(game)

   local free_stacks = true

   for stack in all(game.stacks) do
      update_stack(game, stack)

      if stack.move_delay != 0 or
         stack.lose_delay != 0 or
      stack.fall_delay != 0 then
            free_stacks = false
      end

   end


   if game.shift_delay > 0 then
      game.shift_delay -= 1
      if game.shift_delay == 0 then
         shift_marbles(game)
      end
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
            game.add_score=#mi
            break
         end
      end
   end

   if free_to_match then
      local stack = game.stacks[game.i+1]

      if game.input_y == 1 then
         if #stack.bottom > 0 then
            stack.dy=1
            stack.move_delay=max_move_delay
         end
      elseif game.input_y == -1 then
         if #stack.top > 0 then
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
      stack.ray=maybe() and 1 or -1
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
         if (v == smallest_v and maybe()) or
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

function update_ai(ai)

   ai.t += 1

   if ai.t % 15 != 0 then
      return
   end

   local game = ai.game

   local handled = nil

   dbg = #ai.idea > 0 and ai.idea[1].a

   handled = handled or ai_follow_idea(ai, game)

   handled = handled or ai_shift_match(ai, game)
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
      if game.stacks[i].center != m then
         return false
      end
   end
   return true
end

function ai_center_match_two(game, mi)
   local m = game.stacks[mi[1]].center
   for i=1,2 do
      if game.stacks[mi[i]].center != m then
         return false
      end
   end
   return true
end

function ai_follow_idea(ai, game)
   local idea = ai.idea[1]
   if idea != nil then
      if idea.a == x_cursor then
         return ai_idea_x_cursor(ai, game, idea)
      elseif idea.a == y_cursor then
         return ai_idea_y_cursor(ai, game, idea)
      end
   end      
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
   { 3, 4, 2 }
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

function maybe()
   return rnd(1)<0.5
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
00000000088006660880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000685446888586000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700684888884486000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000468484548888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000048064400880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000aa006660aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a5446aaa5a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a4aaaaa44a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000046a4a454aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004a064400aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc006660cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006c5446ccc5c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006c4ccccc44c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000046c4c454cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004c064400cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
