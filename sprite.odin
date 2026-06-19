package main

import rl "vendor:raylib"

update_sprite :: proc(s: ^Sprite, dt: f32) {
    s.timer += dt
    if s.timer >= s.frame_time {
        s.timer = 0
        s.frame = (s.frame + 1) % s.frame_count
    }
}

load_sprite :: proc(path: cstring, frame_count: i32, frame_time: f32) -> Sprite {
    tex := rl.LoadTexture(path)
    return {
        texture = tex,
        frame_count = frame_count,
        frame_w     = f32(tex.width) / f32(frame_count),
        frame_h     = f32(tex.height),
        frame_time  = frame_time,
    }
}

load_sprites :: proc() {
    state.players[0].sprites.idle = load_sprite("assets/fisherman/idle.png", 4, 0.15)
    state.players[0].sprites.walk = load_sprite("assets/fisherman/walk.png", 6, 0.15)
    state.players[1].sprites.idle = load_sprite("assets/fisherman/idle.png", 4, 0.15)
    state.players[1].sprites.walk = load_sprite("assets/fisherman/walk.png", 6, 0.15)
}

unload_sprites :: proc() {
    rl.UnloadTexture(state.players[0].sprites.idle.texture)
    rl.UnloadTexture(state.players[1].sprites.idle.texture)
    rl.UnloadTexture(state.players[0].sprites.walk.texture)
    rl.UnloadTexture(state.players[1].sprites.walk.texture)
}