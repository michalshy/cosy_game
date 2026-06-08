package entities

import rl "vendor:raylib"
import "../utils"
import "core:math"
import u "../utils"

Boat :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    time: f32
}

boat_rect :: proc(boat: ^Boat) -> rl.Rectangle {
    return { boat.pos.x, boat.pos.y, u.boat_size.x, u.boat_size.y }
}

update_boat :: proc(boat: ^Boat, dt: f32) {
    boat.time += dt
    move_boat(boat, dt)
}

move_boat :: proc(boat: ^Boat, dt: f32) {
    boat.pos.y += math.sin(boat.time * u.boat_speed) * u.boat_amplitude
}

draw_boat :: proc(boat: ^Boat) {
    rl.DrawRectangleV(
        boat.pos,
        u.boat_size,
        rl.DARKGRAY
    )
}