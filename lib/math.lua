vec = {
    x = 0, y = 0,

    __add = function(a, b)
        return vec:new({ x = a.x + b.x, y = a.y + b.y })
    end,

    __sub = function(a, b)
        return vec:new({ x = a.x - b.x, y = a.y - b.y })
    end,

    __mul = function(a, b)
        return vec:new({ x = a.x * b, y = a.y * b })
    end,

    __div = function(a, b)
        return vec:new({ x = a.x / b, y = a.y / b })
    end,

    __unm = function(a)
        return vec:new({ x = -a.x, y = -a.y })
    end,

    __eq = function(a, b)
        return a.x == b.x and a.y == b.y
    end,

    __tostring = function(a)
        return "vec: " .. a.x .. ", " .. a.y
    end,
}

-- make a 2d vector
function vec:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self;
    return o
end

function vec:dot(b)
    return self.x * b.x + self.y * b.y
end

function vec:cross(b)
    return self.x * b.y - self.y * b.x
end

function vec:length()
    return sqrt(self.x * self.x + self.y * self.y)
end

function vec:normalize()
    local len = self:length()
    return vec:new({ x = self.x / len, y = self.y / len })
end

function vec:rotate(angle)
    local c = cos(angle)
    local s = sin(angle)
    return vec:new({ x = self.x * c - self.y * s, y = self.x * s + self.y * c })
end

function vec:angle()
    return atan2(self.y, self.x)
end

function vec:clamp(min, max)
    return vec:new({
        x = mid(min.x, self.x, max.x),
        y = mid(min.y, self.y, max.y)
    })
end

function vec:map_cell()
    return vec:new({
        x = flr(self.x / 8),
        y = flr(self.y / 8)
    })
end

function vec:clone()
    return vec:new({ x = self.x, y = self.y })
end

rect = {
    position,
    w,
    h,

    __tostring = function(a)
        return "rect: " .. a.position.x .. ", " .. a.position.y .. ", " .. a.w .. ", " .. a.h
    end,
}

function rect:new(o)
    o = o or {}
    o.position = o.position or vec:new()
    o.w = o.w or 0
    o.h = o.h or 0
    r = setmetatable(o, self)
    self.__index = self;
    return r
end

function rect:left()
    return self.position.x - self.w / 2
end

function rect:right()
    return self.position.x + self.w / 2
end

function rect:top()
    return self.position.y - self.h / 2
end

function rect:bottom()
    return self.position.y + self.h / 2
end

function rect:top_left()
    return vec:new({ x = self:left(), y = self:top() })
end

function rect:top_right()
    return vec:new({ x = self:right(), y = self:top() })
end

function rect:bottom_left()
    return vec:new({ x = self:left(), y = self:bottom() })
end

function rect:bottom_right()
    return vec:new({ x = self:right(), y = self:bottom() })
end

function rect:contains(v)
    return self:left() <= v.x and
            v.x <= self:right() and
            self:top() <= v.y and
            v.y <= self:bottom()
end

function rect:intersects(r)
    return self:left() < r:right() and
            r:left() < self:right() and
            self:top() < r:bottom() and
            r:top() < self:bottom()
end

function rect:clamp(v)
    return vec:new({
        x = mid(self:left(), v.x, self:right()),
        y = mid(self:top(), v.y, self:bottom())
    })
end

function rect:clamp_rect(r)
    return rect:new {
        position = self:clamp(r.position),
        w = r.w,
        h = r.h
    }
end

function rect:move(v)
    return rect:new {
        position = self.position + v,
        w = self.w,
        h = self.h
    }
end

function rect:clone()
    return rect:new {
        position = self.position:clone(),
        w = self.w,
        h = self.h
    }
end