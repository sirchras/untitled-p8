pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include vector.p8

--globals
_zero=vector()
screen={
  ⬆️=0,
  ⬅️=0,
  ⬇️=128,
  ➡️=128,
}
--init globals
p=player:new()
bullets={}

--helper functions
function on_screen(self)
  local pos=self.pos
  return screen.⬅️<=pos.x and pos.x<screen.➡️
   and screen.⬆️<=pos.y and pos.y<screen.⬇️
end

function screen_clamp(self)
  local pos,r=self.pos,self.r
  self.pos.x=mid(screen.⬅️+r,pos.x,screen.➡️-r)
  self.pos.y=mid(screen.⬆️+r,pos.y,screen.⬇️-r)
end

function screen_wrap(self)
  -- self.pos=self.pos%128 --naive way
  local pos=self.pos
  self.pos.x=pos.x%screen.➡️
  self.pos.y=pos.y%screen.⬇️
end

-- function get_controller_input(c)
function get_directional_input(c)
  --better name tbh, other input not used
  local dv=vector()
  if (btn(➡️,p)) dv.x+=1
  if (btn(⬅️,p)) dv.x-=1
  if (btn(⬇️,p)) dv.y+=1
  if (btn(⬆️,p)) dv.y-=1
  return dv:norm() --return normalised vector for convenience
end

--base class
class={}
function class:new(o)
  local o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

--gmobj
gmobj=class:new{
  pos=vector(0,0)
}
function gmobj:draw()
  local pos=self.pos
  spr(0,pos.x,pos.y)
end
function gmobj:update()
  --placeholder
end
function gmobj:move(dv)
  self.pos+=dv
end

--player
player=gmobj:new{
  r=4,
  speed=1.25,
  fire_cooldown=0,
}
function player:draw()
  local pos=self.pos
  circ(pos.x,pos.y,self.r,8)
end
function player:update()
  --movement
  local v=get_directional_input(1)*self.speed
  self:move(v)
  --shooting
  self.fire_cooldown-=1
  if self.fire_cooldown<=0 then
    local fv=get_directional_input(0)
    local pos,offset=self.pos,self.r
    add(bullets,bullet:new{
      pos=pos+(fv*offset),
      v=fv,
    })
    self.fire_cooldown=8
  end
end
function player:move(v)
  gmobj.move(self,v)
  screen_clamp(self)
end

--bullet
bullet=gmobj:new{
  r=2,
  v=vector(0,-1),
  speed=3,
}
function bullet:draw()
  local pos=self.pos
  circfill(pos.x,pos.y,self.r,8)
end
function bullet:update()
  local v=self.v*self.speed
  self:move(v)
  if not on_screen(self) then
    del(bullets,self)
    return
  end
  --check collisions
end

--polygon
poly=gmobj:new{
  --placeholder vals - get from enemy containing the poly
  angle=0.75,
  n=3,
  r=30,
  c=11,
}
function poly:draw()
  local verts=self:getvertices()
  for i=1,#verts do
    local a=verts[i]
    local b=verts[(i%#verts)+1]
    line(a.x,a.y,b.x,b.y,self.c)
  end
end
function poly:getvertices()
  local pos=self.pos
  local a,r=self.angle,self.r
  local verts={}
  for i=1,self.n do
    verts[i]=vector(pos.x+(cos(a)*r),pos.y+(-sin(a)*r))
    a=(a+(1/self.n))%1
  end
  return verts
end
