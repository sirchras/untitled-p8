pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include vector.p8
#include polygon.p8:1
-- ^appears to be an issue in the P8-LS, should be able to
-- include a single tab

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
enemies={}

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

function spawn_enemy(typ)
  local typ=typ
  local a=vector.heading(vector(64,64)-p.pos)
  local h=rnd()
  local a_off=rnd(h)-(h/2)
  local pos=vector.fromangle(a+a_off)*60
  local v=vector.norm(pos-p.pos)*typ.speed
  local poly=polygon(typ.n,pos,typ.r,v:heading())
  local e=typ:new{
    pos=pos,
    v=v,
    poly=poly,
  }
  return add(enemies,e)
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
      v=fv*bullet.speed,
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
  v=vector(0,-3),
  speed=3, --should be redundant?
}
function bullet:draw()
  local pos=self.pos
  circfill(pos.x,pos.y,self.r,8)
end
function bullet:update()
  --shouldn't vector v include speed component
  -- local v=self.v*self.speed
  -- self:move(v)
  self:move(self.v)
  if not on_screen(self) then
    del(bullets,self)
    return
  end
  --check collisions
end

--enemy
enemy=gmobj:new()
function enemy:draw()
  self.poly:draw()
end
function enemy:update()
  -- local v=self.v*self.speed
  -- gmobj.move(self,v)
  local v=self.v
  self:move(v)
  self.poly.angle=v:heading() --update polygon facing
  if not on_screen(self) then
    del(enemies,self)
  end
end

--tri-gon
trigon=enemy:new{
  n=3,
  r=4,
  c=11,
  speed=1,
  max_speed=1.5,
  max_force=0.3,
  target=p,
  tgweight=1,
}
function trigon:update()
  --todo: add boid code
  local v=self.v
  local acc=vector()
  --homing
  local diff=vector.angle(self.target,self.v)
  if abs(diff)<0.25 then
    acc+=(self:homing()*self.tgweight)
  end
  v+=acc
  self.v=v:limit(self.max_speed)
  enemy.update(self) --call parent class update
end
function trigon:homing()
  local max_speed,max_force=self.max_speed,self.max_force
  local target=p.pos-self.pos
  -- local diff=vector.angle(target,self.v)
  -- if (abs(diff)>0.25)
  local steer=(target:norm()*max_speed)-self.v
  return steer:limit(max_force)
end
