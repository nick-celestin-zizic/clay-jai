#load "common.jai";

shared_state: State; // state that we pass to the layout library
main :: () {
    set_working_directory(String.path_strip_filename(System.get_path_of_running_executable()));
    shared_state.handle_error = .{
        (using error: Clay.ErrorData) -> void #c_call {
            push_context,defer_pop cast(*#Context) userData;
            push_context,defer_pop Remap_Context.remap_context();
            assert(false, "CLAY ERROR %: %", errorType, string.{xx errorText.length, xx errorText.chars});
        },
        xx *context
    };
    
    // Windows is very bad at thread-switching by default unless you do this. Sad.
    #if OS == .WINDOWS {
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }
    
    simp_start();
    
    layout_library: Library;
    while !shared_state.should_quit {
        reset_temporary_storage();
        
        new_library := load_library(layout_library);
        if   new_library.handle
        then layout_library = new_library;
        
        simp_update();
        render_commands := layout_library.update(*shared_state);
        simp_render(*render_commands);
    }
}

Library :: struct {
    handle: *void;
    update: Layout_Update_Procedure;
}

load_library :: (old_library: Library) -> Library {
    using File_Utilities; using File;
    if !file_exists(LAYOUT_LIBRARY_FILES[0].new) {
        if old_library.handle {
            return .{}; // No new library, do nothing!
        } else {
            // We need a library, but do not have one loaded!
            // Maybe there is an old library we can rename and use instead?
            if file_exists(LAYOUT_LIBRARY_FILES[0].old) {
                for LAYOUT_LIBRARY_FILES
                    atomic_file_replace_or_just_rename_if_destination_file_does_not_exist(it.old, it.new);
            } else {
                log_error("could not find any layout dll!");
                return .{};
            }
        }
    }
    
    // we do this to check that dll is ready to be opened
    // and not still being used by the compiler to generate it
    dummy_library := dynamic_library_load("layout");
    if !dummy_library return .{};
    
    if old_library.handle then dynamic_library_unload(old_library.handle);
    dynamic_library_unload(dummy_library);
    
    for LAYOUT_LIBRARY_FILES 
        atomic_file_replace_or_just_rename_if_destination_file_does_not_exist(it.new, it.old);
    
    using new_library: Library = ---;
    
    handle = dynamic_library_load("layout-old");
    if !handle {
        value, desc := System.get_error_value_and_string();
        log_error("Could not load layout library: (%) %", value, desc);
        return .{};
    }
    
    update = dynamic_library_get_procedure(handle, "update");
    if !update {
        value, desc := System.get_error_value_and_string();
        dynamic_library_unload(handle);
        log_error("Could not load library update procedure: (%) %", value, desc);
        return .{};
    }
    
    return new_library;
}


// this is kind of dumb, but we want to rename all of the files associated with the layout library
#if OS == .WINDOWS {
    Windows :: #import "Windows";
    LAYOUT_LIBRARY_FILES :: struct {old, new: string;}.[
        .{"layout-old.dll", "layout.dll"},
        .{"layout-old.exp", "layout.exp"},
        .{"layout-old.lib", "layout.lib"},
        .{"layout-old.pdb", "layout.pdb"},
    ];
    dynamic_library_load :: inline (basename: string) -> *void {
        return Windows.LoadLibraryA(tprint("%.dll\0", basename).data);
    }
    dynamic_library_get_procedure :: inline (library: *void, name: string) -> *void {
        return Windows.GetProcAddress(library, temp_c_string(name));
    }
    dynamic_library_unload :: Windows.FreeLibrary;
} else {
    LAYOUT_LIBRARY_FILES :: struct {old, new: string;}.[
        .{"layout-old.so", "layout.so"},
    ];
    Posix :: #import "Posix";
    dynamic_library_load :: inline (basename: string) -> *void {
        return Posix.dlopen(tprint("%.so\0", basename).data, Posix.RTLD_LOCAL);
    }
    dynamic_library_get_procedure :: inline (library: *void, name: string) -> *void {
        return Posix.dlsym(library, temp_c_string(name));
    }
    dynamic_library_unload :: Posix.dlclose;
}


