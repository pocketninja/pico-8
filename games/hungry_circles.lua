player = nil
level = 1
initial_circle_count = 5
number_of_circles = initial_circle_count
circle_increase_count = 10

bounce_at_walls = true
draw_circles_instead_of_sprites = true

circles_move = true

function _init()
    cls()
    print("Hungry Circles!")

    init_circles()

    print("Number of actors: " .. #actors)
end

function _update()
    cls()
    handle_player_input()
    update_actors()
    --update_camera()
    draw_actors()
    draw_game_field()
    draw_messages();
end

function init_round()
    delete_all_actors()
    init_circles()
end

function init_circles()
    local gravity = vec:new()

    player = actor:new({
        sprite = 1,
        transform = drect:new({
            position = vec:new({ x = 64, y = 64 }),
            w = 8,
            h = 8,
        }),
        gravity = gravity,
        max_velocity = vec:new({ x = 2, y = 2 }),
        friction = vec:new({ x = 0.975, y = 0.975 }),
        speed = 0.1
    })

    -- create all the other circles with varying sizes.
    for i = 1, number_of_circles do
        if spawn_circle() == nil then
            i = i - 1
        end
    end
end

function spawn_circle()
    local gravity = vec:new()
    local position = vec:new({ x = rnd(128), y = rnd(128) })

    -- set a max size which has a base size of 10,  but scales with level
    local max_size = 10 + (level * 2)

    local size = rnd(max_size) + 2

    local circle = actor:new({
        sprite = 33,
        transform = drect:new({
            position = position,
            w = size,
            h = size,
        }),
        velocity = circles_move and vec:new({ x = rnd(0.5) - 0.25, y = rnd(0.5) - 0.25 }) or nil,
        friction = vec:new({ x = 1, y = 1 }),
        gravity = gravity,
        speed = 0.2
    })

    --if the circle overlaps with any other circle, del and keep looping
    local overlapped = get_overlapped_circle(circle)
    if overlapped then
        del(actors, circle)
        return nil
    end

    return circle
end

function update_camera()
    -- this doesn't work yet... and there is apparently no zoom!
    if (player == nil) then
        return
    end
    -- zoom the camera base on player size
    camera_scale = 1 + (player.transform.w / 50)

    -- center the camera on the player
    camera_position = player.transform.position

    -- set the camera zoom and position, accounting for zoom
    camera(camera_position.x, camera_position.y, camera_scale, camera_scale)

end

function draw_game_field()
    rect(0, 0, 127, 127, 7)
end

function draw_actors()
    for i, actor in pairs(actors) do
        if not draw_circles_instead_of_sprites then
            actor:draw(not bounce_at_walls)
        else
            local outline_color = actor == player and 3 or 7
            local fill_color = actor == player and 1 or 8

            circfill(actor.transform.position.x, actor.transform.position.y, actor.transform.w / 2, fill_color)
            circ(actor.transform.position.x, actor.transform.position.y, actor.transform.w / 2, outline_color)
        end
    end
end

function update_actors()
    -- move actors (incl player)
    for i, actor in pairs(actors) do
        actor:update()

        if not bounce_at_walls then
            if actor.transform.position.x < 0 then
                actor.transform.position.x = 128
            elseif actor.transform.position.x > 128 then
                actor.transform.position.x = 0

            end

            if actor.transform.position.y < 0 then
                actor.transform.position.y = 128
            elseif actor.transform.position.y > 128 then
                actor.transform.position.y = 0
            end
        else
            local top_left = actor.transform:top_left()
            local bottom_right = actor.transform:bottom_right()

            if top_left.x <= 0 then
                actor.velocity.x = actor.velocity.x * -1
                actor.transform.position.x = actor.transform.position.x + (0 - top_left.x)
            elseif bottom_right.x >= 128 then
                actor.velocity.x = actor.velocity.x * -1
                actor.transform.position.x = actor.transform.position.x - (bottom_right.x - 128)
            end

            if top_left.y <= 0 then
                actor.velocity.y = actor.velocity.y * -1
                actor.transform.position.y = actor.transform.position.y + (0 - top_left.y)
            elseif bottom_right.y >= 128 then
                actor.velocity.y = actor.velocity.y * -1
                actor.transform.position.y = actor.transform.position.y - (bottom_right.y - 128)
            end
        end

    end

    -- this gets real slow with lots of circles....
    for i, actor in pairs(actors) do
        -- if the circle is not moving, skip...
        if actor.velocity.x == 0 and actor.velocity.y == 0 then
            goto continue
        end

        overlapped_circles = get_overlapped_circles(actor)
        for i, overlapped_circle in pairs(overlapped_circles) do
            -- if the circle is smaller than the player, eat it
            if actor.transform.w > overlapped_circle.transform.w then
                local grow_amount = overlapped_circle.transform.w * 0.3
                actor.transform.w = actor.transform.w + grow_amount
                actor.transform.h = actor.transform.h + grow_amount
                del(actors, overlapped_circle)

                if (overlapped_circle == player) then
                    player = nil
                else
                    spawn_circle()
                end
            end
        end

        ::continue::
    end
end

function get_overlapped_circles(actor)
    local overlapped_circles = {}
    local actor_radius = actor.transform.w / 2
    local actor_position = actor.transform.position

    for i, other_actor in pairs(actors) do
        -- rect based overlap.. doesn't really fit for large circles
        --if actor ~= other_actor and actor.transform:intersects(other_actor.transform) then
        --    add(overlapped_circles, other_actor)
        --end

        if (actor == other_actor) then
            -- nothing
        else
            local other_radius = other_actor.transform.w / 2
            local other_position = other_actor.transform.position
            local distance = actor_position:distance(other_position)
            if (distance < actor_radius + other_radius) then
                add(overlapped_circles, other_actor)
            end
        end


    end
    return overlapped_circles
end

function get_overlapped_circle(actor)
    for i, other_actor in pairs(actors) do
        -- skip self
        if actor ~= other_actor and actor.transform:intersects(other_actor.transform) then
            return other_actor
        end
    end

    return nil
end

function handle_player_input()
    -- when X is pressed and only the player remains, start a new round
    if (btn(❎) and #actors == 1) then
        level = level + 1
        number_of_circles = number_of_circles + circle_increase_count
        init_round(number_of_circles)
    end

    -- if player is nil, bail
    if player == nil then
        if (btn(❎)) then
            level = 1
            number_of_circles = initial_circle_count
            init_round(number_of_circles)
        end
        return
    end

    local shift = vec:new()

    if btn(⬅️) then
        shift.x = -1
    end
    if btn(➡️) then
        shift.x = 1
    end
    if btn(⬆️) then
        shift.y = -1
    end
    if btn(⬇️) then
        shift.y = 1
    end

    player.velocity = player.velocity + shift * player.speed
end

function draw_messages()
    if player == nil then
        print("press X to restart", 2, 119, 8)
        print("press X to restart", 3, 120, 10)
        scale_text(5, "you", 9, 9, 8)
        scale_text(5, "you", 10, 10, 10)
        scale_text(5, "lose", 9, 49, 8)
        scale_text(5, "lose", 10, 50, 10)
        scale_text(5, "!!!", 9, 89, 8)
        scale_text(5, "!!!", 10, 90, 10)
    end
    if #actors == 1 and player ~= nil then
        print("press X for next round", 2, 119, 8)
        print("press X for next round", 3, 120, 10)
        scale_text(5, "you", 9, 9, 8)
        scale_text(5, "you", 10, 10, 10)
        scale_text(5, "win", 9, 49, 8)
        scale_text(5, "win", 10, 50, 10)
        scale_text(5, "!!!", 9, 89, 8)
        scale_text(5, "!!!", 10, 90, 10)
    end
end