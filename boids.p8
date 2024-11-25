pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include vector.p8

function _init()
	--
	boids={}
	max_force=0.02
	max_speed=2
	desired_boid_count=5
	desired_separation=15
	neighbor_dist=25
	sepweight=1.5
	alignweight=1
	cohweight=1
	for i=1,desired_boid_count do
		local x,y = rnd(128),rnd(128)
		add(boids,_boid:new{
--			x=flr(rnd(128)),
--			y=flr(rnd(128)),
--			a=rnd(),
--			v=1+flr(rnd(4)),
			pos=vector(x,y),
			v=rndvector(),
			c=rnd{1,2,9,10,12,13,14},
		})
	end
	p1 = vector(0,20)
	p2 = vector(1,-1)
end

function _update()
	--
	for boid in all(boids) do
		boid:update()
	end
end

function _draw()
	--
	cls()
	print(p1)
	print(p1:heading())
	print(p2)
	print(p2:heading())
	print(p1:angle(p2))
	print(p1:limit(5))
	print(p1:norm()/#p1)
	for boid in all(boids) do
		boid:draw()
	end
end


--helper functions
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
--boid
--
_boid=class:new{
--	x=0, --x position
--	y=0, -- position
--	a=0, --angle/direction
--	v=0, --velocity
	sepdist=25, --desired separation
	neighbordist=50,
}
--update
function _boid:update()
	local acc,v=vector(),self.v
--	local a,v=self.a,self.v
--	local dx,dy=cos(a)*v,-sin(a)*v
	local nearby,neighbors={},{}
	for boid in all(boids) do
--		if boid==self goto continue
		local dist=self.pos:dist(boid.pos)
		if (dist==0) goto continue
		if dist < desired_separation then
			add(nearby,boid)
		end
		if dist < neighbor_dist then
			add(neighbors,boid)
		end
		::continue::
	end
	--separation
	local sep=self:separate(nearby)
	acc+=(sep * sepweight)
	--alignment
	local align=self:align(neighbors)
	acc+=(align * alignweight)
	--cohesion
	local coh=self:cohesion(neighbors)
	acc+=(coh * cohweight)
	--update velocity
	v+=acc
	v:limit(max_speed)
	move(self,v)
	self.v=v
	screen_wrap(self)
end
--separation
function _boid:separate(boids)
	local steer=vector()
	for boid in all(boids) do
		local diff=self.pos - boid.pos
		diff=diff:norm()/#diff
		steer+=diff
	end
	if (#boids>0) steer/=#boids
	--not sure why so much
	-- normalization is necessary
	if (#steer>0) then
		steer=steer:norm()*max_speed
		steer-=self.v
		steer=steer:limit(max_force)
	end
	return steer
end
--alignment
function _boid:align(boids)
	local steer,sum=vector(),vector()
	for boid in all(boids) do
		sum+=boid.v
	end
	if (#boids>0) then
		sum/=#boids
		sum=sum:norm()*max_speed
		steer=sum-self.v
		steer=steer:limit(max_force)
	end
	return steer
end
--cohesion
function _boid:cohesion(boids)
	local steer,sum=vector(),vector()
	for boid in all(boids) do
		sum+=boid.pos
	end
	if (#boids>0) then
		--find average/center pos
		sum/=#boids
		steer=sum-self.pos
		steer=steer:norm()*max_speed
		steer-=self.v
		steer=steer:limit(max_force)
	end
	return steer
end
--draw
function _boid:draw()
	local x,y=self.pos.x,self.pos.y
	local a,v=self.a,self.v
	local r=self.r
	local dx,dy=v.x,v.y
	circ(x,y,4,self.c)
	line(x,y,x+dx*4,y+dy*4,11)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
