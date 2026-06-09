package entities

import "core:fmt"
import rl "vendor:raylib"
import u "../utils"

PlayerSide :: enum {
    LEFT,
    RIGHT
}

Controls :: struct {
    left: rl.KeyboardKey,
    right: rl.KeyboardKey,
    interact: rl.KeyboardKey
}

Player :: struct {
    enable_movement: bool,
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool,
    side: PlayerSide,
    fishing: Fishing,
    zone: ^FishingZone,
}

player_rect :: proc(player: ^Player) -> rl.Rectangle {
    return { player.pos.x, player.pos.y, u.player_size.x, u.player_size.y }
}

get_controls :: proc(side: PlayerSide) -> Controls {
    switch side {
        case .LEFT: return { .A, .D, .S }
        case .RIGHT: return { .J, .L, .K }
    }
    return {} // required
}

update_player :: proc(dt: f32, player: ^Player) {
    if !player.grounded {
        player.vel.y += u.gravity
    }


    controls: Controls = get_controls(player.side)
    if player.enable_movement {
        if rl.IsKeyDown(controls.left) {
            player.vel.x = -u.player_base_speed
        }
        else if rl.IsKeyDown(controls.right) {
            player.vel.x = u.player_base_speed
        } else {
            player.vel.x = 0.0
        }
    } else {
        player.vel.x = 0.0
    }

    if rl.IsKeyDown(controls.interact) {
        if player.zone != nil {
            player.fishing.state = State.THROW
            player.enable_movement = false
        }
    }
    

    player.pos += player.vel * dt
}

draw_debug :: proc(player: ^Player) {
    text := fmt.ctprintf("Player: %v", player.fishing.state)
    rl.DrawText(text, 10, 10 + i32(player.side == PlayerSide.LEFT ? 2 : 1) * 25, 20, rl.WHITE)
}

draw_player :: proc(player: ^Player) {
    rl.DrawRectangleV(
        player.pos,
        u.player_size,
        player.side == PlayerSide.LEFT ? rl.RED : rl.GREEN
    )

    draw_debug(player)
}