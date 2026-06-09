package entities

import rl "vendor:raylib"
import "core:math"
import u "../utils"

Boat :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    time: f32,
    zones: [2]FishingZone
}

boat_rect :: proc(boat: ^Boat) -> rl.Rectangle {
    return { boat.pos.x, boat.pos.y, u.boat_size.x, u.boat_size.y }
}

update_boat :: proc(boat: ^Boat, dt: f32) {
    boat.time += dt
    move_boat(boat, dt)
}

move_boat :: proc(boat: ^Boat, dt: f32) {
    boat.pos.y = f32(rl.GetScreenHeight()) - u.boat_init_y + math.sin(boat.time * u.boat_speed) * u.boat_amplitude
}

get_fishing_zones :: proc(boat: ^Boat) -> [2]rl.Vector2 {
    return {
        { boat.pos.x, boat.pos.y - u.fishing_zone_size.y },
        { boat.pos.x + u.boat_size.x - u.fishing_zone_size.x, boat.pos.y - u.fishing_zone_size.y }
    }
}

draw_boat :: proc(boat: ^Boat) {
    rl.DrawRectangleV(
        boat.pos,
        u.boat_size,
        rl.DARKGRAY
    )

    for zone in boat.zones {
        rl.DrawRectangleV(
            zone.pos,
            u.fishing_zone_size,
            rl.Color{122, 122, 122, 30}
        )
    }
}