using Basic     :: #import "Basic";
Compiler        :: #import "Compiler";
Program_Print   :: #import "Program_Print";
Math            :: #import "Math";
File            :: #import "File";
Hash            :: #import "Hash";
Hash_Table      :: #import "Hash_Table";
String          :: #import "String";
Pool            :: #import "Pool";
System          :: #import "System";
File_Utilities  :: #import "File_Utilities";
Window_Creation :: #import "Window_Creation";
Input           :: #import "Input";
Simp            :: #import "Simp";
Remap_Context   :: #import "Remap_Context";
Clay            :: #import,file "../../module.jai";

simp_start :: () {
    using shared_state;
    
    WANTED_MSAA :: 8;
    simp_window = Window_Creation.create_window(xx window_width, xx window_height, "A Window", wanted_msaa = WANTED_MSAA);
    Simp.prepare_window(simp_window, wanted_msaa = WANTED_MSAA);
    window_width, window_height = xx Simp.get_render_dimensions(simp_window);
    Simp.set_render_target(simp_window, .LEFT_HANDED);
    measure_text = simp_measure_text;
    
    for type_info(type_of(images)).members {
        assert(it.type == type_info(*void));
        assert(it.notes.count == 1);
        
        ok := Simp.texture_load_from_file(*simp_textures[it_index], it.notes[0]);
        assert(ok);
        // cast(cast(*images, *u8) + it.offset_in_bytes, **void).* = *simp_textures[it_index]
        (cast(**void) ((cast(*u8)*images) + it.offset_in_bytes)).* = *simp_textures[it_index];
    }
}

simp_update :: () {
    using shared_state;
    
    Input.update_window_events();

    for Input.get_window_resizes() {
        Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.
        if it.window == simp_window {
            window_width  = xx it.width;
            window_height = xx it.height;
        }
    }

    for Input.events_this_frame {
        if it.type == .QUIT then should_quit = true;

        if it.type == {
        case .KEYBOARD; if it.key_code == {
            case .ESCAPE;            if it.key_pressed then should_quit = true;
            case .MOUSE_BUTTON_LEFT; left_mouse_down = xx it.key_pressed;
            case #char "D";          if it.key_pressed then show_debugger = !show_debugger;
        }
        case .MOUSE_WHEEL; mouse_wheel_delta.y = xx it.wheel_delta / cast(float) it.typical_wheel_delta;
        }
    }
    
    {
        x, y, ok := Window_Creation.get_mouse_pointer_position();
        if ok then mouse_position = .{xx x, xx y};
    }
    
    mouse_wheel_delta.y *= 0.9;
}

