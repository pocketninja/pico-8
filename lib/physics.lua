function rect_collides_with_map(r, flag)
    local tl_cell = r:top_left():map_cell()
    local tr_cell = r:top_right():map_cell()
    local bl_cell = r:bottom_left():map_cell()
    local br_cell = r:bottom_right():map_cell()

    local tl = mget(tl_cell.x, tl_cell.y)
    local tr = mget(tr_cell.x, tr_cell.y)
    local bl = mget(bl_cell.x, bl_cell.y)
    local br = mget(br_cell.x, br_cell.y)

    local tl_flag = fget(tl, flag)
    local tr_flag = fget(tr, flag)
    local bl_flag = fget(bl, flag)
    local br_flag = fget(br, flag)

    result = tl_flag or tr_flag or bl_flag or br_flag

    return result

end