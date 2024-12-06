pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--imports
#include vector.p8

-->8
--polygon class
polygon = {}
polygon.__index = polygon

function newpolygon(n, position, radius, angle)
	assert(n >= 3)
	local o = {
		n = n or 3,
		position = position or vector(),
		radius = radius or 10,
		angle = angle or 0.75,
	}
	return setmetatable(o, polygon)
end
setmetatable(polygon, {
	__call = function(_, ...) return newpolygon(...) end
})

--draw polygon
function polygon.draw(self, color)
	local color = color or 11
	local verticies = self:getverticies()
	for i = 1, #verticies do
		local a = verticies[i]
		local b = verticies[(i % #verticies) + 1]
		line(a.x, a.y, b.x, b.y, color)
	end
end

--calculate polygon verticies
function polygon.getverticies(self)
	local verticies = {}
	local angle = self.angle
	for i = 1, self.n do
		local vertex = self.position + (fromangle(angle) * self.radius)
		verticies[i] = vertex
		angle = (angle + (1 / self.n)) % 1
	end
	return verticies
end

function polygon.__tostring(self)
	return ""..self.n.."-gon, r:"..self.radius.." a:"..self.angle.." @"..self.position:__tostring()
end

-->8
--main
function _init()
	--only p1 can be manipulated
	p1 = polygon(3, vector(64, 64), 30)
	p2 = polygon(5, vector(90, 90), 10, 0.5)
	p3 = polygon(6, vector(40, 90), 30, 0.25)
	p4 = polygon(4, vector(20, 20), 10, 0.125)
	p5 = polygon(4, vector(60, 20), 12)
end

function _update()
	--increase size by 1 px
	if (btn(⬆️)) p1.radius += 1
	if (btn(⬇️)) p1.radius -= 1
	--rotate by 1/100 of a turn
	if (btn(⬅️)) p1.angle -= 0.01
	if (btn(➡️)) p1.angle += 0.01
	p1.angle = p1.angle % 1
	--change # of sides/verts by 1
	if (btnp(🅾️) and p1.n>3) p1.n -= 1
	if (btnp(❎)) p1.n += 1
end

function _draw()
	cls()
	-- print(p1.radius.." "..p1.angle, 8)
	print(p1, 8)
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