simp_render :: (commands: *Clay.RenderCommandArray) {
    array_reset_keeping_memory(*simp_scissors);
    
    to_math_color :: inline (using color: Clay.Color) -> Math.Vector4 { return .{ r / 255.0, g / 255.0, b / 255.0, a / 255.0 }; }
    round :: inline (value: float) -> int { return xx (value + 0.5); }
    push_scissor :: (bound: Clay.BoundingBox) {
        scissor := type_of(simp_scissors.data.*).{ .{bound.x, bound.y}, .{bound.x+bound.width, bound.y+bound.height} };
        array_add(*simp_scissors, scissor);
        Simp.set_scissor(scissor.start, scissor.end);
    }
    pop_scissor :: () {
        pop(*simp_scissors);
        if simp_scissors 
        then Simp.set_scissor(simp_scissors[simp_scissors.count-1].start, simp_scissors[simp_scissors.count-1].end);
        else Simp.set_scissor(0, 0, xx shared_state.window_width, xx shared_state.window_height);
    }
    
    for j: 0..commands.length-1 {
        command := commands.internalArray[j];
        bound := command.boundingBox;
        if #complete command.commandType == {
        case .TEXT; {
            config := command.config.textElementConfig;
            text := string.{xx command.text.length, xx command.text.chars };
            font := simp_get_font(config.fontId, config.fontSize);
            
            text_width := cast(float) Simp.prepare_text(font, text);
            if text_width > bound.width        then push_scissor(bound);
            defer if text_width > bound.width  then pop_scissor();
            
            text_x, text_y := getrect_text_origin(font, bound, text_width);
            Simp.draw_prepared_text(font, xx text_x, xx round(text_y + bound.height/2), to_math_color(config.textColor));
        }
        case .IMAGE; {
            texture := (cast(*Simp.Texture)command.config.imageElementConfig.imageData);
            Simp.set_shader_for_images(texture);
            Simp.immediate_quad(
                bound.x, bound.y,
                bound.x + bound.width,
                bound.y + bound.height,
                .{1, 1, 1, 1},
            );
        }
        case .SCISSOR_START; push_scissor(bound);
        case .SCISSOR_END; pop_scissor();
        case .RECTANGLE; {
            config := command.config.rectangleElementConfig;
            Simp.set_shader_for_color(true);
            if (config.cornerRadius.topLeft > 0) {
                // TODO: this is a hack and assumes all four border regions are the same
                // if the aren't we are going to have to do a lot more rendering stuff :(
                pixels, actual_roundness := getrect_rounded_rectangle(bound, .{
                    roundedness_type = .ABSOLUTE_FROM_THEME_FIELD,
                    roundedness = config.cornerRadius.topLeft,
                    // pixels_per_edge_segment = 1000.0,
                    frame_thickness_type = .ABSOLUTE_FROM_THEME_FIELD,
                    frame_thickness = 0,
                    rounding_flags = .NORTHEAST | .NORTHWEST | .SOUTHWEST | .SOUTHEAST,
                }, to_math_color(config.color), to_math_color(config.color));
            } else {
                Simp.immediate_quad(
                    bound.x, bound.y,
                    bound.x + bound.width,
                    bound.y + bound.height,
                    to_math_color(config.color)
                );
            }
        }
        case .BORDER; {
            config := command.config.borderElementConfig;
            
            // TODO: this is a hack and assumes all four border regions are the same
            // if the aren't we are going to have to do a lot more rendering stuff :(
            pixels, actual_roundness := getrect_rounded_rectangle(bound, .{
                roundedness_type = .ABSOLUTE_FROM_THEME_FIELD,
                roundedness = config.cornerRadius.topLeft,
                // pixels_per_edge_segment = 1000.0,
                frame_thickness_type = .ABSOLUTE_FROM_THEME_FIELD,
                frame_thickness = xx config.left.width,
                rounding_flags = .NORTHEAST | .NORTHWEST | .SOUTHWEST | .SOUTHEAST,
            }, .{}, to_math_color(config.left.color));
            // BorderData :: struct {
            //     width: u32;
            //     color: Color;
            // }
            
            // BorderElementConfig :: struct {
            //     left:            BorderData;
            //     right:           BorderData;
            //     top:             BorderData;
            //     bottom:          BorderData;
            //     betweenChildren: BorderData;
            //     cornerRadius:    CornerRadius;
            // }
            // TODO: steal rounded rectangle code from getrect
            // log("border");
        }
        case .CUSTOM; #through;
        case .NONE; #through;
        case; assert(false, "Error: unhandled render command.");
        }
        
    }
    // assert(false);
    Simp.immediate_flush();
    Simp.swap_buffers(simp_window);
}

