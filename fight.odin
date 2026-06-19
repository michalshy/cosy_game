package main

import rl "vendor:raylib"

succeed_game :: proc(player: ^Player) {
    player.fishing.timer = 0
    player.fishing.power = 0
    player.fishing.state = .IDLE
}

fighting_game :: proc(player: ^Player, dt: f32) {
    if true {
        // on time
        player.fight_game.on_time += dt
    }

    if player.fight_game.on_time >= fish_stats[player.fight_game.fish].fight_time/2 {
        succeed_game(player)
    }
}

draw_fight :: proc(player: ^Player) {
    fight := player.fight_game
    track_x: i32 = i32(player.fight_game.bar_pos.x)
    track_y: i32 = i32(player.fight_game.bar_pos.y)

    rl.DrawRectangle(track_x, track_y, fight_bar_width, 20, rl.DARKGRAY)

    rl.DrawRectangle(
        track_x + i32(fight.fish_pos.x),
        track_y,
        fight_bar_width,
        20,
        rl.ORANGE,
    )

    rl.DrawRectangle(
        track_x + i32(fight.bar_pos.x) - 2,
        track_y,
        4,
        20,
        rl.GREEN,
    )

    rl.DrawRectangleLines(track_x, track_y, fight_bar_width, 20, rl.WHITE)

    rl.DrawRectangleLines(track_x, track_y -  12, fight_bar_width, 8, rl.WHITE)
}