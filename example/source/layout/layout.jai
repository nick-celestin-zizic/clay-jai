COLOR_LIGHT       :: Clay.Color.{244, 235, 230, 255};
COLOR_LIGHT_HOVER :: Clay.Color.{224, 215, 210, 255};
COLOR_RED         :: Clay.Color.{168, 66, 28, 255};
COLOR_RED_HOVER   :: Clay.Color.{148, 46, 8, 255};
COLOR_ORANGE      :: Clay.Color.{225, 138, 50, 255};
COLOR_BLUE        :: Clay.Color.{111, 173, 162, 255};

// Colors for top stripe
COLOR_TOP_BORDER_1 :: Clay.Color.{168, 66, 28, 255};
COLOR_TOP_BORDER_2 :: Clay.Color.{223, 110, 44, 255};
COLOR_TOP_BORDER_3 :: Clay.Color.{225, 138, 50, 255};
COLOR_TOP_BORDER_4 :: Clay.Color.{236, 189, 80, 255};
COLOR_TOP_BORDER_5 :: Clay.Color.{240, 213, 137, 255};

COLOR_BLOB_BORDER_1 :: Clay.Color.{168, 66, 28, 255};
COLOR_BLOB_BORDER_2 :: Clay.Color.{203, 100, 44, 255};
COLOR_BLOB_BORDER_3 :: Clay.Color.{225, 138, 50, 255};
COLOR_BLOB_BORDER_4 :: Clay.Color.{236, 159, 70, 255};
COLOR_BLOB_BORDER_5 :: Clay.Color.{240, 189, 100, 255};

// They're calling it wuhumu oriented programming!
// wu (width   units) is one percent of the width
// hu (height  units) is one percent of the height
// mu (minimum units) is wu or hu depending on which one is smaller
// use these instead of absolute screen units
k  :: 0.01;
wu :: inline (value: $T) -> T { return cast(T) (value * window_width  * k); }
hu :: inline (value: $T) -> T { return cast(T) (value * window_height * k); }
mu :: inline (value: $T) -> T { return xx ((cast(float) Basic.min(window_width, window_height)) * k * value); }

create_layout :: () {
    mobile_screen := window_width < window_height;
    
    Element(ID("OuterContainer"),
        Layout(.{ layoutDirection = .TOP_TO_BOTTOM, sizing = .{ SizingGrow(), SizingGrow() } }),
        Rectangle(.{ color = COLOR_LIGHT })
    );
        
    Element(ID("Header"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFixed(xx hu(4)) },
            childAlignment = .{ y = .CENTER },
            childGap = xx wu(1.1),
            padding = .{ xx wu(2.2), xx wu(2.2), 0, 0 }
        }),
        children = #code {
        
        header_text_config := StoreTextElementConfig(.{
            fontId    = FONT_BODY,
            fontSize  = xx hu(2),
            textColor = .{61, 26, 5, 255},
        });
        
        Text("Clay", header_text_config); 

        { Element(ID("Spacer"), Layout(.{ sizing = .{ width = SizingGrow() } }) ); }
        
        layout := Layout(.{ padding = .{ xx wu(.8), xx wu(.8), 0, 0 } });
        if !mobile_screen {
            link_button(ID("LinkDocsOuter"), "Docs", "https://github.com/nicbarker/clay/blob/main/README.md", header_text_config, layout);
            link_button(ID("LinkExamplesOuter"), "Examples", "https://github.com/nicbarker/clay/tree/main/examples", header_text_config, layout);
        }
        
        border := BorderOutsideRadius(2, COLOR_RED, 10);
        link_button(ID("DiscordLink"), "Discord", "https://github.com/nicbarker/clay/blob/main/README.md", header_text_config, layout, border);
        link_button(ID("GithubLink"), "Github", "https://github.com/nicbarker/clay", header_text_config, layout, border);
    });
    
    h, id := cast(float) hu(0.65), cast(u32) 1;
    stripe :: (color: Color) #expand {
        Element(ID("TopBorder", id), Layout(.{ sizing = .{ SizingGrow(), SizingFixed(h) }}), Rectangle(.{ color = color }) );
        id += 1;
    }
    
    stripe(COLOR_TOP_BORDER_5);
    stripe(COLOR_TOP_BORDER_4);
    stripe(COLOR_TOP_BORDER_3);
    stripe(COLOR_TOP_BORDER_2);
    stripe(COLOR_TOP_BORDER_1);
    
    outer_scroll_container := ID("OuterScrollContainer");
    Element(outer_scroll_container,
        Layout(.{ sizing = .{ SizingGrow(), SizingGrow() }, layoutDirection =  .TOP_TO_BOTTOM }),
        Scroll(.{ vertical = true }),
        Border(.{ betweenChildren = .{2, COLOR_RED} }),
        children = #code if mobile_screen {
            Basic.log_error("TODO: mobile layout");
            // LandingPageMobile();
            // FeatureBlocksMobile();
            // DeclarativeSyntaxPageMobile();
            // HighPerformancePageMobile(lerp_value);
            // RendererPageMobile();
        } else {
            landing_page_desktop();
            feature_blocks_desktop();
            declarative_syntax_page_desktop();
            high_performance_page_desktop();
            renderer_page_desktop();
            debugger_page_desktop();
        }
    );
    
    scroll_bar  := ID("ScrollBar");
    scroll_data := GetScrollContainerData(outer_scroll_container);
    scrollbar_color := Color.{225, 138, 50, 120};
    if scrollbar_data.mouse_down
    then scrollbar_color = .{225, 138, 50, 200};
    else if PointerOver(scroll_bar)
    then scrollbar_color = .{225, 138, 50, 160};
    
    scroll_height := scroll_data.scrollContainerDimensions.height - 12;
    offset := cast(float) mu(.5);
    Element(scroll_bar,
        Layout(.{
            sizing = .{ SizingFixed(xx wu(0.65)), SizingFixed((scroll_height / scroll_data.contentDimensions.height) * scroll_height)} }
        ),
        Floating(.{
            offset     = .{ x = -offset, y = -(scroll_data.scrollPosition.y / scroll_data.contentDimensions.height) * scroll_height + offset },
            zIndex     = 1,
            parentId   = outer_scroll_container.id,
            attachment = .{ element = .RIGHT_TOP, parent = .RIGHT_TOP }}
        ),
        Rectangle(.{ cornerRadius = CornerRadiusAll(5), color = scrollbar_color }),
        children = #code {}
    );
}

