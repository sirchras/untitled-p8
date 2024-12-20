pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include vector.p8
--todo:
--obstacle avoidance?
--possibe performance optimisation: use coroutines?
--spatial partitioning: boids loop over boids in neighbouring cells only

function _init()
	screen={
		left=0,
		right=128,
		top=0,
		bottom=128,
	}
	target=_target:new{
		enabled=false,
	}
	boids={}
	boid_count=5
	max_boid_count=15 --can handle more, but >15 can chug at times
	--15 boids + target can chug at times
	spawn_boids()
--	boids[1].debug=true
end

function _update()
	if btnp(❎) and boid_count<max_boid_count then
		boid_count+=1
	end
	if btnp(🅾️) then
		target.enabled=not target.enabled
		if target.enabled then
			local x,y=rnd(128),rnd(128)
			target.pos=vector(x,y)
		end
	end
	if #boids<boid_count then
		spawn_boids()
	end
	if (target) target:update()
	for boid in all(boids) do
		boid:update()
	end
end

function _draw()
	cls()
	--debug:screen margins
--	local x1=screen.left+_boid.edgemargin
--	local x2=screen.right-_boid.edgemargin
--	local y1=screen.top+_boid.edgemargin
--	local y2=screen.bottom-_boid.edgemargin
--	rect(x1,y1,x2,y2,8)
--	rect(0,0,127,127,8)
	--
	print(boid_count,1,1,11)
	print(target.enabled,1,7,11)
	if (target) target:draw()
	for boid in all(boids) do
		boid:draw()
	end
end


--helper functions
function spawn_boids()
	local desired=boid_count-#boids
	for i=1,desired do
		local x,y=rnd(128),rnd(128)
		local spd=1+rnd(.5)
		add(boids,_boid:new{
			pos=vector(x,y),
			v=rndvector()*spd,
			c=rnd{1,2,9,10,12,13,14},
		})
	end
end

function move(self,d)
	self.pos+=d
end

function screen_wrap(self)
	self.pos=self.pos%128
end

function screen_clamp(self)
	self.pos.x=mid(self.r,self.pos.x,128-self.r)
	self.pos.y=mid(self.r,self.pos.y,128-self.r)
end

--
--classes--
--
class={}
function class:new(o)
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

--
--target
--
_target=class:new{
	pos=vector(64,64),
	speed=2,
	r=4,
}
function _target:update()
	--⬆️⬅️⬇️➡️ movement
	if (not self.enabled) return
	local d=vector()
	if (btn(⬅️)) d.x-=1
	if (btn(➡️)) d.x+=1
	if (btn(⬆️)) d.y-=1
	if (btn(⬇️)) d.y+=1
	d=d:norm()*self.speed
	move(self,d)
--	screen_wrap(self)
	screen_clamp(self)
end
function _target:draw()
	if (not self.enabled) return
	local x,y=self.pos.x,self.pos.y
	circfill(x,y,self.r,8)
	circ(x,y,self.r,7)
end

--
--boid
--
_boid=class:new{
	r=3, --radius
	max_force=0.03,
	max_speed=1.5,
	min_speed=0.5,
	view_angle=0.7,
	viewdist=30,
	sepdist=15, --desired separation
	sepweight=1.5,
	alignweight=1,
	cohweight=1,
	tgweight=2,
	stayonscreen=true,
	turnfactor=0.2,
	edgemargin=12,
	debug=false,
}
--update
function _boid:update()
	local max_speed,min_speed=self.max_speed,self.min_speed
	local acc,v=vector(),self.v
	local nearby,neighbors={},{}
	for boid in all(boids) do
		local diff=boid.pos-self.pos
		local dist=diff:mag()
		local ang=v:angle(diff)
		if (boid==self) goto continue
		if dist < self.sepdist then
			add(nearby,boid)
		end
		if dist < self.viewdist and ang<=(self.view_angle/2) then
			add(neighbors,boid)
		end
		::continue::
	end
	if (self.debug) self.neighbors=neighbors
	--separation
	local sep=self:separate(nearby)
	acc+=(sep*self.sepweight)
	--alignment
	local align=self:align(neighbors)
	acc+=(align*self.alignweight)
	--cohesion
	local coh=self:cohesion(neighbors)
	acc+=(coh*self.cohweight)
	--target
	if target and target.enabled then
		local tg=self:target()
		acc+=(tg*self.tgweight)
	end
	--update velocity
	v+=acc
	--avoid edges
	if self.stayonscreen then
		v+=self:avoid_edges()
	end
	v=v:limit(max_speed)
	if #v<min_speed then
		v=v:norm()*min_speed
	end
	move(self,v)
	self.v=v
	screen_wrap(self)
end
--separation
function _boid:separate(boids)
	local max_speed,max_force=self.max_speed,self.max_force
	local steer=vector()
	for boid in all(boids) do
		local diff=self.pos-boid.pos
		diff=diff:norm()/#diff
		steer+=diff
	end
	if (#boids>0) steer/=#boids
	if (#steer>0) then
		steer=steer:norm()*max_speed
		steer-=self.v
	end
	return steer:limit(max_force)
end
--alignment
function _boid:align(boids)
	local max_speed,max_force=self.max_speed,self.max_force
	local steer,sum=vector(),vector()
	for boid in all(boids) do
		sum+=boid.v
	end
	if (#boids>0) then
		sum/=#boids
		sum=sum:norm()*max_speed
		steer=sum-self.v
	end
	return steer:limit(max_force)
end
--cohesion
function _boid:cohesion(boids)
	local max_speed,max_force=self.max_speed,self.max_force
	local steer,sum=vector(),vector()
	for boid in all(boids) do
		sum+=boid.pos
	end
	if (#boids>0) then
		--find average/center pos
		-- sum/=#boids
		steer=(sum/#boids)-self.pos
		steer=steer:norm()*max_speed
		steer-=self.v
	end
	return steer:limit(max_force)
end
--target
function _boid:target()
	local max_speed,max_force=self.max_speed,self.max_force
	local steer=target.pos-self.pos
	steer=steer:norm()*max_speed
	steer-=self.v
	return steer:limit(max_force)
end
--todo: obstacles?
--avoid going off edge of screen
-- best effort, not 100% successful
function _boid:avoid_edges()
	local pos,tf=self.pos,self.turnfactor
	local margin=self.edgemargin
	local x,y=vector(1,0),vector(0,1)
	if (pos.x<screen.left+margin) return x*tf
	if (pos.x>screen.right-margin) return -x*tf
	if (pos.y<screen.top+margin) return y*tf
	if (pos.y>screen.bottom-margin) return -y*tf
	return vector()
end
--draw
function _boid:draw()
	local x,y=self.pos.x,self.pos.y
	local ray_len=self.debug and self.viewdist or self.r*1.5
	local col=self.debug and 8 or self.c
	local v=self.debug and self.v:norm() or self.v
	circ(x,y,self.r,col)
	line(x,y,x+v.x*ray_len,y+v.y*ray_len,11)
	if self.debug then
		local heading=self.v:heading()
		local angle=self.view_angle/2
		local ray_1=fromangle((heading-angle)%1)*ray_len
		local ray_2=fromangle((heading+angle)%1)*ray_len
		circ(x,y,ray_len,3)
		circ(x,y,self.sepdist,8)
		line(x,y,x+ray_1.x,y+ray_1.y,3)
		line(x,y,x+ray_2.x,y+ray_2.y,3)
		for b in all(self.neighbors) do
			line(x,y,b.pos.x,b.pos.y,6)
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
