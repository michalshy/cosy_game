package entities

import rl "vendor:raylib"

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
player_size: rl.Vector2 : {20, 60}

player_rect :: proc(player: ^Player) -> rl.Rectangle {
    return { player.pos.x, player.pos.y, player_size.x, player_size.y }
}

get_controls :: proc(side: PlayerSide) -> Controls {
    switch side {
        case .LEFT: return { .A, .D, .S }
        case .RIGHT: return { .J, .L, .K }
    }
    return {}
}
