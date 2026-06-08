package entities

import rl "vendor:raylib"

Boat :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    time: f32
}
boat_size: rl.Vector2 : {600, 80}
boat_init_y: f32 : 250.0

boat_rect :: proc(boat: ^Boat) -> rl.Rectangle {
    return { boat.pos.x, boat.pos.y, boat_size.x, boat_size.y }
}