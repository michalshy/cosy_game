package main

import rl "vendor:raylib"

Player :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool
}

PLAYER_NO :: enum {
    FIRST,
    SECOND
}

update :: proc(delta_time: f32) {
    update_player(PLAYER_NO.FIRST)
    update_player(PLAYER_NO.SECOND)
    update_boat()
    update_env()
}

update_player :: proc(no: PLAYER_NO) {

}

update_boat :: proc() {

}

update_env :: proc() {

}

draw :: proc() {
    draw_player(PLAYER_NO.FIRST)
    draw_player(PLAYER_NO.SECOND)
    draw_boat()
    draw_env()
}

draw_player :: proc(no: PLAYER_NO) {

}

draw_boat :: proc() {

}

draw_env :: proc() {

}

main :: proc() {

    SCREEN_WIDTH := rl.GetScreenWidth()
    SCREEN_HEIGHT := rl.GetScreenHeight()
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Fishy")
    rl.ToggleBorderlessWindowed()
    rl.SetTargetFPS(120)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime())
        draw()

        rl.EndDrawing()
    }
}