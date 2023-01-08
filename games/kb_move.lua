player = {
    position = {
        x = 10,
        y = 10,
    },
    speed = 1,
    speed_scale = 1,
    sprite = 1,
}

function _init()
    print("Hello! This is KB Move...")
end

function _update()
    cls()
    handle_input()
    spr(player.sprite, player.position.x, player.position.y)
end

function handle_input()
    if btn(⬅️)
    then
        player.position.x -= player.speed
    end
    if btn(➡️)
    then
        player.position.x += player.speed
    end
    if btn(⬆️)
    then
        player.position.y -= player.speed
    end
    if btn(⬇️)
    then
        player.position.y += player.speed
    end

    -- when X is pressed, set speed to 2
    if btn(❎)
    then
        player.speed = 3
    else
        player.speed = 1
    end

    --clamp to screen size
    player.position.x = mid(0, player.position.x, 128 - 8)
    player.position.y = mid(0, player.position.y, 128 - 8)
end