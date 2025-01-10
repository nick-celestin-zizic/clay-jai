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
    using Clay;
    
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
            padding = .{ xx wu(2.2), 0 }
        }),
        children = #code {
        
        header_text_config := StoreTextElementConfig(.{
            fontId    = FONT_BODY,
            fontSize  = xx hu(2),
            textColor = .{61, 26, 5, 255},
        });
        
        Text("Clay", header_text_config); 

        { Element(ID("Spacer"), Layout(.{ sizing = .{ width = SizingGrow() } }) ); }
        
        header_button_pad := cast(u16) wu(.8);
        if !mobile_screen {
            Element(ID("LinkExamplesOuter"),
                Layout(.{ padding = .{ header_button_pad, 0 } }),
                Rectangle(.{/*link = ("https://github.com/nicbarker/clay/tree/main/examples"),*/ color = .{} }),
                children = Text("Examples", header_text_config)
            );

            Element(ID("LinkDocsOuter"),
                Layout(.{ padding = .{ header_button_pad, 0 } }),
                Rectangle(.{/*link = ("https://github.com/nicbarker/clay/blob/main/README.md"),*/ color = .{} }),
                children = Text("Docs", header_text_config)
            );
        }
        
        discord_link_id := ID("DiscordLink");
        Element(discord_link_id,
            Layout(.{ padding = .{ header_button_pad, 0 } }),
            Rectangle(.{
                cornerRadius = CornerRadiusAll(10),
                // link = ("https://discord.gg/b4FTWkxdvT"),
                color = ifx PointerOver(discord_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
            }),
            BorderOutsideRadius(2, COLOR_RED, 10),
            children = Text("Discord", header_text_config)
        );
        
        github_link_id := ID("GithubLink");
        Element(github_link_id,
            Layout(.{ padding = .{header_button_pad, 0 } }),
            Rectangle(.{
                cornerRadius = CornerRadiusAll(10),
                // link = ("https://github.com/nicbarker/clay"),
                color = ifx PointerOver(github_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
            }),
            BorderOutsideRadius(2, COLOR_RED, 10),
            children = Text("Github", header_text_config)
        );
    });
    
    h, id := cast(float) hu(0.65), cast(u32) 1;
    stripe :: (color: Color) #expand {
        Element(ID("TopBorder", id), Layout(.{ sizing = .{ SizingGrow(), SizingFixed(h) }}), Rectangle(.{ color = color }), );
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

#load "desktop.jai";

active_renderer_index : int = 0;

#load "../common.jai";
using,only(.["+", "-", "*", "/"]) Basic :: #import "Basic";
using,only(.["+", "-", "*", "/"]) Math  :: #import "Math";
Compiler      :: #import "Compiler";
Program_Print :: #import "Program_Print";
Remap_Context :: #import "Remap_Context"(VERBOSE=false);
Clay          :: #import,file "../../../module.jai";

using shared_state: *State;

#program_export "update"
update : Layout_Update_Procedure : (state: *State) -> Clay.RenderCommandArray {
    push_context,defer_pop Remap_Context.remap_context();
    using Clay;
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
    
    SetCurrentContext(clay_context);
    SetMeasureTextFunction(measure_text);
    SetDebugModeEnabled(show_debugger);
    SetPointerState(cast,force(Clay.Vector2) mouse_position, left_mouse_down && !scrollbar_data.mouse_down);
    SetLayoutDimensions(.{ window_width, window_height });
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