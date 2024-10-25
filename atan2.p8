pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	--
	x=64
	y=64
	fx,fy=0,0
	a=0.75
	bl={}
	fc=0
	fr=4
	p0⬅️=false
	p0➡️=false
	p0⬆️=false
	p0⬇️=false
end

function _update()
	--
	dx,dy=0,0
	if (btn(⬆️,1)) dy=-1
	if (btn(⬇️,1)) dy=1
	if (btn(⬅️,1)) dx=-1
	if (btn(➡️,1)) dx=1
	x+=dx
	y+=dy
--	if (btnp(⬆️,0)) fy=-1
--	if (btnp(⬇️,0)) fy=1
--	if (btnp(⬅️,0)) fx=-1
--	if (btnp(➡️,0)) fx=1
--	a=atan2(fx,-fy)
	
	p0in=btn()
	--problem: btn and btnp act weird together
	shoot_b(p0in,fr)
	fc-=1	
	for b in all(bl) do
		b:move()
	end
end

function _draw()
	--
	cls()
	print(a)
	print(tostr(btn(),true).." "..btn())
	print(p0in)
	print(tostr(p0in,true))
	print("⬅️"..tostr(p0⬅️))
	print("➡️"..tostr(p0➡️))
	print("⬆️"..tostr(p0⬆️))
	print("⬇️"..tostr(p0⬇️))
	circ(x,y,4,8)
	line(x,y,x+cos(a)*5,y-sin(a)*5)
	for b in all(bl) do
		--
		circ(b.x,b.y,2,8)
--		print(b)
	end
end

function shoot_b(btnin,fr)
	if (fc>0) return
	--problem: btn is > 0 for movement keys
--	if (btnin==0 or btnin>128) return
	fc=fr
	local p0in=btnin
	p0⬅️=p0in & 1 != 0
	p0➡️=p0in & 2 != 0
	p0⬆️=p0in & 4 != 0
	p0⬇️=p0in & 8 != 0
	if not (p0⬅️ or p0➡️ or p0⬆️ or p0⬇️) then
		return
	end
	if p0⬅️ or p0➡️ then
		fx=p0➡️ and 1 or -1
	else
		fx=0
	end
	if p0⬆️ or p0⬇️ then
		fy=p0⬇️ and -1 or 1
	else
		fy=0
	end
	a=atan2(fx,fy)
	local b=bc:new{
		x=x,
		y=y,
		dx=cos(a)*2,
		dy=-sin(a)*2
	}
	return add(bl,b)
end

bc={
	x=0,
	y=0
}
function bc:new(o)
	o=o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
function bc:move()
	if (not self.dx and not self.dy) return
	local dx,dy=self.dx,self.dy
	self.x+=dx
	self.y+=dy
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
