#load "common.jai";
// #load "layout.jai";

Library :: struct {
    handle: *void;
    using procedures: Layout_Library_Procedures;
}

my_window: Window_Creation.Window_Type;
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
    measure_text = simp_measure_text,
    render = simp_render,
};
main :: () {
    using state;
    set_working_directory(String.path_strip_filename(System.get_path_of_running_executable()));
    main_thread_context = *context;
    
    #if OS == .WINDOWS {
        Windows.SetProcessDPIAware();
        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }
    
    WANTED_MSAA :: 8;
    // On Linux, we need to pass the MSAA value to create_window
    my_window = Window_Creation.create_window(xx window_width, xx window_height, "A Window", wanted_msaa = WANTED_MSAA);

    // On other operating systems, the MSAA value needs to be passed to *_create_context, so we
    // need to have an extra step here if you want MSAA.
    msaa := Simp.prepare_window(my_window, wanted_msaa = WANTED_MSAA);
    log("Wanted MSAA: %\nChosen MSAA: %", WANTED_MSAA, msaa);

    // Actual render size in pixels can be different from the window dimensions we specified above (for example on high-resolution displays on macOS/iOS).
    window_width, window_height = xx Simp.get_render_dimensions(my_window);
    Simp.set_render_target(my_window, .LEFT_HANDED);
    
    
    layout_library := load_library(.{});
    assert(xx layout_library.handle);
    assert(xx layout_library.layout_init);
    assert(xx layout_library.layout_update);
    assert(xx layout_library.layout_get_clay_state);
    
    for type_info(type_of(state.images)).members {
        assert(it.type == type_info(State.Image));
        image := ((cast(*State.Image)*state.images) + it_index);
        ok := Simp.texture_load_from_file(*image.data, image.path);
        assert(ok);
    }
    
    // id: u16;
    // image_syntax = load_image(id, "../resources/declarative.png"); id += 1;
    // image_debug0 = load_image(id, "../resources/debugger.png");    id += 1;
    // image_check1 = load_image(id, "../resources/check_1.png");     id += 1;
    // image_check2 = load_image(id, "../resources/check_2.png");     id += 1;
    // image_check3 = load_image(id, "../resources/check_3.png");     id += 1;
    // image_check4 = load_image(id, "../resources/check_4.png");     id += 1;
    // image_check5 = load_image(id, "../resources/check_5.png");     id += 1;
    
    quit := false;
    while !quit {
        reset_temporary_storage();
        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.

            if it.window == my_window {
                should_reinit := (it.width != xx window_width) || (it.height != xx window_height);

                window_width  = xx it.width;
                window_height = xx it.height;

                // if should_reinit my_init_fonts();  // Resize the font for the new window size.
            }
        }

        for Input.events_this_frame {
            if it.type == .QUIT then quit = true;

            if it.type == {
            case .KEYBOARD; {
                if it.key_pressed && it.key_code == .ESCAPE {
                    quit = true;
                }
                
                if it.key_code == .MOUSE_BUTTON_LEFT
                then left_mouse_down = xx it.key_pressed;
                
                if it.key_code == #char "D"
                then is_d_key_pressed = xx it.key_pressed;
            }
            case .MOUSE_WHEEL; mouse_wheel_delta.y = xx it.wheel_delta / cast(float) it.typical_wheel_delta;
            }
        }
        
        {
            x, y, ok := Window_Creation.get_mouse_pointer_position();
            if ok then mouse_position = .{xx x, xx y};
        }
        
        mouse_wheel_delta.y *= 0.9;
        array_reset_keeping_memory(*simp_scissors);
        
        layout_library.layout_update(*state);
        new_library := load_library(layout_library);
        if   new_library.handle
        then layout_library = new_library;
    }
    
}

using Basic     :: #import "Basic";
Compiler        :: #import "Compiler";
Program_Print   :: #import "Program_Print";
Math            :: #import "Math";
File            :: #import "File";
Hash            :: #import "Hash";
Hash_Table      :: #import "Hash_Table";
String          :: #import "String";
System          :: #import "System";
Window_Creation :: #import "Window_Creation";
Windows         :: #import "Windows";
Simp            :: #import "Simp";
Input           :: #import "Input";
File_Utilities  :: #import "File_Utilities";
Clay            :: #import,file "../../module.jai"(link_implementation=false);

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