simp_window   : Window_Creation.Window_Type;
simp_textures : [#run type_info(type_of(shared_state.images)).members.count]Simp.Texture;
simp_fonts    : Hash_Table.Table(u32, *Simp.Dynamic_Font);
simp_scissors : [..]struct { start, end: Math.Vector2; };

simp_get_font :: (id: u16, _size: u16) -> *Simp.Dynamic_Font {
    using Hash_Table;
    size := Basic.max(_size, 1);
    
    A :: struct { a, b: u16; }
    foo := A.{id, size};
    table_id := cast(*u32, *foo).*;
    font, found := table_find(*simp_fonts, table_id);
    if found return font;
    
    // COMPILER_BUG: both of these should evaluate to the same thing but the first one crashes in the .X64 backend!
    // path := ((cast(*string)type_info(State.Font_Paths).constant_storage.data) + id).*;
    path := cast(*string, type_info(State.Font_Paths).constant_storage.data + (id*size_of(string))).*;
    font_data, ok := File.read_entire_file(path,, temp);
    assert(ok);
    
    font = Simp.get_font_at_size(cast([]u8, font_data), size);
    assert(xx font);
    
    table_add(*simp_fonts, table_id, font);
    return font;
}

simp_measure_text :: (text: Clay.StringSlice, config: *Clay.TextElementConfig, user_data: u64) -> Clay.Dimensions #c_call {
    push_context,defer_pop cast(*#Context) user_data;
    push_context,defer_pop Remap_Context.remap_context();
    
    text_size := Clay.Dimensions.{0, 0};

    max_text_width  : float = 0;
    line_text_width : float = 0;

    text_height := cast(float)config.fontSize;
    font_to_use := simp_get_font(config.fontId, config.fontSize);
    
    // TODO: i think i have to iterate unicode code points here....
    for i: 0..text.length-1 {
        if (text.chars[i] == #char "\n") {
            max_text_width = ifx max_text_width > line_text_width then max_text_width else line_text_width;
            line_text_width = 0;
            continue;
        }
        
        glyph := Simp.find_or_create_glyph(font_to_use, text.chars[i]);
        // diff := cast(int) glyph.height - cast(int) glyph.ascent;
        // height := cast(float)(cast(int) glyph.height + cast(int) glyph.offset_y);
        // log("'%': %", string.{1, *text.chars[i]}, glyph.height - cast(float)glyph.offset_y);
        assert(glyph.offset_y == glyph.ascent);
        text_height = max(text_height, (cast(float)config.fontSize) + (glyph.height - cast(float)glyph.offset_y));//cast(float)config.fontSize + (glyph.height - cast(float)glyph.offset_y));
        // assert(glyph.y0 <= glyph.ascent, "'%': %", string.{1, *text.chars[i]}, glyph.*);
        // if glyph.y0 {
        //     log("'%': %", string.{1, *text.chars[i]}, glyph.*);
        // }
        // if glyph.y0 && (glyph.offset_y != glyph.ascent) {
        //     logx(string.{1, *text.chars[i]});
        //     logx(glyph.*);
        //     assert(false);
        // }
        
        if (glyph.advance != 0) {
            line_text_width += cast(float)glyph.advance;
        } else {
            line_text_width += (glyph.width + cast(float)glyph.offset_x);
        }
    }
    // log("\n\n");
    max_text_width = ifx max_text_width > line_text_width then max_text_width else line_text_width;

    text_size.width = max_text_width;
    text_size.height = text_height * 1.075; // :JankyFontStuff

    return text_size;
}


// this stuff is taken from GetRect


getrect_default_text_baseline :: (font: *Simp.Dynamic_Font, height: float) -> float {
    assert(xx font);
    // Just a heuristic to try to line up fonts, kind of.
    // Could probably be better.
    active_height := font.character_height * 0.55;
    pad := height - active_height;
    return Math.floor(pad * 0.5);
}

getrect_text_origin :: (font: *Simp.Dynamic_Font, r: Clay.BoundingBox, text_width: float) -> (x: float, y: float) {
    if !font return 0, 0;  // :NullFont

    // theme.font is ignored, so that people can pass in a substituted font.
    // However, other properties like alignment, baseline, etc are used here.

    x := r.x;

    // y := text_baseline(font, y, y+r.h);
    vert := getrect_default_text_baseline(font, r.height);

    y := r.y + vert;

    // Due to atlassed texture rendering, we draw text at integer coordinates currently.
    // If we wish to change this, don't round! (Or round to whatever subpixel resolution
    // we generate atlas alternatives at. etc.)
    x = Math.floor(x + .5);
    y = Math.floor(y + .5);
    return x, y;
}

getrect_global_rounding_radius_in_pixels := 9.0;
getrect_global_frame_thickness_in_pixels := 4.0;
getrect_global_divider_thickness_in_pixels := 4.0;
getrect_global_initial_divider_position_in_pixels := 32.0;
getrect_global_slider_nub_thickness_in_pixels := 32.0;


GetRect_Size_Computation :: enum u8 {   // Defaults to RELATIVE_TO_HEIGHT.
    RELATIVE_TO_HEIGHT        :: 0;
    RELATIVE_TO_WIDTH         :: 1;
    ABSOLUTE_FROM_THEME_FIELD :: 2;
    ABSOLUTE_FROM_GLOBAL      :: 3;
};

GetRect_Rectangle_Shape :: struct {
    roundedness_type: GetRect_Size_Computation;
    
    roundedness := .18;   // If absolute, this is the number of pixels. If relative, set this to a value in [0, 1]: 0 == totally squared off; 1 == capsule along the width or height (though this will be clamped to the shortest side).
    
    pixels_per_edge_segment  := 10.0;  // How many triangles we generate for the curves, based on the length of the arc.

    frame_thickness_type: GetRect_Size_Computation;
    frame_thickness := .02;            // By default, .02 * rect.h. Set to a value <= 0 for no frame.

    Rounding_Flags :: enum_flags u32 {
        NORTHEAST :: 0x1;
        NORTHWEST :: 0x2;
        SOUTHWEST :: 0x4;
        SOUTHEAST :: 0x8;

        // Combo flags, for convenience:
        EAST  :: NORTHEAST | SOUTHEAST;
        WEST  :: NORTHWEST | SOUTHWEST;
        SOUTH :: SOUTHEAST | SOUTHWEST;
        NORTH :: NORTHEAST | NORTHWEST;

        ALL :: EAST | WEST;
    }

    rounding_flags := Rounding_Flags.NORTHEAST | .NORTHWEST | .SOUTHWEST | .SOUTHEAST;
}

getrect_to_vec3 :: (v2: Math.Vector2) -> Math.Vector3 {
    result: Math.Vector3;
    result.xy = v2;

    return result;
}

getrect_get_quad :: (using r: Clay.BoundingBox, snap_coordinates := false) -> (p0: Math.Vector2, p1: Math.Vector2, p2: Math.Vector2, p3: Math.Vector2) {
    using Math;
    
    p0 := xy(x      , y       );
    p1 := xy(x+width, y       );
    p2 := xy(x+width, y+height);
    p3 := xy(x      , y+height);

    if snap_coordinates {
        p0.x = floor(p0.x + .5);
        p0.y = floor(p0.y + .5);
        p1.x = floor(p1.x + .5);
        p1.y = floor(p1.y + .5);
        p2.x = floor(p2.x + .5);
        p2.y = floor(p2.y + .5);
        p3.x = floor(p3.x + .5);
        p3.y = floor(p3.y + .5);
    }

    return p0, p1, p2, p3;
}

getrect_get_roundedness_for_rect :: (r: Clay.BoundingBox, type: GetRect_Size_Computation, roundedness: float, global_value: float, limit := 0.5) -> float {
    using Math;
    
    radius_pixels := getrect_get_float_parameter(r, type, roundedness, global_value);

    shortest := min(r.width, r.height);
    Clamp(*radius_pixels, 0, shortest*limit);
    radius_pixels = floor(radius_pixels + .5);

    return radius_pixels;
}

getrect_get_float_parameter :: (r: Clay.BoundingBox, type: GetRect_Size_Computation, local: float, global: float, override: float = Math.FLOAT32_INFINITY) -> float {
    using Math;
    
    if override != FLOAT32_INFINITY {
        local  = override;
        global = override;
    }

    result: float;
    if #complete type == {
      case .RELATIVE_TO_HEIGHT;
        result = r.height * local;
      case .RELATIVE_TO_WIDTH;
        result = r.width * local;
      case .ABSOLUTE_FROM_THEME_FIELD;
        result = local;
      case; assert(false); #through;
      case .ABSOLUTE_FROM_GLOBAL;
        result = global;
    }

    return result;
}

