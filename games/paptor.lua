-- maybe use this for maps? https://www.lexaloffle.com/bbs/?tid=42848

current_map = 1
base_map_position = -400
map_position = -400
map_percentage = 0
floored_map_percentage = 0
base_map_speed = 0.5
map_speed = 2 -- 0.5
player_speed = 4

default_gravity.y = 0;

-- @TODO Find a better way to do this, need to learn more about lua arrays/etc...
function make_map_actor_array()
    local array = {}
    -- for every % of the map progress...
    for i = 1, 100 do
        array[i] = {}
        -- ... allow up to 10 actors ot be spawned
        for j = 1, 10 do
            array[i][j] = nil
        end
    end
    return array
end

map_actors = { }
map_actors[1] = make_map_actor_array(100)
map_actors[1][5][1] = { enemy_cool_dog, 50, -30 };
map_actors[1][5][2] = { enemy_rock, 70, -30 };
map_actors[1][5][3] = { enemy_rock, 90, -30 };
map_actors[1][9][1] = { enemy_cool_dog, 30, -30 };
map_actors[1][9][2] = { enemy_rock, 50, -30 };
map_actors[1][9][3] = { enemy_rock, 20, -30 };

player = actor:new({
    -- bottom of map
    transform = drect:new({ position = vec:new({ x = 64, y = 110 }), w = 16, h = 16 }),
    --transform = drect:new({ position = vec:new({ x = 64, y = 120 }), w = 16, h = 16 }),
    sprite = 1,
    sprite_sheet_scale = vec:new({ x = 2, y = 2 }),
    health = 100,
    shield = 35,
})

function _init()
    cls()
    print("paptor: call of padows", 10, 10)

    --print("#X: " .. #map_actors[1][5][2])
    --print("X: " .. map_actors[1][5][2][1].sprite)

    set_map(1)
end

function _update()
    cls()
    handle_player_input()

    update_map_position()
    spawn_map_actors()
    update_actors()

    draw_map()
    draw_actors()
    draw_ui()

    draw_debug()
end

function set_map(map_number)
    current_map = map_number
    map_speed = base_map_speed
    map_position = base_map_position
end

function update_map_position()
    -- when there are 2 screens left, gradually decay map_speed until we get
    -- to the top, slowing to a stop at the top
    if (map_position > -128) then
        distance_left = -map_position
        map_speed = base_map_speed * (distance_left / 128)
    end

    map_adjustment = map_speed
    map_position = min(0, map_position + map_adjustment)

    map_percentage = (map_position - base_map_position) / (0 - base_map_position) * 100
    floored_map_percentage = flr(map_percentage)
end

function draw_map()
    map(
            (current_map - 1) * 16,
            0,
            0,
            map_position,
            16,
            64
    )
end

function draw_actors()
    for i, actor in pairs(actors) do
        actor:draw(not bounce_at_walls)
    end
end

function draw_debug()
    print("map:y: " .. map_position, 10, 10)
    print("map:%: " .. map_percentage .. " (" .. floored_map_percentage .. ")")
    print("#actors: " .. #actors)
end

function handle_player_input()
    if btn(⬅️) then
        player.transform.position.x = max(8, player.transform.position.x - player_speed)
    end
    if btn(➡️) then
        player.transform.position.x = min(120, player.transform.position.x + player_speed)
    end
    if btn(⬆️) then
        player.transform.position.y = max(8, player.transform.position.y - player_speed)
    end
    if btn(⬇️) then
        player.transform.position.y = min(120, player.transform.position.y + player_speed)
    end
end

function draw_ui()
    draw_ui_health_bar()
    draw_ui_shield_bar()
end

function draw_ui_health_bar()
    rectfill(
            2,
            125 - (player.health / 100 * 125) + 2,
            2,
            125,
            8
    )
end

function draw_ui_shield_bar()
    rectfill(
            4,
            125 - (player.shield / 100 * 125) + 2,
            4,
            125,
            10
    )
end

function spawn_map_actors()
    if map_actors[current_map] ~= nil then
        if map_actors[current_map][floored_map_percentage] ~= nil then
            percentage_actors = map_actors[current_map][floored_map_percentage]
            for j, spawn_spec in pairs(percentage_actors) do
                -- 1 is the definition, 2 is x, 3 is y
                new_actor = actor:new({
                    transform = drect:new({ position = vec:new({ x = spawn_spec[2], y = spawn_spec[3] }), w = 8, h = 8 }),
                    sprite = spawn_spec[1].sprite or 1,
                    health = spawn_spec[1].health or 10,
                    velocity = spawn_spec[1].velocity or nil,
                })
            end
            -- remove the actors to prevent respawn
            map_actors[current_map][floored_map_percentage] = nil
        end
    end
end

function update_actors()
    for i, a in pairs(actors) do
        if a ~= player then
            a:update()

            -- if the actor is off the screen, remove it
            if a.transform.position.y > 128 then
                del(actors, a)
            end
        end
    end
end