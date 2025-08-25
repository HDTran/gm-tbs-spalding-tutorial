function NewEncounter(_enemies, _bg) {
    var TOPMOST_DEPTH = -9999;
    instance_create_depth(
        camera_get_view_x(view_camera[0]),
        camera_get_view_y(view_camera[0]),
        TOPMOST_DEPTH,
        oBattle,
        { enemies: _enemies, creator: id, battleBackground: _bg }
    );
}