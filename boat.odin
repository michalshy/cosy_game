package main

import rl "vendor:raylib"
import "core:math"

update_boat :: proc(boat: ^Boat, dt: f32) {
    boat.time += dt
    move_boat(boat, dt)
}

draw_boat :: proc(boat: ^Boat) {
    rl.DrawRectangleV(
        boat.pos,
        boat_size,
        rl.DARKGRAY
    )

    // debug
    for zone in boat.zones {
        rl.DrawRectangleV(
            zone.pos,
            fishing_zone_size,
            rl.Color{122, 122, 122, 30}
        )

        rl.DrawRectangleV(
            zone.pond,
            fishing_pond_size,
            rl.Color{122, 122, 122, 30}
        )
    }
}

move_boat :: proc(boat: ^Boat, dt: f32) {
    boat.pos.y = f32(RENDER_H) - boat_init_y + math.sin(boat.time * boat_speed) * boat_amplitude
}

boat_rect :: proc(boat: ^Boat) -> rl.Rectangle {
    return { boat.pos.x, boat.pos.y, boat_size.x, boat_size.y }
}