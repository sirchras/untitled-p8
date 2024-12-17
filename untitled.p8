pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
#include vector.p8
#include polygon.p8:1
--todo:
--rewrite using vectors

--globals
_zero=vector()
screen={⬆️=0,⬅️=0,⬇️=128,➡️=128}

function _init()
	--debug vars
--	frame=0
	debug_angle=nil
	x="hello world"
	--strings are 1 token!?!
	p=player:new{pos=vector(64,64)}
	bullets={}
	enemies={}
	desired_enemy_count=1
--	enemies[1]=trigon:new{
--		x=10,y=64,
--		--facing player
--		--slightly askew as player is
--		-- a sprite
--		angle=atan2(p.x-10,-(p.y-64))
--	}
--	spawn_enemy(trigon)
end

function _update()
	--debuging
--	frame+=1
	--
	--move/update player
	p:update()
	--spawn enemies
	local n=desired_enemy_count-#enemies
	for i=n,1,-1 do
		spawn_enemy(trigon)
	end
	--move/update enemies
	for e in all(enemies) do
		e:update()
	end
	--move/update bullets
	for bullet in all(bullets) do
		bullet:update()
	end
end

function _draw()
	cls()
	print("p:"..p.pos.x.." "..p.pos.y,8)
	print("e:"..#enemies)
	print("b:"..#bullets)
	circ(64,64,50,8)--spawn outside
	p:draw()
	for e in all(enemies) do
		e:draw()
	end
	for bullet in all(bullets) do
		bullet:draw()
	end
--	print(frame,1,120,8)
end

--helper functions
function screen_clamp(self)
	local pos,r=self.pos,self.r or 0
	self.pos.x=mid(screen.⬅️+r,pos.x,screen.➡️-r)
	self.pos.y=mid(screen.⬆️+r,pos.y,screen.⬇️-r)
end

function on_screen(self)
	local pos,r=self.pos,self.r or 0
	return screen.⬅️+r<=pos.x and pos.x<screen.➡️-r
	 and screen.⬆️+r<=pos.y and pos.y<screen.⬇️-r
end

--todo: rewrite w/ vectors
function circ_circ_coll(self,other)
	local dx=self.x-other.x
	local dy=self.y-other.y
	local dist=(dx^2)+(dy^2)
	local radii=(self.r^2)+
		(other.r^2)
	return dist<=radii
end

--function get_controller_input(c)
function get_directional_input(c)
	--better name tbh, other input not used
	local dv=vector()
	if (btn(➡️,c)) dv.x+=1
	if (btn(⬅️,c)) dv.x-=1
	if (btn(⬇️,c)) dv.y+=1
	if (btn(⬆️,c)) dv.y-=1
	return dv:norm() --return normalised vector for convenience
end

function spawn_enemy(typ)
	spawn_fn=true
	local typ=typ
	local center=vector(64,64)
	local a=vector.heading(center-p.pos)
	if (a==_zero) a=rnd()
	local h=rnd()
	local a_off=rnd(h)-(h/2)
	local a_off=0
	local pos=center+fromangle(a+a_off)*60
	local v=vector.norm(p.pos-pos)*typ.speed
	local poly=polygon(typ.n,pos,typ.r,v:heading())
	local e=typ:new{
		pos=pos,
		v=v,
		poly=poly,
		target=p,
	}
	return add(enemies,e)
end

--classes
class={}
function class:new(o)
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

--
--base game object class
--
gmobj=class:new{
	pos=vector(0,0)
}
--draw fn
function gmobj:draw()
	local pos=self.pos
	spr(0,pos.x,pos.y)
end
--update fn
function gmobj:update()
	--placeholder
end
function gmobj:move(v)
	self.pos+=v
end

--
--player class
--
player=gmobj:new{
	r=4,
	speed=1.25,
	fire_cooldown=0,
}
function player:draw()
	local pos=self.pos
	circ(pos.x,pos.y,self.r,8)
end
--update fn
function player:update()
	--movement
	local v=get_directional_input(1)*self.speed
	self:move(v)
	--shooting
	self.fire_cooldown-=1
	local fv=get_directional_input(0)
	if fv!=_zero and self.fire_cooldown<=0 then
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

--
--bullet class
--
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
	self:move(self.v)
	if not on_screen(self) then
		del(bullets,self)
		return
	end
	--todo: rewrite collisions
	--check collisions
--	self:check_enemy_colls()
end
--function bullet:check_enemy_colls()
--	for e in all(enemies) do
--		local hit=circ_circ_coll(self,
--			e)
--		if hit then
--			--todo: score,dmg,effects
--			del(enemies,e)
--			del(bullets,self)
--			return
--		end
--	end
--end

--
--enemy base class
--
enemy=gmobj:new()
function enemy:draw()
	self.poly:draw()
	local pos=self.pos
	local v=self.v
	line(pos.x,pos.y,pos.x+(10*v.x),pos.y+(10*v.y),11)
end
function enemy:update()
	-- local v=self.v*self.speed
	-- gmobj.move(self,v)
	local v=self.v
	self:move(v)
	--update poly -kinda annoying
	self.poly.position=self.pos
	self.poly.angle=v:heading() --update polygon facing
	if not on_screen(self) then
		del(enemies,self)
	end
end

--
--tri-gon
--
trigon=enemy:new{
	n=3,
	r=4,
	c=11,
	speed=1,
	max_speed=1.5,
	min_speed=1,
	max_force=0.3,
--	target=p,
	tgweight=1,
}
function trigon:update()
	--todo: add boid code
	local v=self.v
	local acc=vector()
	--homing
	local tpos=self.target.pos
	local diff=vector.angle(tpos-self.pos,self.v)
	if abs(diff)<0.25 then
		acc+=(self:homing()*self.tgweight)
	end
	v+=acc
	v=v:limit(self.max_speed)
	if #v<self.min_speed then
		v=v:norm()*self.min_speed
	end
	self.v=v
	enemy.update(self) --call parent class update
end
function trigon:homing()
	local max_speed,max_force=self.max_speed,self.max_force
	local steer=target.pos-self.pos
	-- local diff=vector.angle(target,self.v)
	-- if (abs(diff)>0.25)
	local steer=(steer:norm()*max_speed)-self.v
	return steer:limit(max_force)
end
__gfx__
00000000008888000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000808888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700800000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000800000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000800000080888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700800000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
