pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--imports
#include vector.p8

-->8
--polygon class
--
gmobj={}
function gmobj:new(o)
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

--
--polygon
--
poly=gmobj:new()
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
	local a,r=self.a,self.r
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

--poly factory fn
-- n: # of verticies/sides
-- x: x position
-- y: y position
-- r: radius
-- a: angle, default up (0.75)
function newpoly(n,x,y,r,a)
	if (n<3) return
	local a=a or 0.75
	return poly:new{
		x=x,
		y=y,
		n=n,
		r=r,
		a=a
	}
end

-->8
--main
function _init()
	--only p1 can be manipulated
	p1=newpoly(3,64,64,30)
	p2=newpoly(5,90,90,10,0.5)
	p3=newpoly(6,40,90,30,0.25)
	p4=newpoly(4,20,20,10,0.125)
	p5=newpoly(4,60,20,12)
end

function _update()
	--increase size by 1 px
	if (btn(⬆️)) p1.r+=1
	if (btn(⬇️)) p1.r-=1
	--rotate by 1/100 of a turn
	if (btn(⬅️)) p1.a-=0.01
	if (btn(➡️)) p1.a+=0.01
	p1.a=p1.a%1
	--change # of sides/verts by 1
	if (btnp(🅾️) and p1.n>3) p1.n-=1
	if (btnp(❎)) p1.n+=1
end

function _draw()
	cls()
	print(p1.r.." "..p1.a,8)
	p1:draw()
	p2:draw()
	p3:draw()
	p4:draw()
	p5:draw()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