simp_fonts    : Hash_Table.Table(u32, *Simp.Dynamic_Font);
simp_images   : [10]Simp.Texture;
simp_scissors : [..]struct { start, end: Math.Vector2; };

get_font :: (id: u16, size: u16) -> *Simp.Dynamic_Font {
    using Hash_Table;
    A :: struct { a, b: u16; }
    foo := A.{id, size};
    table_id := (cast(*u32) *foo).*;
    
    font, found := table_find(*simp_fonts, table_id);
    if found return font;
    
    path := FONT_PATHS[id];
    font_data, ok := File.read_entire_file(path,, temp);
    assert(ok);
    
    font = Simp.get_font_at_size(cast([]u8)font_data, size);
    assert(xx font);
    
    table_add(*simp_fonts, table_id, font);
    return font;
}

load_image :: (id: u16, path: string) -> *Simp.Texture {
    ok := Simp.texture_load_from_file(*simp_images[id], path);
    assert(ok);
    return *simp_images[id];
}

main_thread_context: *Context;
simp_measure_text :: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call {
    push_context,defer_pop main_thread_context;
    
    text_size := Clay.Dimensions.{0, 0};

    max_text_width  : float = 0;
    line_text_width : float = 0;

    text_height := cast(float)config.fontSize;
    font_to_use := get_font(config.fontId, config.fontSize);
    
    // TODO: i think i have to iterate unicode code points here....
    for i: 0..text.length-1 {
        if (text.chars[i] == #char "\n") {
            max_text_width = ifx max_text_width > line_text_width then max_text_width else line_text_width;
            line_text_width = 0;
            continue;
        }
        glyph := Simp.find_or_create_glyph(font_to_use, text.chars[i]);
        if (glyph.advance != 0) {
            line_text_width += cast(float)glyph.advance;
        } else {
            line_text_width += (glyph.width + cast(float)glyph.offset_x);
        }
    }
    

    max_text_width = ifx max_text_width > line_text_width then max_text_width else line_text_width;

    text_size.width = max_text_width;
    text_size.height = text_height;
    
    // s := string.{xx text.length, xx text.chars };
    // log("% <= `%`", text_size, s);

    return text_size;
}

simp_render :: (commands: *Clay.RenderCommandArray) {
    push_context,defer_pop main_thread_context;
    
    // defer assert(false);
    
    to_math_color :: inline (using color: Clay.Color) -> Math.Vector4 {
        return .{ r / 255.0, g / 255.0, b / 255.0, a / 255.0 };
    }
    for j: 0..commands.length-1 {
        command := commands.internalArray[j];
        bound := command.boundingBox;
        if #complete command.commandType == {
        case .TEXT; {
            Simp.set_shader_for_text();
            text := string.{xx command.text.length, xx command.text.chars };
            font := get_font(command.config.textElementConfig.fontId, command.config.textElementConfig.fontSize);
            Simp.draw_text(font, xx bound.x, xx bound.y+font.character_height, text, to_math_color(command.config.textElementConfig.textColor));
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
        case .SCISSOR_START; {
            scissor := type_of(simp_scissors.data.*).{ .{bound.x, bound.y}, .{bound.x+bound.width, bound.y+bound.height} };
            array_add(*simp_scissors, scissor);
            Simp.set_scissor(scissor.start, scissor.end);
        }
        case .SCISSOR_END; {
            pop(*simp_scissors);
            if simp_scissors 
            then Simp.set_scissor(simp_scissors[simp_scissors.count-1].start, simp_scissors[simp_scissors.count-1].end);
            else Simp.set_scissor(0, 0, xx state.window_width, xx state.window_height);
        }
        case .RECTANGLE; {
            config := command.config.rectangleElementConfig;
            Simp.set_shader_for_color(true);
            if (config.cornerRadius.topLeft > 0) {
                // TODO: steal rounded rectangle stuff from GetRect
                Simp.immediate_quad(
                    bound.x, bound.y,
                    bound.x + bound.width,
                    bound.y + bound.height,
                    to_math_color(config.color)
                );
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
            // TODO: steal rounded rectangle code from getrect
            // log("border");
        }
        case .CUSTOM; #through;
        case .NONE; #through;
        case; assert(false, "Error: unhandled render command.");
        }
        
    }
    
    Simp.immediate_flush();
    Simp.swap_buffers(my_window);
}
