package main

import "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"

update_player :: proc(dt: f32, player: ^Player) {
    update_fishing(player, dt)
    
    check_grounded(player, dt)
    apply_controls(player, dt)
    
    update_sprite(player.current_sprite, dt)

    // apply velocity
    player.pos += player.vel * dt
}

check_grounded :: proc(player: ^Player, dt: f32) {
    if !player.grounded {
        player.vel.y += gravity * dt
    }
}

get_controls :: proc(side: Side) -> Controls {
    switch side {
        case .LEFT: return { .A, .D, .S }
        case .RIGHT: return { .J, .L, .K }
    }
    return {} // required
}

apply_controls :: proc(player: ^Player, dt: f32) {
    controls: Controls = get_controls(player.side)

    if rl.IsKeyDown(controls.left) || rl.IsKeyDown(controls.right) {
        player.current_sprite = &player.sprites.walk
    } else {
        player.current_sprite = &player.sprites.idle
    }

    if player.flip {
        if player.vel.x > 0 {
            player.flip = false
        }
    } else {
        if player.vel.x < 0 {
            player.flip = true
        }
    }

    if player.fishing.state == .IDLE {
        if rl.IsKeyDown(controls.left) {
            player.vel.x = -player_base_speed
        }
        else if rl.IsKeyDown(controls.right) {
            player.vel.x = player_base_speed
        } else {
            player.vel.x = 0.0
        }
    } else {
        player.vel.x = 0.0
    }

    if rl.IsKeyPressed(controls.interact) {
        if player.zone != nil && player.fishing.state == .IDLE {
            player.fishing.state = .THROW
            player.fishing.timer = throwing_time
        }
        if player.fishing.state == .BITE {
            player.fishing.state = .FIGHT
            player.fishing.timer = fish_stats[player.fight_game.fish].fight_time
        }
    }
    if rl.IsKeyReleased(controls.interact) {
        if player.zone != nil && player.fishing.state == .THROW {
            // we still successed to throw
            if player.fishing.timer >= 0.0 {
                // add power
                player.fishing.state = .WAIT
                player.fishing.power = 1.0 - (player.fishing.timer / throwing_time)
                player.fishing.bobber_active = true
                t := player.side == .LEFT ? (1.0 - player.fishing.power) : player.fishing.power
                player.zone.bobber_pos.x = player.zone.pond.x + fishing_pond_size.x * t
                player.zone.bobber_pos.y = player.zone.pond.y + bobber_size.y/2

                // active game
                if player.fight_game == nil {
                    type: FishType = .ROACH
                    player.fight_game = new(FightGame)
                    player.fight_game.fish         = type
                    player.fight_game.track_origin = bar_pos[player.zone.side]
                    player.fight_game.fish_t       = f32(fight_bar_height) / 2
                    player.fight_game.fish_vel     = fish_stats[type].fish_speed
                    player.fight_game.bar_t        = f32(fight_bar_height) / 2

                    player.fishing.timer = rand.float32_range(fish_stats[type].wait_min, fish_stats[type].wait_max)
                }
            }
        }
    }
}

draw_player :: proc(player: ^Player) {
    s := player.current_sprite
    src := rl.Rectangle{
        f32(s.frame) * s.frame_w,
        0,
        player.flip ? -s.frame_w : s.frame_w,
        s.frame_h,
    }
    rl.DrawTextureRec(player.current_sprite.texture, src, player.pos, rl.WHITE)
    // Collider debug
    // pos := rl.Vector2{
    //     player.flip ? player.pos.x + s.frame_w : player.pos.x,
    //     player.pos.y,
    // }
    // rl.DrawRectangleLines(i32(player.pos.x), i32(player.pos.y), 32, 48, rl.RED)

    switch player.fishing.state {
        case .IDLE: break
        case .THROW: {
            draw_throwing(player)
        }
        case .WAIT: {
            draw_bobber(player)
        }
        case .BITE: {
            draw_bobber(player)
        }
        case .FIGHT: {
            draw_bobber(player)
            draw_fight(player)
        }
    }

    draw_debug(player)
}

draw_debug :: proc(player: ^Player) {
    text := fmt.ctprintf("Player: %v", player.fishing.state)
    rl.DrawText(text, 10, 10 + i32(player.side == Side.LEFT ? 2 : 1) * 25, 20, rl.WHITE)
}

player_rect :: proc(player: ^Player) -> rl.Rectangle {
    return { player.pos.x, player.pos.y, player_size.x, player_size.y }
}