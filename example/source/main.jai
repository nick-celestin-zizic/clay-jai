#load "common.jai";
// #load "layout.jai";

Library :: struct {
    handle: *void;
    using procedures: Layout_Library_Procedures;
}

load_library :: (old_library: Library) -> Library {
    using File_Utilities; using File;
    if !file_exists("layout-new.dll") {
        if old_library.handle return .{}; else {
            // its not there! look for backup
            if file_exists("layout.dll") {
                atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout.dll", "layout-new.dll");
                atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout.exp", "layout-new.exp");
                atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout.lib", "layout-new.lib");
                atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout.pdb", "layout-new.pdb");
            } else {
                log_error("could not find any layout dll!");
                return .{};
            }
        }
    }
    
    dummy_library := load_dynamic_library("layout-new", struct{});
    if !dummy_library {
        code, description := System.get_error_value_and_string();
        log_error("Could not load layout library: (%) %", code, description);
        return .{};
    }
    
    clay_state := ifx old_library.layout_get_clay_state then old_library.layout_get_clay_state();
    
    if old_library.handle then unload_dynamic_library(old_library.handle);
    unload_dynamic_library(dummy_library);
    
    atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout-new.dll", "layout.dll");
    atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout-new.exp", "layout.exp");
    atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout-new.lib", "layout.lib");
    atomic_file_replace_or_just_rename_if_destination_file_does_not_exist("layout-new.pdb", "layout.pdb");
    file_delete("layout-new.dll");
    file_delete("layout-new.exp");
    file_delete("layout-new.lib");
    file_delete("layout-new.pdb");
    
    
    using new_library: Library = ---;
    handle, procedures = load_dynamic_library("layout", Layout_Library_Procedures);
    layout_init(*state, ifx old_library.layout_get_clay_state then *clay_state);
    return new_library;
}

state := State.{
    measure_text = raylib_measure_text,
    render = raylib_render,
};
main :: () {
    using state;
    set_working_directory(String.path_strip_filename(System.get_path_of_running_executable()));
    
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }
    
    { using Raylib.ConfigFlags;
        Raylib.SetConfigFlags(xx (
            FLAG_VSYNC_HINT     |
            FLAG_WINDOW_HIGHDPI |
            FLAG_MSAA_4X_HINT   |
            FLAG_WINDOW_RESIZABLE
        ));
    }
    
    Raylib.InitWindow(xx window_width, xx window_height, "Clay - Raylib Renderer Example");
    Raylib.SetTargetFPS(Raylib.GetMonitorRefreshRate(0));
    
    
    layout_library := load_library(.{});
    assert(xx layout_library.handle);
    assert(xx layout_library.layout_init);
    assert(xx layout_library.layout_update);
    assert(xx layout_library.layout_get_clay_state);
    
    load_font(FONT_TITLE_56,     56, "../resources/Calistoga-Regular.ttf");
    load_font(FONT_TITLE_36,     36, "../resources/Calistoga-Regular.ttf");
    load_font(FONT_BODY_16,      16, "../resources/Quicksand-Semibold.ttf");
    load_font(FONT_BODY_24,      24, "../resources/Quicksand-Semibold.ttf");
    load_font(FONT_BODY_36,      36, "../resources/Quicksand-Semibold.ttf");
    load_font(FONT_MONOSPACE_24, 24, "../resources/RobotoMono-Medium.ttf");
    
    image_syntax = load_image(0, "../resources/declarative.png");
    image_syntax = load_image(1, "../resources/declarative.png");
    image_debug0 = load_image(2, "../resources/debugger.png");
    image_check1 = load_image(3, "../resources/check_1.png");
    image_check2 = load_image(4, "../resources/check_2.png");
    image_check3 = load_image(5, "../resources/check_3.png");
    image_check4 = load_image(6, "../resources/check_4.png");
    image_check5 = load_image(7, "../resources/check_5.png");
    
    while (!Raylib.WindowShouldClose()) {
        reset_temporary_storage();
        
        mouse_position    = cast,force(Math.Vector2) Raylib.GetMousePosition();
        mouse_wheel_delta = cast,force(Math.Vector2) Raylib.GetMouseWheelMoveV();
        left_mouse_down   = Raylib.IsMouseButtonDown(0);
        delta_time        = Raylib.GetFrameTime();
        is_d_key_pressed  = Raylib.IsKeyPressed(.KEY_D);
        window_width, window_height = cast(float) Raylib.GetScreenWidth(), cast(float) Raylib.GetScreenHeight();
        
        layout_library.layout_update(*state);
        
        new_library := load_library(layout_library);
        if   new_library.handle
        then layout_library = new_library;
    }
}

