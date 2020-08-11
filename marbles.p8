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

   side_player.game = init_game_data(3)
   side_ai.game = init_game_data(3)
   
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

   local game = side.game

   rectfill(x, 0, x + 32, 64, side.bg)

   rectfill(x, 0, x + 32, 4, 1)
   print(side.name, x, 0, side.bg)


   rect(x, 32, x + 31, 32 + 6, 1)

   local i = game.i

   for i, marbles in pairs(game.marbles) do
      for j, marble in pairs(marbles.stack) do
         local mx = x+1+(i-1)*6
         local my = 32+(j-1-marbles.top)*6

         local falloffy = 0

         if j-1-marbles.top == 0 then

            if game.lose and 
            seq_contains(game.lose.mi, i) then
               rectfill(mx, my+1, mx + 5,
                        my + 5, 2)
            end
         end

         if j-1-marbles.top < 0 then
            if game.fall and
               seq_contains(game.fall.mi, i) then
                  falloffy = 5 * game.fall.t
                  rectfill(mx, my+1 + falloffy, mx+5,
                           my + 5 + falloffy, 2)
            end
         end
         print(""..marble, mx + 1, my + 1 + falloffy, 1)
      end
   end

   for add_top in all(game.add_top) do
      local i = add_top.i
      local marbles=game.marbles[i]
      local mx = x+1+(i-1)*6
      local my = 32+(0-1-marbles.top)*6

      local flash = add_top.delay % 3 == 0
      
      if flash then
         print(""..add_top.marble, mx + 1, my + 1, 3)
      end
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
   i=3
}

function init_game_data(height)
   local data = {}
   merge(data, game_template)

   data.marbles = {}
   data.add_top = {}

   for i=1,5 do
      local stack = {}

      for i=1,height do
         add(stack, make_marble())
      end

      data.marbles[i] = {
         top=flr(height/2),
         bottom=flr(height/2)-height + 1,
         stack=stack
      }
   end
   

   return data
end

match_indexes = {
   { 1, 2, 3, 4, 5 },
   { 1, 2, 3, 4 },
   { 2, 3, 4, 5 },
   { 1, 2, 3 },
   { 2, 3, 4 },
   { 3, 4, 5 }
}

function update_game(game)

   if game.in_transition then
      update_game_transition(game)
   else
      update_game_free(game)
   end

   game.in_transition = game_in_transition(game)
end

function update_game_transition(game)

   if game.lose then
      game.lose.delay -= 1
      if game.lose.delay < 5 and 
      game.fall == nil then
         begin_fall_lost_marbles(game)
      end
      if game.lose.delay < 0 then
         game.lose = nil
      end
   end

   if game.fall then
      game.fall.delay -= 1
      game.fall.t = 1.0-game.fall.delay/10
      if game.fall.delay < 0 then
         lose_and_fall_marbles(game)
         game.fall = nil
      end
   end

   for add_top in all(game.add_top) do
      add_top.delay -= 1
      if add_top.delay < 0 then
         add_top_marbles(game, add_top)
         del(game.add_top, add_top)
      end
   end

end

function update_game_free(game)
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
         begin_lose_marbles(game, mi)
         break
      end
   end
end

function add_top_marbles(game, add_top)
   game.marbles[add_top.i].top += 1
   add(game.marbles[add_top.i].stack, add_top.marble, 1)
end

function lose_and_fall_marbles(game)
   for i in all(game.fall.mi) do
      local marbles = game.marbles[i]
      deli(marbles.stack, marbles.top + 1)
      marbles.top -= 1

      local height = marbles.top - marbles.bottom

      if height < 3 then
         begin_add_top_marbles(game, i)
      end
   end
end

function begin_add_top_marbles(game, i)
   add(game.add_top, {
          i=i,
          delay=10,
          marble=make_marble()
   })
end

function begin_fall_lost_marbles(game)
   game.fall = {
      delay = 10,
      t = 0,
      mi=game.lose.mi
   }
end

function begin_lose_marbles(game, mi)
   game.lose = {
      delay=10,
      mi=mi
   }
end

function game_in_transition(game)
   return game.lose != nil or game.fall != nil or #game.add_top != 0
end

function center_marble(game, i)
   local marble = game.marbles[i]

   return marble.stack[marble.top + 1]
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

function game_up(game)
   local marble = game.marbles[game.i + 1]

   if marble.bottom < 0 then
      marble.top += 1
      marble.bottom += 1
   end
end

function game_down(game)
   local marble = game.marbles[game.i + 1]

   if marble.top > 0 then
      marble.top -= 1
      marble.bottom -= 1
   end
end

function game_shift(game)
   for i=4,1,-1 do
      local pre=game.marbles[i+1]
      local cur=game.marbles[i]

      local prebas = pre.top+1
      local curbas = cur.top+1

      local t = pre.stack[prebas]
      pre.stack[prebas]=cur.stack[curbas]
      cur.stack[curbas]=t
   end
end

-->8

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
