pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--
--vector class
--adapted from https://github.com/sirchras/vector-lua
--
vector = {}
vector.__index = vector

local function isvector(t)
  return getmetatable(t) == vector
end

function newvector(x, y)
  local o = {x = x or 0, y = y or 0}
  return setmetatable(o, vector)
end
-- idk why this is the only thing that works, and idc at this point
setmetatable(vector, {
  __call = function(_, ...) return newvector(...) end,
})

function fromangle(angle)
  local x = cos(angle)
  local y = -sin(angle)
  return newvector(x, y)
end

function rndvector()
  return fromangle(rnd())
end

function vector.__eq(a, b)
  assert(isvector(a) and isvector(b))
  return a.x == b.x and a.y == b.y
end

function vector.__unm(a)
  assert(isvector(a))
  return newvector(-a.x, -a.y)
end

function vector.__add(a, b)
  assert(isvector(a) and isvector(b))
  return newvector(a.x + b.x, a.y + b.y)
end

function vector.__sub(a, b)
  assert(isvector(a) and isvector(b))
  return newvector(a.x - b.x, a.y - b.y)
end

function vector.dot(a, b)
  assert(isvector(a) and isvector(b))
  return (a.x * b.x) + (a.y * b.y)
end

function vector.__mul(a, b)
  if type(a) == "number" then
    return newvector(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return newvector(a.x * b, a.y * b)
  else
    assert(isvector(a) and isvector(b))
    return a:dot(b)
  end
end

function vector.__div(a, b)
  assert(isvector(a) and type(b) == "number")
  assert(b != 0)
  return newvector(a.x / b, a.y / b)
end

function vector.__mod(a, b)
  assert(isvector(a) and type(b) == "number")
  assert(b != 0)
  return newvector(a.x % b, a.y % b)
end

function vector.magsq(a)
  assert(isvector(a))
  return a:dot(a)
end

function vector.mag(a)
  assert(isvector(a))
  return sqrt(a:magsq())
end
vector.__len = vector.mag

function vector.norm(a)
  assert(isvector(a))
  local mag = a:mag()
  if mag == 1 or mag == 0 then
    return newvector(a.x, a.y)
  else
    return a / mag
  end
end

function vector.heading(a)
  assert(isvector(a))
  --todo: check this works as intended
  return atan2(a.x, -a.y)
end

function vector.dist(a, b)
  assert(isvector(a) and isvector(b))
  local diff = a - b
  return diff:mag()
end

function vector.angle(a, b)
  assert(isvector(a) and isvector(b))
  --todo: check this works as intended
  local diff = a:heading() - b:heading()
  return abs(diff)
end

function vector.limit(a, b)
  assert(isvector(a) and type(b) == "number")
  local mag = a:mag()
  if mag <= b then return a end
  return a:norm() * b
end

function vector:__tostring()
  return "("..self.x..","..self.y..")"
end