using Basic    :: #import "Basic";
Compiler       :: #import "Compiler";
Program_Print  :: #import "Program_Print";
Math           :: #import "Math";
String         :: #import "String";
System         :: #import "System";
Windows        :: #import "Windows";
Raylib         :: #import "raylib-jai";
File_Utilities :: #import "File_Utilities";
File           :: #import "File";
Clay           :: #import,file "../../module.jai";

load_dynamic_library :: (basename: string, $procedure_table_type: Type) -> *void, procedure_table_type {
    table: procedure_table_type;
    
    handle := Windows.LoadLibraryA(tprint("%.dll\0", basename).data);
    if !handle return null, table;
    
    for type_info(procedure_table_type).members {
                // cast(cast(*procedures, *u8) + it.offset_in_bytes, **void)
        address := (cast(**void)((cast(*u8) *table) + it.offset_in_bytes));
        address.* = Windows.GetProcAddress(handle, it.name.data);
        if !address.* return null, table;
        assert(xx address.*, "Could not get % from %.dll: %", it.name, basename, System.get_error_string(System.get_error_value()));
    }
    
    return handle, table;
}

unload_dynamic_library :: inline (library_handle: *void) {
    Windows.FreeLibrary(library_handle);
}



// TODO: Simp Renderer so we don't rely on some random raylib module for this example
Raylib_Font :: struct { fontId: u32; font: Raylib.Font; }

raylib_fonts: [10]Raylib_Font;
raylib_images: [10]Raylib.Texture2D;

raylib_camera: Raylib.Camera;

load_font :: (id: u16, size: u16, path: string) {
    f := Raylib.LoadFontEx(to_c_string(path), size*2, null, 0);
    raylib_fonts[id] = .{
        font   = f,
        fontId = id,
    };
    Raylib.SetTextureFilter(raylib_fonts[id].font.texture, xx Raylib.TextureFilter.RL_TEXTURE_FILTER_BILINEAR);
}

load_image :: (id: int, path: string) -> *Raylib.Texture2D {
    raylib_images[id] = Raylib.LoadTextureFromImage(Raylib.LoadImage(path.data));
    return *raylib_images[id];
}

measure_calls: u32;
raylib_measure_text :: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call { 
    using Clay;
    textSize := Dimensions.{0, 0};

    maxTextWidth: float = 0;
    lineTextWidth: float = 0;

    textHeight := cast(float)config.fontSize;
    fontToUse := raylib_fonts[config.fontId].font;

    for i: 0 ..text.length-1 {
        if (text.chars[i] == #char "\n") {
            maxTextWidth = ifx maxTextWidth > lineTextWidth then maxTextWidth else lineTextWidth;
            lineTextWidth = 0;
            continue;
        }
        index := cast(s32)text.chars[i] - 32;
        if (fontToUse.glyphs[index].advanceX != 0) {
            lineTextWidth += cast(float)fontToUse.glyphs[index].advanceX;
        } else {
            lineTextWidth += (fontToUse.recs[index].width + cast(float)fontToUse.glyphs[index].offsetX);
        }
    }

    maxTextWidth = ifx maxTextWidth > lineTextWidth then maxTextWidth else lineTextWidth;

    textSize.width = maxTextWidth / 2;
    textSize.height = textHeight;

    return textSize;
}