getrect_rounded_rectangle :: (r: Clay.BoundingBox, shape: GetRect_Rectangle_Shape, color: Math.Vector4, frame_color: Math.Vector4, frame_thickness_override := Math.FLOAT32_INFINITY /*, return_points := false*/) -> (frame_pixels: float, actual_roundedness: float/*, points: [] Rounded_Rectangle_Point*/) {
/*
    points: [..] Rounded_Rectangle_Point;  // We only fill this if return_points == true.
    points.allocator = temp;
*/
    
    using Math;
    using Basic;
    
    radius_pixels := getrect_get_roundedness_for_rect(r, shape.roundedness_type, shape.roundedness, getrect_global_rounding_radius_in_pixels, .5);

    Simp.set_shader_for_color(true);
    frame_pixels := getrect_get_float_parameter(r, shape.frame_thickness_type, shape.frame_thickness, getrect_global_frame_thickness_in_pixels);
    shortest := min(r.width, r.height);
    Clamp(*frame_pixels, 0, shortest*.5);

    if (frame_pixels > 0) && (frame_pixels < 1) frame_pixels = 1;  // Give them at least 1 pixel if they are asking for a frame...
    frame_pixels = floor(frame_pixels + .5);

    if !frame_color.w  frame_pixels = 0;  // Kill drawing of the frame.
    if (color.w == 0) && (frame_pixels == 0) return 0, 0;  // Early out and do not draw!

    flags := shape.rounding_flags;
    if radius_pixels == 0 {
        flags = 0;  // Just don't do corners, but, go do the rest of the code, because we want to draw frames etc and don't want to dupe that code here.
    }

    extra_w := radius_pixels;
    extra_h := radius_pixels;

    // i0..i3: inside  vertices, of the interior quad.
    // o0..o7: outside vertices, that protrude out like flaps.
    // f0..f7: frame   vertices, recessed by frame_pixels from the outside vertices.

    p0, p1, p2, p3 := getrect_get_quad(r, snap_coordinates=true);

    i0 := p0 + xy( extra_w,  extra_h);
    i1 := p1 + xy(-extra_w,  extra_h);
    i2 := p2 + xy(-extra_w, -extra_h);
    i3 := p3 + xy( extra_w, -extra_h);

    o0 := i0;
    o1 := i1;
    o2 := i1;
    o3 := i2;
    o4 := i2;
    o5 := i3;
    o6 := i3;
    o7 := i0;

    o0.y = p0.y;
    o1.y = p0.y;
    o2.x = p1.x;
    o3.x = p1.x;
    o4.y = p2.y;
    o5.y = p2.y;
    o6.x = p0.x;
    o7.x = p0.x;

    if color.w {
        Simp.immediate_quad(o0, o1, i1, i0, color);
        Simp.immediate_quad(i1, o2, o3, i2, color);
        Simp.immediate_quad(i3, i2, o4, o5, color);
        Simp.immediate_quad(o7, i0, i3, o6, color);
        Simp.immediate_quad(i0, i1, i2, i3, color);
    }

    f0, f1, f2, f3, f4, f5, f6, f7: Math.Vector2 = ---;

    if frame_pixels {
        f0 = o0;
        f1 = o1;
        f2 = o2;
        f3 = o3;
        f4 = o4;
        f5 = o5;
        f6 = o6;
        f7 = o7;

        f0.y += frame_pixels;

        f1.y += frame_pixels;
        f2.x -= frame_pixels;
        f3.x -= frame_pixels;
        f4.y -= frame_pixels;
        f5.y -= frame_pixels;
        f6.x += frame_pixels;
        f7.x += frame_pixels;

        Simp.immediate_quad(o0, o1, f1, f0, frame_color);
        Simp.immediate_quad(f2, o2, o3, f3, frame_color);
        Simp.immediate_quad(f5, f4, o4, o5, frame_color);
        Simp.immediate_quad(o7, f7, f6, o6, frame_color);
    }

    denom := shape.pixels_per_edge_segment;
    if denom <= 0 {
        denom = 4.0;  // Fail over to some value. Who knows if this is a good idea.
    }

    num_segments := cast(s32) floor(TAU * radius_pixels / denom + .5);
    if num_segments < 1  num_segments = 1;

    dtheta := TAU * .25 * (1 / cast(float) num_segments);

    // @Speed: Math.Vector3 stuff.
    i0_3 := getrect_to_vec3(i0);
    i1_3 := getrect_to_vec3(i1);
    i2_3 := getrect_to_vec3(i2);
    i3_3 := getrect_to_vec3(i3);

    for i: 0..num_segments - 1 {
        // @Speed: Record old theta and re-use.
        theta0 := dtheta * i;
        theta1 := theta0 + dtheta;

        ct0 := cos(theta0);
        ct1 := cos(theta1);
        st0 := sin(theta0);
        st1 := sin(theta1);

        w0 := xyz(ct0*radius_pixels, st0*radius_pixels, 0);
        w1 := xyz(ct1*radius_pixels, st1*radius_pixels, 0);

        v0 := xy(ct0*(radius_pixels-frame_pixels), st0*(radius_pixels-frame_pixels));
        v1 := xy(ct1*(radius_pixels-frame_pixels), st1*(radius_pixels-frame_pixels));

        q0 := i2_3 + w0;
        q1 := i2_3 + w1;
        if flags & .NORTHEAST  {
            Simp.immediate_triangle(i2_3, i2_3 + w0, i2_3 + w1, color, color, color);
            if frame_pixels  Simp.immediate_quad(i2 + v1, i2 + v0, i2 + w0.xy, i2 + w1.xy, frame_color);
        }

        if flags & .SOUTHWEST  {
            Simp.immediate_triangle(i0_3, i0_3 - w0, i0_3 - w1, color, color, color);
            if frame_pixels  Simp.immediate_quad(i0 - v1, i0 - v0, i0 - w0.xy, i0 - w1.xy, frame_color);
        }

        m0 := xyz(-w0.y, w0.x, 0);
        m1 := xyz(-w1.y, w1.x, 0);
        n0 := xy(-v0.y, v0.x);
        n1 := xy(-v1.y, v1.x);
        if flags & .NORTHWEST  {
            Simp.immediate_triangle(i3_3, i3_3 + m0, i3_3 + m1, color, color, color);
            if frame_pixels  Simp.immediate_quad(i3 + n1, i3 + n0, i3 + m0.xy, i3 + m1.xy, frame_color);
        }

        if flags & .SOUTHEAST  {
            Simp.immediate_triangle(i1_3, i1_3 - m0, i1_3 - m1, color, color, color);
            if frame_pixels  Simp.immediate_quad(i1 - n1, i1 - n0, i1 - m0.xy, i1 - m1.xy, frame_color);
        }
    }

    if !(flags & .NORTHEAST) {
        Simp.immediate_quad(i2, o3, p2, o4, color);

        // Our two quads are non-rectangular, so that we don't make a T junction
        // or generate unsightly alpha overlap.
        // See how much I care about you???

        if frame_pixels {
            f34 := xy(f3.x, f4.y);
            Simp.immediate_quad(f4, f34, p2, o4, frame_color);
            Simp.immediate_quad(f3, o3, p2, f34, frame_color);
        }
    }

    if !(flags & .NORTHWEST) {
        Simp.immediate_quad(o6, i3, o5, p3, color);

        if frame_pixels {
            f65 := xy(f6.x, f5.y);
            Simp.immediate_quad(f65, f5, o5, p3, frame_color);
            Simp.immediate_quad(o6, f6, f65, p3, frame_color);
        }
    }

    if !(flags & .SOUTHWEST) {
        Simp.immediate_quad(p0, o0, i0, o7, color);

        if frame_pixels {
            f70 := xy(f7.x, f0.y);
            Simp.immediate_quad(p0, f70, f7, o7, frame_color);
            Simp.immediate_quad(p0, o0, f0, f70, frame_color);
        }
    }

    if !(flags & .SOUTHEAST) {
        Simp.immediate_quad(o1, p1, o2, i1, color);

        if frame_pixels {
            f21 := xy(f2.x, f1.y);
            Simp.immediate_quad(o1, p1, f21, f1, frame_color);
            Simp.immediate_quad(f21, p1, o2, f2, frame_color);
        }
    }

    Simp.immediate_flush();

    return frame_pixels, radius_pixels;  // Sometimes used in scissoring.
}