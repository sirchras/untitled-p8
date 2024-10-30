pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
	--debug vars
	debug_angle=nil
	x="hello world"
	--strings are 1 token!?!
	p=player:new{x=60,y=60}
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
	print("p:"..p.x.." "..p.y)
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
end

--helper functions
function screen_clamp(self)
	self.x=mid(self.r,self.x,
		128-self.r)
	self.y=mid(self.r,self.y,
		128-self.r)
end

function on_screen(self)
	return self.x<128 and
	 self.x>-self.r and
	 self.y<128 and
	 self.y>-self.r
end

function circ_circ_coll(self,other)
	local dx=self.x-other.x
	local dy=self.y-other.y
	local dist=(dx^2)+(dy^2)
	local radii=(self.r^2)+
		(other.r^2)
	return dist<=radii
end

function get_controller_input(p)
	local dx,dy,a=0,0
	local ❎,🅾️=false,false
	if (btn(⬅️,p)) dx=-1
	if (btn(➡️,p)) dx=1
	if (btn(⬆️,p)) dy=1
	if (btn(⬇️,p)) dy=-1
	if (btn(❎,p)) ❎=true
	if (btn(🅾️,p)) 🅾️=true
	if dx!=0 or dy!=0 then
		a=atan2(dx,dy)
	end
	return {a,❎,🅾️}
end

function spawn_enemy(typ)
	local typ=typ or trigon
	local px,py=p.x,p.y
	local a=atan2(64-px,-(64-py))
	local h=rnd()
	local a_off=rnd(h)-(h/2)
	local x=64+(cos(a+a_off)*60)
	local y=64+(-sin(a+a_off)*60)
	local e=typ:new{
		x=x,y=y,
		angle=atan2(px-x,-(py-y))
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
	x=0,
	y=0,
--	sprite=0,
--	width=8,
--	height=8,
}
--update fn
function gmobj:update()
	--
end
--draw fn
function gmobj:draw()
--	local sp=self.sprite
	local x,y=self.x,self.y
--	spr(sp,x,y)
	spr(0,x,y)
end
function gmobj:move(dx,dy)
	self.x+=dx
	self.y+=dy
end

--
--player class
--
player=gmobj:new{
--	sprite=1,
	r=4,
	speed=1.25,
	fire_cooldown=0,
}
function player:draw()
	circ(self.x,self.y,self.r,8)
end
--update fn
function player:update()
	--movement
	local c1=get_controller_input(1)
	local m_a=unpack(c1)
	if not not m_a then
		local spd=p.speed
		--movement is not smooth at
		-- speed=1?
		local dx,dy=cos(m_a)*spd,
			-sin(m_a)*spd
		self:move(dx,dy)
	end
	--shooting
	self.fire_cooldown-=1
	local c0=get_controller_input(0)
	local s_a=unpack(c0)
	if not not s_a and
	 self.fire_cooldown<=0 then
		local offset=self.r
		local b=bullet:new{
			x=self.x+(cos(s_a)*offset),
			y=self.y+(-sin(s_a)*offset),
			angle=s_a
		}
		add(bullets,b)
		self.fire_cooldown=8
	end
end
function player:move(dx,dy)
	gmobj.move(self,dx,dy)
	screen_clamp(self)
end

--
--bullet class
--
bullet=gmobj:new{
--	sprite=2,
--	width=5,
--	height=5,
	r=2,
	speed=3,
	angle=0.75,
}
function bullet:draw()
	circfill(self.x,self.y,self.r,8)
end
function bullet:update()
	local a,spd=self.angle,
		self.speed
	local dx,dy=cos(a)*spd,
		-sin(a)*spd
	self:move(dx,dy)
	if not on_screen(self) then
		del(bullets,self)
		return
	end
	--check collisions
	self:check_enemy_colls()
end
function bullet:check_enemy_colls()
	for e in all(enemies) do
		local hit=circ_circ_coll(self,
			e)
		if hit then
			--todo: score,dmg,effects
			del(enemies,e)
			del(bullets,this)
			return
		end
	end
end

--
--polygon
--
poly=gmobj:new{
	angle=0.75,
}
--draw polygon
function poly:draw()
	local verts=self:getverts()
	for i=1,#verts do
		local a=verts[i]
		local b=verts[(i%#verts)+1]
		line(a.x,a.y,b.x,b.y,11)
	end
end
--calculate polygon verticies
function poly:getverts()
	local a,r=self.angle,self.r
	local verts={}
	for i=1,self.n do
		verts[i]={
			x=self.x+r*cos(a),
			y=self.y+r*-sin(a)
		}
		a=(a+(1/self.n))%1
	end
	return verts
end

--
--enemy base class
--
enemy=poly:new()
function enemy:update()
	local a,spd=self.angle,
		self.speed
	local dx,dy=cos(a)*spd,
		-sin(a)*spd
	self:move(dx,dy)
	--todo: add collisions
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
	speed=1
}
function trigon:draw()
	local spd=self.speed
	local a=self.angle
	local dx=cos(a)*spd*10
	local dy=-sin(a)*spd*10
	print(a,self.x,self.y-8,8)
	line(self.x,self.y,self.x+dx,self.y+dy,13)
	enemy.draw(self)
end
function trigon:update()
	--homing
	local x,y=self.x,self.y
	local a=self.angle
	local target_a=atan2(p.x-x,
	 y-p.y)
	local diff=target_a-a
	--stop homing if angle diff
	-- too large
	if abs(diff)<0.25 then
		a+=sgn(diff)*0.005
	end
	self.angle=a
	--call parent update
	enemy.update(self)
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
