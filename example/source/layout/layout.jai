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
// wu :: inline (value: $T) -> T { return mu(value); }
// hu :: inline (value: $T) -> T { return mu(value); }

create_layout :: () {
    using Clay;
    
    mobile_screen := window_width < window_height;
    
    { Element(ID("OuterContainer"), Layout(.{
        layoutDirection = .TOP_TO_BOTTOM, sizing = .{ SizingGrow(), SizingGrow() } }),
        Rectangle(.{ color = COLOR_LIGHT })
    );
        
        { Element(ID("Header"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingFixed(xx hu(4)) },
                childAlignment = .{ y = .CENTER },
                childGap = xx wu(1.1),
                padding = .{ xx wu(2.2), 0 }
            })
        );
            header_text_config := StoreTextElementConfig(.{
                fontId    = FONT_BODY,
                fontSize  = xx hu(2),
                textColor = .{61, 26, 5, 255},
            });
            
            Text("Clay", header_text_config); 
    
            { Element(ID("Spacer"), Layout(.{ sizing = .{ width = SizingGrow() } }) ); }
            
            header_button_pad := cast(u16) wu(.8);
            if !mobile_screen {
                { Element(ID("LinkExamplesOuter"),
                    Layout(.{ padding = .{ header_button_pad, 0 } }),
                    Rectangle(.{/*link = ("https://github.com/nicbarker/clay/tree/main/examples"),*/ color = .{} })
                );
                    Text("Examples", header_text_config);
                }
    
                { Element(ID("LinkDocsOuter"),
                    Layout(.{ padding = .{ header_button_pad, 0 } }),
                    Rectangle(.{/*link = ("https://github.com/nicbarker/clay/blob/main/README.md"),*/ color = .{} }) 
                );
                    Text("Docs", header_text_config);
                }
            }
            
            discord_link_id := ID("DiscordLink");
            { Element(discord_link_id,
                Layout(.{ padding = .{ header_button_pad, 0 } }),
                Rectangle(.{
                    cornerRadius = CornerRadiusAll(10),
                    // link = ("https://discord.gg/b4FTWkxdvT"),
                    color = ifx PointerOver(discord_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
                }),
                BorderOutsideRadius(2, COLOR_RED, 10)
            );
                Text("Discord", header_text_config);
            }
            
            github_link_id := ID("GithubLink");
            { Element(github_link_id,
                Layout(.{ padding = .{header_button_pad, 0 } }),
                Rectangle(.{
                    cornerRadius = CornerRadiusAll(10),
                    // link = ("https://github.com/nicbarker/clay"),
                    color = ifx PointerOver(github_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
                }),
                BorderOutsideRadius(2, COLOR_RED, 10)
            );
                Text("Github", header_text_config);
            }
        }
        
        stripe :: inline (name: string, color: Color) {
            Element(ID(name), Layout(.{ sizing = .{ SizingGrow(), SizingFixed(xx hu(0.6)) }}), Rectangle(.{ color = color }));
        }
        
        stripe("TopBorder1", COLOR_TOP_BORDER_5);
        stripe("TopBorder2", COLOR_TOP_BORDER_4);
        stripe("TopBorder3", COLOR_TOP_BORDER_3);
        stripe("TopBorder4", COLOR_TOP_BORDER_2);
        stripe("TopBorder5", COLOR_TOP_BORDER_1);
        
        { Element(ID("OuterScrollContainer"),
            Layout(.{ sizing = .{ SizingGrow(), SizingGrow() }, layoutDirection =  .TOP_TO_BOTTOM }),
            Scroll(.{ vertical = true }),
            Border(.{ betweenChildren = .{2, COLOR_RED} })
        );
            if mobile_screen {
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
        }
    }
}

#load "desktop.jai";

active_renderer_index : int = 0;

#load "../common.jai";
Basic         :: #import "Basic";
Math          :: #import "Math";
Compiler      :: #import "Compiler";
Program_Print :: #import "Program_Print";
Remap_Context :: #import "Remap_Context"(VERBOSE=false);
Clay          :: #import,file "../../../module.jai";

using shared_state: *State;

#program_export "layout_update"
layout_update : type_of(Layout_Library_Procedures.layout_update) : (state: *State) -> Clay.RenderCommandArray {
    push_context,defer_pop Remap_Context.remap_context();
    using Clay;
    Basic.assert(xx state);
    shared_state = state;
    
    mouseWheelX := mouse_wheel_delta.x;
    mouseWheelY := mouse_wheel_delta.y;
    
    SetDebugModeEnabled(show_debugger);
    
    // mouse_position := Math.Vector2.{R.GetMousePosition().x, R.GetMousePosition().y};
    // SetQueryScrollOffsetFunction((id: u32) -> Vector2 #c_call {
    //     using shared_state;
    //     return cast,force(Clay.Vector2) (mouse_wheel_delta);
    // });
    SetPointerState(cast,force(Clay.Vector2) mouse_position, left_mouse_down && !scrollbar_data.mouse_down);
    SetLayoutDimensions(.{ window_width, window_height });
    if (!left_mouse_down) {
        scrollbar_data.mouse_down = false;
    }
    
    if (left_mouse_down && !scrollbar_data.mouse_down && PointerOver(ID("ScrollBar"))) {
        container := GetScrollContainerData(ID("OuterScrollContainer"));
        scrollbar_data.click_origin    = mouse_position;
        scrollbar_data.position_origin = cast,force(Math.Vector2) container.scrollPosition.*;
        scrollbar_data.mouse_down      = true;
    } else if (scrollbar_data.mouse_down) {
        container := GetScrollContainerData(ID("OuterScrollContainer"));
        if (container.contentDimensions.height > 0) {
            ratio := Vector2.{
                container.contentDimensions.width / container.scrollContainerDimensions.width,
                container.contentDimensions.height / container.scrollContainerDimensions.height,
            };
            
            if   container.config.vertical
            then container.scrollPosition.y = scrollbar_data.position_origin.y + (scrollbar_data.click_origin.y - mouse_position.y) * ratio.y;
            
            if   container.config.horizontal
            then container.scrollPosition.x = scrollbar_data.position_origin.x + (scrollbar_data.click_origin.x - mouse_position.x) * ratio.x;
        }
    }
    
    delta_time :: 1.0/60.0;
    animation_counter += delta_time;
    
    mouse_wheel_speed :: 5.0;
    using,except(Vector2) Math;
    UpdateScrollContainers(true, cast,force(Clay.Vector2)(mouse_wheel_delta*mouse_wheel_speed), delta_time);
    BeginLayout();
    create_layout();
    return EndLayout();
}

// this stuff is pretty ugly, would be nice if all of Clay's globals where in a single struct, but we have to 
// do this to reload the state of the library properly.

#program_export "layout_init"
layout_init : type_of(Layout_Library_Procedures.layout_init) : (using state: *State, clay_state: *Clay_State) {
    push_context,defer_pop Remap_Context.remap_context();
    if clay_state {
        Clay.Clay__pointerInfo = clay_state.pointerInfo;
        Clay.Clay__layoutDimensions = clay_state.layoutDimensions;
        Clay.Clay__dynamicElementIndexBaseHash = clay_state.dynamicElementIndexBaseHash;
        Clay.Clay__dynamicElementIndex = clay_state.dynamicElementIndex;
        Clay.Clay__debugModeEnabled = clay_state.debugModeEnabled;
        Clay.Clay__disableCulling = clay_state.disableCulling;
        Clay.Clay__externalScrollHandlingEnabled = clay_state.externalScrollHandlingEnabled;
        Clay.Clay__debugSelectedElementId = clay_state.debugSelectedElementId;
        Clay.Clay__debugViewWidth = clay_state.debugViewWidth;
        Clay.Clay__debugViewHighlightColor = clay_state.debugViewHighlightColor;
        Clay.Clay__debugMaxElementsLatch = clay_state.debugMaxElementsLatch;
        Clay.Clay__generation = clay_state.generation;
        Clay.Clay__arenaResetOffset = clay_state.arenaResetOffset;
        Clay.Clay__internalArena = clay_state.internalArena;
        Clay.Clay__layoutElements = clay_state.layoutElements;
        Clay.Clay__renderCommands = clay_state.renderCommands;
        Clay.Clay__openLayoutElementStack = clay_state.openLayoutElementStack;
        Clay.Clay__layoutElementChildren = clay_state.layoutElementChildren;
        Clay.Clay__layoutElementChildrenBuffer = clay_state.layoutElementChildrenBuffer;
        Clay.Clay__textElementData = clay_state.textElementData;
        Clay.Clay__imageElementPointers = clay_state.imageElementPointers;
        Clay.Clay__reusableElementIndexBuffer = clay_state.reusableElementIndexBuffer;
        Clay.Clay__layoutElementClipElementIds = clay_state.layoutElementClipElementIds;
        Clay.Clay__layoutConfigs = clay_state.layoutConfigs;
        Clay.Clay__elementConfigBuffer = clay_state.elementConfigBuffer;
        Clay.Clay__elementConfigs = clay_state.elementConfigs;
        Clay.Clay__rectangleElementConfigs = clay_state.rectangleElementConfigs;
        Clay.Clay__textElementConfigs = clay_state.textElementConfigs;
        Clay.Clay__imageElementConfigs = clay_state.imageElementConfigs;
        Clay.Clay__floatingElementConfigs = clay_state.floatingElementConfigs;
        Clay.Clay__scrollElementConfigs = clay_state.scrollElementConfigs;
        Clay.Clay__customElementConfigs = clay_state.customElementConfigs;
        Clay.Clay__borderElementConfigs = clay_state.borderElementConfigs;
        Clay.Clay__layoutElementIdStrings = clay_state.layoutElementIdStrings;
        Clay.Clay__wrappedTextLines = clay_state.wrappedTextLines;
        Clay.Clay__layoutElementTreeNodeArray1 = clay_state.layoutElementTreeNodeArray1;
        Clay.Clay__layoutElementTreeRoots = clay_state.layoutElementTreeRoots;
        Clay.Clay__layoutElementsHashMapInternal = clay_state.layoutElementsHashMapInternal;
        Clay.Clay__layoutElementsHashMap = clay_state.layoutElementsHashMap;
        Clay.Clay__measureTextHashMapInternal = clay_state.measureTextHashMapInternal;
        Clay.Clay__measureTextHashMapInternalFreeList = clay_state.measureTextHashMapInternalFreeList;
        Clay.Clay__measureTextHashMap = clay_state.measureTextHashMap;
        Clay.Clay__measuredWords = clay_state.measuredWords;
        Clay.Clay__measuredWordsFreeList = clay_state.measuredWordsFreeList;
        Clay.Clay__openClipElementStack = clay_state.openClipElementStack;
        Clay.Clay__pointerOverIds = clay_state.pointerOverIds;
        Clay.Clay__scrollContainerDatas = clay_state.scrollContainerDatas;
        Clay.Clay__treeNodeVisited = clay_state.treeNodeVisited;
        Clay.Clay__dynamicStringData = clay_state.dynamicStringData;
        Clay.Clay__debugElementData = clay_state.debugElementData;
        Clay.Clay__MeasureText = clay_state.MeasureText; // for some reason we still have to do ClaySetMeasureTextFunction() for it to work :/
        Clay.Clay__QueryScrollOffset = clay_state.QueryScrollOffset;
        
        Clay.SetMeasureTextFunction(measure_text);
        // return clay_state.internalArena.memory, clay_state.internalArena.capacity;
    } else {
        min_mem_size := Clay.MinMemorySize();
        arena_label  :: "Clay Memory Arena";
        clay_memory  := Clay.Arena.{
            label     = .{xx arena_label.count, arena_label.data},
            memory    = Basic.alloc(min_mem_size),
            capacity  = min_mem_size
        };
        Clay.Initialize(clay_memory, .{ window_width, window_height });
        Clay.SetMeasureTextFunction(measure_text);
        // return clay_memory.memory, min_mem_size;
    }
}

#program_export "layout_get_clay_state"
layout_get_clay_state : type_of(Layout_Library_Procedures.layout_get_clay_state) : () -> Clay_State {
    push_context,defer_pop Remap_Context.remap_context();
    clay_state: Clay_State = ---;
    clay_state.pointerInfo = Clay.Clay__pointerInfo;
    clay_state.layoutDimensions = Clay.Clay__layoutDimensions;
    clay_state.dynamicElementIndexBaseHash = Clay.Clay__dynamicElementIndexBaseHash;
    clay_state.dynamicElementIndex = Clay.Clay__dynamicElementIndex;
    clay_state.debugModeEnabled = Clay.Clay__debugModeEnabled;
    clay_state.disableCulling = Clay.Clay__disableCulling;
    clay_state.externalScrollHandlingEnabled = Clay.Clay__externalScrollHandlingEnabled;
    clay_state.debugSelectedElementId = Clay.Clay__debugSelectedElementId;
    clay_state.debugViewWidth = Clay.Clay__debugViewWidth;
    clay_state.debugViewHighlightColor = Clay.Clay__debugViewHighlightColor;
    clay_state.debugMaxElementsLatch = Clay.Clay__debugMaxElementsLatch;
    clay_state.generation = Clay.Clay__generation;
    clay_state.arenaResetOffset = Clay.Clay__arenaResetOffset;
    clay_state.internalArena = Clay.Clay__internalArena;
    clay_state.layoutElements = Clay.Clay__layoutElements;
    clay_state.renderCommands = Clay.Clay__renderCommands;
    clay_state.openLayoutElementStack = Clay.Clay__openLayoutElementStack;
    clay_state.layoutElementChildren = Clay.Clay__layoutElementChildren;
    clay_state.layoutElementChildrenBuffer = Clay.Clay__layoutElementChildrenBuffer;
    clay_state.textElementData = Clay.Clay__textElementData;
    clay_state.imageElementPointers = Clay.Clay__imageElementPointers;
    clay_state.reusableElementIndexBuffer = Clay.Clay__reusableElementIndexBuffer;
    clay_state.layoutElementClipElementIds = Clay.Clay__layoutElementClipElementIds;
    clay_state.layoutConfigs = Clay.Clay__layoutConfigs;
    clay_state.elementConfigBuffer = Clay.Clay__elementConfigBuffer;
    clay_state.elementConfigs = Clay.Clay__elementConfigs;
    clay_state.rectangleElementConfigs = Clay.Clay__rectangleElementConfigs;
    clay_state.textElementConfigs = Clay.Clay__textElementConfigs;
    clay_state.imageElementConfigs = Clay.Clay__imageElementConfigs;
    clay_state.floatingElementConfigs = Clay.Clay__floatingElementConfigs;
    clay_state.scrollElementConfigs = Clay.Clay__scrollElementConfigs;
    clay_state.customElementConfigs = Clay.Clay__customElementConfigs;
    clay_state.borderElementConfigs = Clay.Clay__borderElementConfigs;
    clay_state.layoutElementIdStrings = Clay.Clay__layoutElementIdStrings;
    clay_state.wrappedTextLines = Clay.Clay__wrappedTextLines;
    clay_state.layoutElementTreeNodeArray1 = Clay.Clay__layoutElementTreeNodeArray1;
    clay_state.layoutElementTreeRoots = Clay.Clay__layoutElementTreeRoots;
    clay_state.layoutElementsHashMapInternal = Clay.Clay__layoutElementsHashMapInternal;
    clay_state.layoutElementsHashMap = Clay.Clay__layoutElementsHashMap;
    clay_state.measureTextHashMapInternal = Clay.Clay__measureTextHashMapInternal;
    clay_state.measureTextHashMapInternalFreeList = Clay.Clay__measureTextHashMapInternalFreeList;
    clay_state.measureTextHashMap = Clay.Clay__measureTextHashMap;
    clay_state.measuredWords = Clay.Clay__measuredWords;
    clay_state.measuredWordsFreeList = Clay.Clay__measuredWordsFreeList;
    clay_state.openClipElementStack = Clay.Clay__openClipElementStack;
    clay_state.pointerOverIds = Clay.Clay__pointerOverIds;
    clay_state.scrollContainerDatas = Clay.Clay__scrollContainerDatas;
    clay_state.treeNodeVisited = Clay.Clay__treeNodeVisited;
    clay_state.dynamicStringData = Clay.Clay__dynamicStringData;
    clay_state.debugElementData = Clay.Clay__debugElementData;
    clay_state.MeasureText = Clay.Clay__MeasureText;
    clay_state.QueryScrollOffset = Clay.Clay__QueryScrollOffset;
    return clay_state;
}

