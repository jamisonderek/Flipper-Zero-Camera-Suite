#include "../camera_suite.h"
#include <lib/toolbox/value_index.h>

// Camera orientation, in degrees.
const char* const orientation_text[4] = {
    "0",
    "90",
    "180",
    "270",
};

const uint32_t orientation_value[4] = {
    CameraSuiteOrientation0,
    CameraSuiteOrientation90,
    CameraSuiteOrientation180,
    CameraSuiteOrientation270,
};

// Possible dithering types for the camera.
const char* const dither_text[28] = {
    "Floyd-Steinberg",
    "Stucki",
    "Jarvis-Judice-Ninke",
};

const uint32_t dither_value[4] = {
    CameraSuiteDitherFloydSteinberg,
    CameraSuiteDitherStucki,
    CameraSuiteDitherJarvisJudiceNinke,
};

const char* const flash_text[2] = {
    "OFF",
    "ON",
};

const uint32_t flash_value[2] = {
    CameraSuiteFlashOff,
    CameraSuiteFlashOn,
};

const char* const frames_text[] = {
    "Disabled",
    "2",
    "4",
    "6",
    "8",
    "10",
    "16",
    "20",
};

const uint32_t frames_value[] = {
    0,
    2,
    4,
    6,
    8,
    10,
    16,
    20,
};

const char* const jpeg_text[2] = {
    "OFF",
    "ON",
};

const uint32_t jpeg_value[2] = {
    CameraSuiteJpegOff,
    CameraSuiteJpegOn,
};

static void camera_suite_scene_cam_settings_set_camera_orientation(VariableItem* item) {
    CameraSuite* app = variable_item_get_context(item);
    uint8_t index = variable_item_get_current_value_index(item);

    variable_item_set_current_value_text(item, orientation_text[index]);
    app->orientation = orientation_value[index];
}

static void camera_suite_scene_cam_settings_set_camera_dither(VariableItem* item) {
    CameraSuite* app = variable_item_get_context(item);
    uint8_t index = variable_item_get_current_value_index(item);

    variable_item_set_current_value_text(item, dither_text[index]);
    app->dither = dither_value[index];
}

static void camera_suite_scene_cam_settings_set_flash(VariableItem* item) {
    CameraSuite* app = variable_item_get_context(item);
    uint8_t index = variable_item_get_current_value_index(item);

    variable_item_set_current_value_text(item, flash_text[index]);
    app->flash = flash_value[index];
}

static void camera_suite_scene_cam_settings_set_frames(VariableItem* item) {
    CameraSuite* app = variable_item_get_context(item);
    uint8_t index = variable_item_get_current_value_index(item);

    variable_item_set_current_value_text(item, frames_text[index]);
    app->frames = frames_value[index];
    create_animation_files(app->frames);
}

static void camera_suite_scene_cam_settings_set_jpeg(VariableItem* item) {
    CameraSuite* app = variable_item_get_context(item);
    uint8_t index = variable_item_get_current_value_index(item);

    variable_item_set_current_value_text(item, jpeg_text[index]);
    app->jpeg = jpeg_value[index];
}

void camera_suite_scene_cam_settings_submenu_callback(void* context, uint32_t index) {
    CameraSuite* app = context;
    view_dispatcher_send_custom_event(app->view_dispatcher, index);
}

void camera_suite_scene_cam_settings_on_enter(void* context) {
    CameraSuite* app = context;
    VariableItem* item;
    uint8_t value_index;

    // Camera Orientation
    item = variable_item_list_add(
        app->variable_item_list,
        "Orientation:",
        4,
        camera_suite_scene_cam_settings_set_camera_orientation,
        app);
    value_index = value_index_uint32(app->orientation, orientation_value, 4);
    variable_item_set_current_value_index(item, value_index);
    variable_item_set_current_value_text(item, orientation_text[value_index]);

    // Camera Dither Type
    item = variable_item_list_add(
        app->variable_item_list,
        "Dithering Type:",
        3,
        camera_suite_scene_cam_settings_set_camera_dither,
        app);
    value_index = value_index_uint32(app->dither, dither_value, 3);
    variable_item_set_current_value_index(item, value_index);
    variable_item_set_current_value_text(item, dither_text[value_index]);

    // Flash ON/OFF
    item = variable_item_list_add(
        app->variable_item_list, "Flash:", 2, camera_suite_scene_cam_settings_set_flash, app);
    value_index = value_index_uint32(app->flash, flash_value, 2);
    variable_item_set_current_value_index(item, value_index);
    variable_item_set_current_value_text(item, flash_text[value_index]);

    item = variable_item_list_add(
        app->variable_item_list,
        "Frames:",
        COUNT_OF(frames_text),
        camera_suite_scene_cam_settings_set_frames,
        app);
    value_index = value_index_uint32(app->frames, frames_value, COUNT_OF(frames_value));
    variable_item_set_current_value_index(item, value_index);
    variable_item_set_current_value_text(item, frames_text[value_index]);

    // @todo - Save picture to ESP32-CAM sd-card instead of Flipper Zero
    // sd-card. This hides the setting for it, for now.
    // Save JPEG to ESP32-CAM sd-card instead of Flipper Zero sd-card ON/OFF
    // item = variable_item_list_add(
    //     app->variable_item_list,
    //     "Save JPEG to ext sdcard:",
    //     2,
    //     camera_suite_scene_cam_settings_set_jpeg,
    //     app);
    // value_index = value_index_uint32(app->jpeg, jpeg_value, 2);
    // variable_item_set_current_value_index(item, value_index);
    // variable_item_set_current_value_text(item, jpeg_text[value_index]);
    UNUSED(camera_suite_scene_cam_settings_set_jpeg);

    view_dispatcher_switch_to_view(app->view_dispatcher, CameraSuiteViewIdCamSettings);
}

bool camera_suite_scene_cam_settings_on_event(void* context, SceneManagerEvent event) {
    CameraSuite* app = context;
    UNUSED(app);
    bool consumed = false;
    if(event.type == SceneManagerEventTypeCustom) {
    }
    return consumed;
}

void camera_suite_scene_cam_settings_on_exit(void* context) {
    CameraSuite* app = context;
    variable_item_list_set_selected_item(app->variable_item_list, 0);
    variable_item_list_reset(app->variable_item_list);
}