raylib_render :: (_commands: *void) {
    using Clay;
    R :: Raylib;
    renderCommands := (cast(*RenderCommandArray) _commands).*;
    
    R.BeginDrawing();
    R.ClearBackground(R.BLACK);
    
    to_raylib_color :: (color: Color) -> R.Color #expand {
        return .{ r = cast(u8)(0.5+color.r), g = cast(u8)(0.5+color.g), b = cast(u8)(0.5+color.b), a = cast(u8)(0.5+color.a) };
    }
    
    round :: (f: float) -> s32 #expand {
        return xx (f + 0.5);
    }
    
    measure_calls = 0;
    for j: 0..renderCommands.length-1
    // for (int j = 0; j < renderCommands.length; j++)
    {
        renderCommand := RenderCommandArray_Get(*renderCommands, xx j);
        boundingBox := renderCommand.boundingBox;
        if #complete renderCommand.commandType ==
        {
            case .TEXT; {
                // Raylib uses standard C strings so isn't compatible with cheap slices, we need to clone the string to append null terminator
                text := renderCommand.text;
                cloned := cast(*u8)alloc(text.length + 1);
                memcpy(cloned, text.chars, text.length);
                cloned[text.length] = #char "\0";
                fontToUse := raylib_fonts[renderCommand.config.textElementConfig.fontId].font;
                R.DrawTextEx(fontToUse, cloned, .{boundingBox.x, boundingBox.y}, cast(float)renderCommand.config.textElementConfig.fontSize, cast(float)renderCommand.config.textElementConfig.letterSpacing, to_raylib_color(renderCommand.config.textElementConfig.textColor));
                free(cloned);
            }
            case .IMAGE; {
                imageTexture := (cast(*R.Texture2D)renderCommand.config.imageElementConfig.imageData).*;
                R.DrawTextureEx(
                imageTexture,
                .{boundingBox.x, boundingBox.y},
                0,
                boundingBox.width / cast(float)imageTexture.width,
                R.WHITE);
            }
            case .SCISSOR_START; {
                R.BeginScissorMode(round(boundingBox.x), round(boundingBox.y), round(boundingBox.width), round(boundingBox.height));
            }
            case .SCISSOR_END; {
                R.EndScissorMode();
            }
            case .RECTANGLE; {
                config := renderCommand.config.rectangleElementConfig;
                if (config.cornerRadius.topLeft > 0) {
                    radius := (config.cornerRadius.topLeft * 2) / cast(float) (ifx (boundingBox.width < boundingBox.height) then boundingBox.height else boundingBox.width);
                    R.DrawRectangleRounded(
                        .{ boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height },
                        radius, 8, to_raylib_color(config.color)
                    );
                } else {
                    R.DrawRectangle(xx boundingBox.x, xx boundingBox.y, xx boundingBox.width, xx boundingBox.height, to_raylib_color(config.color));
                }
            }
            case .BORDER; {
                config := renderCommand.config.borderElementConfig;
                // Left border
                if (config.left.width > 0) {
                    R.DrawRectangle(round(boundingBox.x), round(boundingBox.y + config.cornerRadius.topLeft), cast(s32)config.left.width, round(boundingBox.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft), to_raylib_color(config.left.color));
                }
                // Right border
                if (config.right.width > 0) {
                    R.DrawRectangle(round(boundingBox.x + boundingBox.width - config.right.width), round(boundingBox.y + config.cornerRadius.topRight), cast(s32)config.right.width, round(boundingBox.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight), to_raylib_color(config.right.color));
                }
                // Top border
                if (config.top.width > 0) {
                    R.DrawRectangle(round(boundingBox.x + config.cornerRadius.topLeft), round(boundingBox.y), round(boundingBox.width - config.cornerRadius.topLeft - config.cornerRadius.topRight), cast(s32)config.top.width, to_raylib_color(config.top.color));
                }
                // Bottom border
                if (config.bottom.width > 0) {
                    R.DrawRectangle(round(boundingBox.x + config.cornerRadius.bottomLeft), round(boundingBox.y + boundingBox.height - config.bottom.width), round(boundingBox.width - config.cornerRadius.bottomLeft - config.cornerRadius.bottomRight), cast(s32)config.bottom.width, to_raylib_color(config.bottom.color));
                }
                if (config.cornerRadius.topLeft > 0) {
                    R.DrawRing(.{ xx round(boundingBox.x + config.cornerRadius.topLeft), xx round(boundingBox.y + config.cornerRadius.topLeft) }, xx round(config.cornerRadius.topLeft - config.top.width), config.cornerRadius.topLeft, 180, 270, 10, to_raylib_color(config.top.color));
                }
                if (config.cornerRadius.topRight > 0) {
                    R.DrawRing(.{ xx round(boundingBox.x + boundingBox.width - config.cornerRadius.topRight), xx round(boundingBox.y + config.cornerRadius.topRight) }, xx round(config.cornerRadius.topRight - config.top.width), config.cornerRadius.topRight, 270, 360, 10, to_raylib_color(config.top.color));
                }
                if (config.cornerRadius.bottomLeft > 0) {
                    R.DrawRing(.{ xx round(boundingBox.x + config.cornerRadius.bottomLeft), xx round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomLeft) }, xx round(config.cornerRadius.bottomLeft - config.top.width), config.cornerRadius.bottomLeft, 90, 180, 10, to_raylib_color(config.bottom.color));
                }
                if (config.cornerRadius.bottomRight > 0) {
                    R.DrawRing(.{ xx round(boundingBox.x + boundingBox.width - config.cornerRadius.bottomRight), xx round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomRight) }, xx round(config.cornerRadius.bottomRight - config.bottom.width), config.cornerRadius.bottomRight, 0.1, 90, 10, to_raylib_color(config.bottom.color));
                }
            }
            case .CUSTOM; #through;
            case .NONE; #through;
            case; assert(false, "Error: unhandled render command.");
        }
    }
    
    // Raylib_Render(render_commands);
    R.EndDrawing();
}
