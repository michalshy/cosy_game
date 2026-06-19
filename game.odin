package main

import rl "vendor:raylib"

state: GameState = {}

update :: proc(delta_time: f32) {
    for &player in state.players {
        update_player(delta_time, &player)
    }
    update_boat(&state.boat, delta_time)
    for &player in state.players {
        collisions(&player, &state.boat)
    }
}

draw :: proc() {
    for &player in state.players {
        draw_player(&player)
    }
    draw_boat(&state.boat)
}

collisions :: proc(player: ^Player, boat: ^Boat) {
    if rl.CheckCollisionRecs(
        player_rect(player), boat_rect(boat)
    ) {
        player.grounded = true
        player.vel.y = 0
        player.pos.y = boat.pos.y - player_size.y
    } else {
        player.grounded = false
    }

    for &zone in boat.zones {
        if rl.CheckCollisionRecs(
            player_rect(player), zone_rect(&zone)
        ) {
            player.zone = &zone
            break
        } else {
            player.zone = nil
        }
    }
}

main :: proc() {
    rl.InitWindow(0, 0, "Fishy")
    rl.ToggleBorderlessWindowed()
    rl.SetTargetFPS(120)
    
    SCREEN_WIDTH := RENDER_W
    SCREEN_HEIGHT := RENDER_H
    respawn_offset :: 150
    starting_y := f32(SCREEN_HEIGHT)  - player_size.y - boat_init_y - 10
    
    // init players
    state.players[0] = Player{
        pos = {f32(SCREEN_WIDTH / 4) + respawn_offset, starting_y},
        side = Side.LEFT
    }
    state.players[1] = Player{
        pos = {f32(SCREEN_WIDTH - (SCREEN_WIDTH / 4)) - respawn_offset, starting_y},
        side = Side.RIGHT
    }
    
    // init boat
    state.boat = Boat{
        pos = {(f32(SCREEN_WIDTH) - boat_size.x) / 2.0, f32(SCREEN_HEIGHT) - boat_init_y},
        time = 0.0,
    }
    state.boat.zones = init_zones(&state.boat)

    load_sprites()
    state.players[0].current_sprite = &state.players[0].sprites.idle;
    state.players[1].current_sprite = &state.players[1].sprites.idle;

    render_target := rl.LoadRenderTexture(RENDER_W, RENDER_H)

    for !rl.WindowShouldClose() {
        update(rl.GetFrameTime())

        rl.BeginTextureMode(render_target)
            rl.ClearBackground(rl.SKYBLUE)
            draw()
        rl.EndTextureMode()

        rl.BeginDrawing()
            src := rl.Rectangle{0, 0, RENDER_W, -RENDER_H}
            dst := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
            rl.DrawTexturePro(render_target.texture, src, dst, {0, 0}, 0, rl.WHITE)
        rl.EndDrawing()
    }

    rl.UnloadRenderTexture(render_target)
    unload_sprites()
    rl.CloseWindow()
}