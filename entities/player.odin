package entities

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
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool,
    side: PlayerSide
}

player_rect :: proc(player: ^Player) -> rl.Rectangle {
    return { player.pos.x, player.pos.y, u.player_size.x, u.player_size.y }
}

get_controls :: proc(side: PlayerSide) -> Controls {
    switch side {
        case .LEFT: return { .A, .D, .S }
        case .RIGHT: return { .J, .L, .K }
    }
    return {}
}

update_player :: proc(dt: f32, player: ^Player) {
    if !player.grounded {
        player.vel.y += u.gravity * dt
    }

    controls: Controls = get_controls(player.side)
    if rl.IsKeyDown(controls.left) {
        player.vel.x = -u.player_base_speed * u.player_speed_ampl * dt
    }
    else if rl.IsKeyDown(controls.right) {
        player.vel.x = u.player_base_speed * u.player_speed_ampl * dt
    } else {
        player.vel.x = 0.0
    }

    player.pos += player.vel * dt
}

draw_player :: proc(player: ^Player) {
    rl.DrawRectangleV(
        player.pos,
        u.player_size,
        player.side == PlayerSide.LEFT ? rl.RED : rl.GREEN
    )
}