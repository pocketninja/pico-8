actors = {}

actor = {
    sprite = nil,
    sprite_sheet_scale = nil,

    -- position and size
    transform = nil,

    -- velocity
    velocity = nil,
    friction = nil,
    max_velocity = nil,

    -- gravity
    gravity = nil,

    __tostring = function(a)
        return "actor: " .. a.sprite .. ' == ' .. a.transform.position.x .. ", " .. a.transform.position.y .. ", " .. a.transform.w .. ", " .. a.transform.h
    end,
}

function actor:new(o)
    o = o or {}
    o.sprite = o.sprite or 0
    o.sprite_sheet_scale = o.sprite_sheet_scale or vec:new({ x = 1, y = 1 })
    o.transform = o.transform or drect:new()
    o.velocity = o.velocity or vec:new()
    o.friction = o.friction or vec:new({ x = 1, y = 1 })
    o.max_velocity = o.max_velocity or vec:new({ x = 10, y = 10 })
    o.gravity = o.gravity or vec:new({ y = 0.1 })
    setmetatable(o, self)
    self.__index = self;

    -- @todo check for max actors list?
    add(actors, o)

    return o
end

function actor:draw(wrap)
    wrap = wrap or false

    -- determine the sprite's x and y in the spritesheet for the sprite number
    local sprite_x = 8 * (self.sprite % 16)
    local sprite_y = 8 * (flr(self.sprite / 16))
    local sprite_width = 8 * self.sprite_sheet_scale.x
    local sprite_height = 8 * self.sprite_sheet_scale.y

    local top_left = self.transform:top_left()
    local bottom_right = self.transform:bottom_right()
    sspr(
            sprite_x,
            sprite_y,
            sprite_width,
            sprite_height,
            top_left.x,
            top_left.y,
            self.transform.w,
            self.transform.h
            -- @todo flipping based on direction?
    )

    -- if wrapping, and the sprite is within range of the edge, draw
    -- off the other side to account
    if wrap then
        -- if we're heading out the top right, draw the sprite on the
        -- bottom left
        --if top_left.y < 0 and top_left.x > 128 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x - 128,
        --            top_left.y + 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.y < 0 and top_left.x < 0 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x + 128,
        --            top_left.y + 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.y > 128 and top_left.x > 128 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x - 128,
        --            top_left.y - 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.y > 128 and top_left.x < 0 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x + 128,
        --            top_left.y - 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.y < 0 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x,
        --            top_left.y + 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.y > 128 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x,
        --            top_left.y - 128,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.x < 0 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x + 128,
        --            top_left.y,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --elseif top_left.x > 128 then
        --    sspr(
        --            sprite_x,
        --            sprite_y,
        --            sprite_width,
        --            sprite_height,
        --            top_left.x - 128,
        --            top_left.y,
        --            self.transform.w,
        --            self.transform.h
        --    )
        --end


        --when within the full length of the sprite from the edge, draw
        -- appropriately from the other side
        if top_left.x < 0 then
            sspr(
                    sprite_x,
                    sprite_y,
                    sprite_width,
                    sprite_height,
                    top_left.x + 128,
                    top_left.y,
                    self.transform.w,
                    self.transform.h
            )
        elseif bottom_right.x > 128 then
            sspr(
                    sprite_x,
                    sprite_y,
                    sprite_width,
                    sprite_height,
                    top_left.x - 128,
                    top_left.y,
                    self.transform.w,
                    self.transform.h
            )
        end

        if top_left.y < 0 then
            sspr(
                    sprite_x,
                    sprite_y,
                    sprite_width,
                    sprite_height,
                    top_left.x,
                    top_left.y + 128,
                    self.transform.w,
                    self.transform.h
            )
        elseif bottom_right.y > 128 then
            sspr(
                    sprite_x,
                    sprite_y,
                    sprite_width,
                    sprite_height,
                    top_left.x,
                    top_left.y - 128,
                    self.transform.w,
                    self.transform.h
            )
        end
    end
end

function actor:update()
    -- apply gravity
    self.velocity = self.velocity + self.gravity

    -- apply friction
    self.velocity = self.velocity * self.friction

    -- clamp to max
    self.velocity = self.velocity:clamp(self.max_velocity * -1, self.max_velocity)

    -- apply velocity
    self.transform.position = self.transform.position + self.velocity
end

function delete_all_actors()
    actors = {}
end