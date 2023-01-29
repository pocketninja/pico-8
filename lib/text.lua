-- https://www.lexaloffle.com/bbs/?tid=29612
function scale_text(scale, str, x, y, c)
    x = x or 0
    y = y or 0
    c = c or 7
    memcpy(0x4300, 0x0, 0x0200)
    memset(0x0, 0, 0x0200)
    poke(0x5f55, 0x00)
    print(str, 0, 0, 7)
    poke(0x5f55, 0x60)

    local w, h = #str * 4, 5
    pal(7, c)
    palt(0, true)
    sspr(0, 0, w, h, x, y, w * scale, h * scale)
    pal()

    memcpy(0x0, 0x4300, 0x0200)
end