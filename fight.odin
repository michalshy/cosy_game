package main

import rl "vendor:raylib"

succeed_game :: proc(player: ^Player) {
    player.fishing.timer  = 0
    player.fishing.power  = 0
    player.fishing.state  = .IDLE
    if player.fight_game != nil {
        free(player.fight_game)
        player.fight_game = nil
    }
}

fighting_game :: proc(player: ^Player, dt: f32) {
    fight := player.fight_game
    stats := fish_stats[fight.fish]
    bar_len := f32(fight_bar_height)
    fish_w  := f32(stats.bar_width)

    fight.fish_t += fight.fish_vel * dt
    if fight.fish_t <= 0 || fight.fish_t + fish_w >= bar_len {
        fight.fish_vel = -fight.fish_vel
        fight.fish_t   = clamp(fight.fish_t, 0, bar_len - fish_w)
    }

    controls := get_controls(player.side)
    if rl.IsKeyDown(controls.left)  { fight.bar_t -= 150 * dt }
    if rl.IsKeyDown(controls.right) { fight.bar_t += 150 * dt }
    fight.bar_t = clamp(fight.bar_t, 0, bar_len)

    if fight.bar_t >= fight.fish_t && fight.bar_t <= fight.fish_t + fish_w {
        fight.on_time += dt
    }

    if fight.on_time >= stats.fight_time {
        succeed_game(player)
    }
}

draw_fight :: proc(player: ^Player) {
    fight := player.fight_game
    tx := i32(fight.track_origin.x)
    ty := i32(fight.track_origin.y)
    fish_w := fish_stats[fight.fish].bar_width

    rl.DrawRectangle(tx, ty, fight_bar_height, 20, rl.DARKGRAY)
    rl.DrawRectangle(tx + i32(fight.fish_t), ty, fish_w, 20, rl.ORANGE)
    rl.DrawRectangle(tx + i32(fight.bar_t) - 2, ty, 4, 20, rl.GREEN)
    rl.DrawRectangleLines(tx, ty, fight_bar_height, 20, rl.WHITE)
}
