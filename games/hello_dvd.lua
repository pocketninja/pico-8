
dvd = {
    x=40,
    y=40,
    dx,
    dy,
    w=30,
    h=10,
    speed=1,
    color=8,
}

function _init()
    print("hello ♥", 10, 10)

    --set the direction for the dvd
    dvd.dx = (abs(flr(2)-1) > 0) and 1 or -1
    dvd.dy = (abs(flr(2)-1) > 0) and 1 or -1
end

function _update()

    cls()

    update_dvd()

end

function set_color()
    dvd.color = flr(rnd(143))

    if dvd.color == 0
    then
        set_color()
    end

    pal(6, dvd.color)

end

function update_dvd()
    dvd.x += dvd.dx * dvd.speed
    dvd.y += dvd.dy * dvd.speed

    hw = dvd.w/2
    hh = dvd.h/2

    changed_x = false
    changed_y = false

    if (
    (dvd.x-hw) <= 0 or
    (dvd.x+hw) >= 128
    ) then
    dvd.dx *= -1
    changed_x = true
    end

    if (
    (dvd.y-hh) <= 0 or
    (dvd.y+hh) >= 128
    ) then
    dvd.dy *= -1
    changed_y = true
    end

    if (changed_x and changed_y)
    then
    print("celebrate! ♥♥♥")
    end

    if (changed_x or changed_y)
    then
    set_color()
    end

    x = dvd.x - hw
    y = dvd.y - hh
    x2 = x + dvd.w
    y2 = y + dvd.h

    // d = 1
    // v = 2
    // - = 17

    // left d
    spr(1,
    dvd.x - 8 - 4,
    dvd.y - 4
    )
    // right d
    spr(1,
    dvd.x + 4,
    dvd.y - 4
    )

    // v
    spr(2,
    dvd.x - 4,
    dvd.y - 4
    )

end