link_button :: (id: ElementId, text: string, link_value: string, config: *TextElementConfig, layout: LayoutConfig, configs: ..ElementConfig) {
    rectangle := Rectangle(.{
        cornerRadius = CornerRadiusAll(10),
        color = ifx PointerOver(id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
    });
    
    // we have to do this silly thing because we can't spread configs into Element AND put in rectangle, sad!
    mark := Basic.get_temporary_storage_mark();
    args := Basic.NewArray(configs.count+1, ElementConfig,, Basic.temp);
    for configs args[it_index] = it;
    args[args.count-1] = rectangle;
    Element(id, layout, ..args);
    Basic.set_temporary_storage_mark(mark);
    
    #if OS == .WASM then rectangle.config.rectangleElementConfig.link = link; else {
        // user_data := capture(#code.{ ctx = *context, link = link_value },, Basic.temp);
        user_data := Basic.New(struct { ctx: *#Context; link: string; },, Basic.temp);
        user_data.* = .{*context, link_value};
        OnHover(xx (id: ElementId, pointer_info: PointerData, using capture: type_of(user_data)) #c_call {
            push_context,defer_pop ctx;
            push_context,defer_pop Remap_Context.remap_context();
            if pointer_info.state == .PRESSED_THIS_FRAME {
                Basic.log("TODO: Open Link %", link);
            }
        }, xx user_data);
    }
    
    Text(text, config);
}

#load "desktop.jai";

active_renderer_index : int = 0;

#load "../common.jai";
using,only(.["+", "-", "*", "/"]) Basic :: #import "Basic";
using,only(.["+", "-", "*", "/"]) Math  :: #import "Math";
Compiler      :: #import "Compiler";
Program_Print :: #import "Program_Print";
Remap_Context :: #import "Remap_Context"(VERBOSE=false);
using Clay    :: #import,file "../../../module.jai";

using shared_state: *State;

my_print_style :: inline (max_pointer_depth : u32 = 0) -> Basic.Print_Style {
    style := Basic.Print_Style.{
        struct_printer = my_struct_printer,
        // struct_printer_data = New(My_Struct_Printer_Data),
        default_format_struct = .{
            use_long_form_if_more_than_this_many_members = -1,
            draw_type_name                               = true,
            use_newlines_if_long_form                    = true,
        }, 
    };
    // (cast(*My_Struct_Printer_Data) style.struct_printer_data).max_pointer_chases = max_pointer_chases;
    return style;
}

my_struct_printer :: (sb: *Basic.String_Builder, v: Any, data: *void) -> bool {
    using Basic;
    // here we "dereference" any pointer types so that we can print the
    // contents at that address if it is non-null (you can still cast to *void to
    // print the address)
    if !v.value_pointer return false;
    // using cast(*My_Struct_Printer_Data) data;
    
    item: Any;
    info: *Type_Info_Struct;
    if v.type.type == {
    case .POINTER; {
    //     if cur_pointer_chases >= max_pointer_chases return false;
        item.value_pointer = (cast(**void)v.value_pointer).*;
        if !item.value_pointer return false;
        item.type = (cast(*Type_Info_Pointer)v.type).pointer_to;
        if item.type.type != .STRUCT return false;
        info = cast(*Type_Info_Struct) item.type;
        if context.print_style.default_format_struct.draw_type_name append(sb, "*");
    //     cur_pointer_chases += 1;
    }
    case .STRUCT; {
        if !v.value_pointer return false;
        info = cast(*Type_Info_Struct) v.type;
        item = v;
    }
    case; return false; //assert(false, "%", v.type.type); return false;
    }
    
    // defer if v.type.type == .POINTER then cur_pointer_chases -= 1;
    
    if info.name == {
    case; if v.type.type != .POINTER then return false; else {
        print_item_to_builder(sb, item);
        return true;
    }
    }
    return false;
}

#program_export "update"
update : Layout_Update_Procedure : (state: *State) -> Clay.RenderCommandArray {
    push_context,defer_pop Remap_Context.remap_context();
    
    Basic.assert(xx state);
    shared_state = state;
    if !clay_context {
        min_mem_size := MinMemorySize();
        clay_memory  := Arena.{
            memory    = Basic.alloc(min_mem_size),
            capacity  = min_mem_size
        };
        clay_context = Initialize(clay_memory, .{ window_width, window_height }, handle_error);
    }
    Basic.assert(xx clay_context);
    
    context.print_style = my_print_style();
    
    SetCurrentContext(clay_context);
    SetMeasureTextFunction(measure_text, xx *context);
    SetDebugModeEnabled(show_debugger);
    SetPointerState(cast,force(Clay.Vector2) mouse_position, left_mouse_down && !scrollbar_data.mouse_down);
    SetLayoutDimensions(.{ window_width, window_height });
    debugViewWidth = xx (window_width * 0.35);
    // mouse_position := Math.Vector2.{R.GetMousePosition().x, R.GetMousePosition().y};
    // SetQueryScrollOffsetFunction((id: u32) -> Vector2 #c_call {
    //     using shared_state;
    //     return cast,force(Clay.Vector2) (mouse_wheel_delta);
    // });
    if !left_mouse_down then scrollbar_data.mouse_down = false;
    
    if left_mouse_down && !scrollbar_data.mouse_down && PointerOver(ID("ScrollBar")) {
        container := GetScrollContainerData(ID("OuterScrollContainer"));
        scrollbar_data.click_origin    = mouse_position;
        scrollbar_data.position_origin = cast,force(Math.Vector2) container.scrollPosition.*;
        scrollbar_data.mouse_down      = true;
    } else if scrollbar_data.mouse_down {
        using container := GetScrollContainerData(ID("OuterScrollContainer"));
        if contentDimensions.height > 0 {
            ratio := Vector2.{
                contentDimensions.width / scrollContainerDimensions.width,
                contentDimensions.height / scrollContainerDimensions.height,
            };
            
            if   config.vertical
            then scrollPosition.y = scrollbar_data.position_origin.y + (scrollbar_data.click_origin.y - mouse_position.y) * ratio.y;
            
            if   config.horizontal
            then scrollPosition.x = scrollbar_data.position_origin.x + (scrollbar_data.click_origin.x - mouse_position.x) * ratio.x;
        }
    }
    
    delta_time :: 1.0/60.0;
    animation_counter += delta_time;
    
    mouse_wheel_speed :: 5.0;
    UpdateScrollContainers(true, cast,force(Clay.Vector2)(mouse_wheel_delta*mouse_wheel_speed), delta_time);
    BeginLayout();
    create_layout();
    show_debugger = IsDebugModeEnabled(); // in case we hit the little close button in the debugger window
    return EndLayout();
}