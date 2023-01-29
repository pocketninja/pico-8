speed = {
    high = 3,
    low = 1,
}

player = {
    --position = vec(10, 10),
    rect = rect:new({
        position = vec:new({ x = 15, y = 15 }),
        -- 1px smaller than actual sprite to allow for 1px gaps
        w = 7, h = 7
    }),
    speed = speed.low,
    speed_scale = 1,
    sprite = 1,
}

function _init()
    print("Hello! This is KB Move...")
end

function _update()
    cls()
    handle_input()
    update_camera()

    draw_player()
    draw_map()
end

function update_camera()
    camera(
            player.rect.position.x - 64,
            player.rect.position.y - 64
    )
end

function draw_player()
    local coord = player.rect:top_left()
    spr(player.sprite, coord.x, coord.y)
end

function draw_map()
    map(0, 0, 0, 0, 128, 128)
end

function handle_input()

    shift = vec:new({ x = 0, y = 0 })

    if btn(⬅️)
    then
        shift.x = -player.speed
    end
    if btn(➡️)
    then
        shift.x = player.speed
    end
    if btn(⬆️)
    then
        shift.y = -player.speed
    end
    if btn(⬇️)
    then
        shift.y = player.speed
    end

    -- when X is pressed, set speed to 3
    if btn(❎)
    then
        player.speed = speed.high
    else
        player.speed = speed.low
    end

    new_y = 0;
    new_x = 0;

    -- speed is in pixels, so let's check each step of the player speed, it can be negative or positive
    -- this is prob very inefficient, but it works

    for i = 1, abs(shift.x) do
        -- flip the sign if the person is moving left
        if (shift.x < 0)
        then
            i = -i
        end

        -- if colliding, break;
        if rect_collides_with_map(player.rect:clone():move(vec:new({ x = i, y = 0 })), 1)
        then
            break
        end

        -- set the shift
        new_x = i;
    end

    player.rect.position = player.rect.position + vec:new({ x = new_x, y = 0 })

    for i = 1, abs(shift.y) do
        -- flip the sign if the person is moving up
        if (shift.y < 0)
        then
            i = -i
        end
        -- if colliding, break...
        if rect_collides_with_map(player.rect:clone():move(vec:new({ x = 0, y = i })), 1)
        then
            break
        end

        -- set the shift.
        new_y = i;
    end

    player.rect.position = player.rect.position + vec:new({ x = 0, y = new_y })
end