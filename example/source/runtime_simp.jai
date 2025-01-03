RUNTIME_SIMP :: Runtime.{ simp_start, simp_stop, simp_update, simp_render };

#scope_file
Simp  :: #import "Simp";
Input :: #import "Input";

simp_window   : Window_Creation.Window_Type;
simp_textures : [#run type_info(type_of(shared_state.images)).members.count]Simp.Texture;
simp_fonts    : Hash_Table.Table(u32, *Simp.Dynamic_Font);
simp_scissors : [..]struct { start, end: Math.Vector2; };

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

simp_stop :: () {
    #if OS == .WINDOWS {
        Windows.DestroyWindow(simp_window);
        Simp.the_hdc_for_pixel_format_cloning = null;
    } else {
        #assert(false, "TODO: contribute a destroy_window to modules/Window_Creation that implements other OSes");
    }
    
    // this is a very janky way of turning Simp
    // off in a way that I can just call simp_start()
    // and have it "just work"
    
    // simp_runtime globals
    Hash_Table.table_reset(*simp_fonts);
    array_reset(*simp_scissors);
    for * simp_textures Initialize(it);
    
    // simp module globals and context
    Initialize(*Simp.the_gl_context);
    array_reset(*Simp.window_infos);
    free(context.simp);
    context.simp = null;
    
    // simp module globals in font.jai
    Initialize(*Simp.ft_library);
    Simp.fonts_initted = false;
    Simp.page_size_x   = 2048;
    Simp.page_size_y   = 1024;
    array_reset(*Simp.loaded_file_fonts);
    array_reset(*Simp.loaded_memory_fonts);
    array_reset(*Simp.font_pages);
    array_reset(*Simp.dynamic_fonts);
    Pool.release(*Simp.glyph_and_line_pool);
    Initialize(*Simp.glyph_and_line_pool);
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
            case .SPACEBAR;          requested_next_runtime = true;
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
    push_context,defer_pop main_thread_context;
    
    array_reset_keeping_memory(*simp_scissors);
    
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
            else Simp.set_scissor(0, 0, xx shared_state.window_width, xx shared_state.window_height);
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
    Simp.swap_buffers(simp_window);
}

get_font :: (id: u16, _size: u16) -> *Simp.Dynamic_Font {
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

    return text_size;
}