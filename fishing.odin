package main

import rl "vendor:raylib"

init_zones :: proc(boat: ^Boat) -> [2]FishingZone {
    zones: [2]rl.Vector2 = get_fishing_zones(boat)
    ponds: [2]rl.Vector2 = get_fishing_ponds(boat)

    return {
        { side = Side.LEFT, pos = zones[0], pond = ponds[0] },
        { side = Side.RIGHT, pos = zones[1], pond = ponds[1] }
    }
}

update_fishing :: proc(player: ^Player, dt: f32) {
    player.fishing.timer -= dt

    if player.fishing.state == .IDLE && player.fight_game != nil {
        free(player.fight_game)
    }

    switch player.fishing.state
    {
        case .IDLE: return
        case .THROW: {
            if player.fishing.timer <= 0 {
                player.fishing.state = .IDLE
                if player.fight_game != nil {
                    free(player.fight_game)
                }
            }
        }
        case .WAIT: {
            if player.fishing.timer <= 0 {
                if player.fight_game != nil {
                    player.fishing.state = .BITE
                    player.fishing.timer = fish_stats[player.fight_game.fish].bite_time
                }
            }
        }
        case .BITE: {
            if player.fishing.timer <= 0 {
                player.fishing.state = .IDLE
                if player.fight_game != nil {
                    free(player.fight_game)
                }
            }
        }
        case .FIGHT: {
            fighting_game(player, dt)
        }
    }
}

draw_throwing :: proc(player: ^Player) {
    progress := 1.0 - (player.fishing.timer / throwing_time)

    bar_w: f32 = 60
    bar_h: f32 = 8
    x := player.pos.x - (bar_w - player_size.x) / 2
    y := player.pos.y - 20

    rl.DrawRectangle(i32(x), i32(y), i32(bar_w), i32(bar_h), rl.GRAY)
    rl.DrawRectangle(i32(x), i32(y), i32(bar_w * progress), i32(bar_h), rl.YELLOW)
}

draw_bobber :: proc(player: ^Player) {
    if player.fishing.bobber_active {
        rl.DrawRectangle(i32(player.zone.bobber_pos.x), i32(player.zone.bobber_pos.y), i32(bobber_size.x), i32(bobber_size.y), rl.RED)
    }
}

zone_rect :: proc(zone: ^FishingZone) -> rl.Rectangle {
    return { zone.pos.x, zone.pos.y, fishing_zone_size.x, fishing_zone_size.y }
}

get_fishing_zones :: proc(boat: ^Boat) -> [2]rl.Vector2 {
    return {
        { boat.pos.x, boat.pos.y - fishing_zone_size.y },
        { boat.pos.x + boat_size.x - fishing_zone_size.x, boat.pos.y - fishing_zone_size.y }
    }
}

get_fishing_ponds :: proc(boat: ^Boat) -> [2]rl.Vector2 {
    return {
        { boat.pos.x - fishing_pond_size.x - f32(fishing_pond_offset), boat.pos.y + boat_size.y / 2 },
        { boat.pos.x + boat_size.x + f32(fishing_pond_offset), boat.pos.y + boat_size.y / 2 }
    }
}