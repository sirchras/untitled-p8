pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include vector.p8

function _init()
	--
	boids={}
	boid_count=5
	max_boid_count=20 --starts to chug at ~22
	spawn_boids()
end

function _update()
	if btnp(❎) and boid_count<max_boid_count then
		boid_count+=1
	end
	if #boids<boid_count then
		spawn_boids()
	end
	for boid in all(boids) do
		boid:update()
	end
end

function _draw()
	cls()
	print(boid_count,0,0,11)
	for boid in all(boids) do
		boid:draw()
	end
end


--helper functions
function spawn_boids()
	local desired=boid_count-#boids
	for i=1,desired do
		local x,y=rnd(128),rnd(128)
		local spd=1+flr(rnd(1))
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
_target=class:new{}

--
--boid
--
_boid=class:new{
	r=3, --radius
	max_force=0.02,
	max_speed=1.5,
	min_speed=0.5,
	sepdist=15, --desired separation
	neighbordist=25,
	sepweight=1.5,
	alignweight=1,
	cohweight=1,
}
--update
function _boid:update()
	local max_speed,min_speed=self.max_speed,self.min_speed
	local acc,v=vector(),self.v
	local nearby,neighbors={},{}
	for boid in all(boids) do
		local dist=self.pos:dist(boid.pos)
		if (dist==0) goto continue
		if dist < self.sepdist then
			add(nearby,boid)
		end
		if dist < self.neighbordist then
			add(neighbors,boid)
		end
		::continue::
	end
	--separation
	local sep=self:separate(nearby)
	acc+=(sep*self.sepweight)
	--alignment
	local align=self:align(neighbors)
	acc+=(align*self.alignweight)
	--cohesion
	local coh=self:cohesion(neighbors)
	acc+=(coh*self.cohweight)
	--update velocity
	v+=acc
	v:limit(max_speed)
	move(self,v)
	self.v=v
	screen_wrap(self)
end
--separation
function _boid:separate(boids)
	local max_speed,max_force=self.max_speed,self.max_force
	local steer=vector()
	for boid in all(boids) do
		local diff=self.pos - boid.pos
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
--draw
function _boid:draw()
	local x,y=self.pos.x,self.pos.y
	local r=self.r
	local dx,dy=self.v.x,self.v.y
	circ(x,y,r,self.c)
	line(x,y,x+dx*r*1.5,y+dy*r*1.5,11)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
