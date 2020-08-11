pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

dbg = nil

side_player = {
   name="p1",
   bg=7,
   i = 3,
}

side_ai = {
   name="ai",
   bg=15,
   i = 3
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

   update_game(game)
end


function update_ai(ai)

   //update_game(ai.game)

end


function _update()
   update_player(side_player)
   update_ai(side_ai)
end

function draw_side(side, x)

   rectfill(x, 0, x + 32, 64, side.bg)

   local game = side.game

   local i = game.i

   rectfill(x, 0, x + 32, 4, 1)
   print(side.name, x, 0, side.bg)

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

   if stack.move_delay > 0 then
      movey = (1.0 - stack.move_delay/max_move_delay) * 6 * stack.dy * -1
   end

   if game.shift_delay > 0 then
      shiftx = (1.0 - game.shift_delay/10) * 6
   end

   if stack.lose_delay > 0 then
      rectfill(mx + 1, my + 1, mx + 5, my + 5, 2)
   end

   if stack.fall_delay > 0 then
      fally = (1.0-stack.fall_delay/10) * 6
   end

   if stack.short_delay > 0 then
      flash_hide = stack.short_delay % 3 == 0
   end


   my += movey

   if stack.fall_delay == 0 then
      print(stack.center, mx + shiftx + 1, my + 1, 1)
   end

   for i, marble in pairs(stack.top) do
      my = 32 - i * 6

      my += movey

      if stack.fy == 1 then
         my += fally
      end

      if flash_hide and
         stack.sy == 1 and
      i == #stack.top then
      else
         print(marble, mx + 1, my + 1, 1)
      end
   end

   for i, marble in pairs(stack.bottom) do
      my = 32 + i * 6

      my += movey

      if stack.fy == -1 then
         my += fally * -1
      end

      if flash_hide and
         stack.sy == -1 and
      i == #stack.bottom then
      else
         print(marble, mx + 1, my + 1, 1)
      end
   end


   if stack.roll_delay > 0 then
      my = 32 + stack.ry * stack.ray * 6 * -1

      fally = (1.0-stack.roll_delay/max_roll_delay) * 6 * stack.ray 

      my += fally

      print(stack.rm, mx + 1, my + 1, 1)
   end
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
            if center_marble(game, i) != m then
               nomatch = true
               break
            end
         end

         if not nomatch then
            for i in all(mi) do
               game.stacks[i].lose_delay=10
            end
               begin_roll(game)
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
   return flr(rnd(3))
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
