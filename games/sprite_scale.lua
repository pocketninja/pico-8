
function _update()
    cls()
    scale_step = 1.15

    x = 0
    y = 0
    w = 2

    -- while within screen space, scale out the sprite and
    -- coordinate
    while x < 128 and y < 128 do
        sspr(8, 0, 8, 8, x, y, w, w)
        x = x + w
        y = y + w
        w = w * scale_step
    end

end