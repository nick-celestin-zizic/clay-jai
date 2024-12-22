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

HEADER_TEXT_CONFIG :: Clay.TextElementConfig.{
    fontId    = FONT_BODY_24,
    fontSize  = 24,
    textColor = .{61, 26, 5, 255},
};

create_layout :: (using state: State) -> Clay.RenderCommandArray {
    using Clay;
    BeginLayout();
    
    mobile_screen := window_width < window_height;
    
    { Element(ID("OuterContainer"), Layout(.{
        layoutDirection = .TOP_TO_BOTTOM, sizing = .{ SizingGrow(), SizingGrow() } }),
        Rectangle(.{ color = COLOR_LIGHT })
    );
        
        { Element(ID("Header"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingFixed(50) },
                childAlignment = .{ y = .CENTER },
                childGap = 16,
                padding = .{ 32, 0 }
            })
        );
            Text("Clay", *HEADER_TEXT_CONFIG); 
    
            { Element(ID("Spacer"), Layout(.{ sizing = .{ width = SizingGrow() } }) ); }
            
            if (!mobile_screen) {
                { Element(ID("LinkExamplesOuter"),
                    Layout(.{ padding = .{ 8, 0 } }),
                    Rectangle(.{/*link = ("https://github.com/nicbarker/clay/tree/main/examples"),*/ color = .{} })
                );
                    Text("Examples", *HEADER_TEXT_CONFIG);
                }
    
                { Element(ID("LinkDocsOuter"),
                    Layout(.{ padding = .{ 8, 0 } }),
                    Rectangle(.{/*link = ("https://github.com/nicbarker/clay/blob/main/README.md"),*/ color = .{} }) 
                );
                    Text("Docs", *HEADER_TEXT_CONFIG);
                }
            }
            
            discord_link_id := ID("DiscordLink");
            { Element(discord_link_id,
                Layout(.{ padding = .{16, 6} }),
                Rectangle(.{
                    cornerRadius = CornerRadiusAll(10),
                    // link = ("https://discord.gg/b4FTWkxdvT"),
                    color = ifx PointerOver(discord_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
                }),
                BorderOutsideRadius(2, COLOR_RED, 10)
            );
                Text("Discord", *HEADER_TEXT_CONFIG);
            }
            
            github_link_id := ID("GithubLink");
            { Element(github_link_id,
                Layout(.{ padding = .{16, 6} }),
                Rectangle(.{
                    cornerRadius = CornerRadiusAll(10),
                    // link = ("https://github.com/nicbarker/clay"),
                    color = ifx PointerOver(github_link_id) then COLOR_LIGHT_HOVER else COLOR_LIGHT
                }),
                BorderOutsideRadius(2, COLOR_RED, 10)
            );
                Text("Github", *HEADER_TEXT_CONFIG);
            }
        }
        
        stripe :: inline (name: string, color: Color) { Element(ID(name), Layout(.{ sizing = .{ SizingGrow(), SizingFixed(4) }}), Rectangle(.{ color = color })); }
        stripe("TopBorder1", COLOR_TOP_BORDER_5);
        stripe("TopBorder2", COLOR_TOP_BORDER_4);
        stripe("TopBorder3", COLOR_TOP_BORDER_3);
        stripe("TopBorder4", COLOR_TOP_BORDER_2);
        stripe("TopBorder5", COLOR_TOP_BORDER_1);
        
        // stripe("TopBorder41", COLOR_TOP_BORDER_2);
        // stripe("TopBorder51", COLOR_TOP_BORDER_1);
        // stripe("TopBorder41", COLOR_TOP_BORDER_2);
        // stripe("TopBorder51", COLOR_TOP_BORDER_1);
        // stripe("TopBorder41", COLOR_TOP_BORDER_2);
        // stripe("TopBorder51", COLOR_TOP_BORDER_1);
        
        { Element(ID("OuterScrollContainer"),
            Layout(.{ sizing = .{ SizingGrow(), SizingGrow() }, layoutDirection =  .TOP_TO_BOTTOM }),
            Scroll(.{ vertical = true }),
            Border(.{ betweenChildren = .{2, COLOR_RED} })
        );
            Basic.assert(!mobile_screen);
            if mobile_screen {
                // LandingPageMobile();
                // FeatureBlocksMobile();
                // DeclarativeSyntaxPageMobile();
                // HighPerformancePageMobile(lerp_value);
                // RendererPageMobile();
            } else {
                landing_page_desktop(state);
                high_performance_page_desktop(state);
                // FeatureBlocksDesktop();
                // DeclarativeSyntaxPageDesktop();
                // RendererPageDesktop();
                // DebuggerPageDesktop();
            }
        }
    }
    
    return EndLayout();
}

landing_page_desktop :: (using state: State) {
    using Clay;
    
    { Element(ID("LandingPage1Desktop"),
        Layout(.{
            sizing = .{ width = SizingGrow(), height = SizingFit(.{ min = window_height - 70 }) },
            childAlignment = .{y = .CENTER}, padding = .{ x = 50 } }
        )
    );
        
        { Element(ID("LandingPage1"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingGrow() },
                childAlignment = .{y = .CENTER},
                padding = .{ 32, 32 }, childGap = 32 }
            ),
            Border(.{ left = .{ 2, COLOR_RED }, right = .{ 2, COLOR_RED } })
        );
            { Element(ID("LeftText"),
                Layout(.{
                    sizing = .{ width = SizingPercent(0.55) },
                    layoutDirection = .TOP_TO_BOTTOM,
                    childGap = 8
                })
            );
                config := StoreTextElementConfig(.{ fontSize = 56, fontId = FONT_TITLE_56, textColor = COLOR_RED });
                Text("Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.", config);
                
                { Element(ID("LandingPageSpacer"),
                    Layout(.{
                        sizing = .{ width = SizingGrow(), height = SizingFixed(32) }
                    })
                );
                    config := StoreTextElementConfig(.{ fontSize = 36, fontId = FONT_TITLE_36, textColor = COLOR_ORANGE });
                    Text("Clay is laying out this webpage right now!", config);
                }
            }
            
            landing_page_blob :: (index: u32, color: Color, text: string, imageData: *void) {
                font_size: u16 = 24;
                Element(ID("HeroBlob", index),
                    Layout(.{
                        sizing = .{ width = SizingGrow(.{ max = 480 }) },
                        padding = .{16, 16},
                        childGap = 16,
                        childAlignment = .{y = .CENTER} }
                    ),
                    BorderOutsideRadius(2, color, 10)
                );
                    
                { Element(ID("CheckImage", index),
                    Layout(.{ sizing = .{ width = SizingFixed(32) } }),
                    Image(.{ sourceDimensions = .{ 128, 128 }, imageData = imageData })
                ); }
                
                Text(text, StoreTextElementConfig(.{ fontSize = font_size, fontId = FONT_BODY_24, textColor = color }));
            }
            
            { Element(ID("HeroImageOuter"),
                Layout(.{
                    layoutDirection = .TOP_TO_BOTTOM,
                    sizing = .{ width = SizingPercent(0.45) },
                    childAlignment = .{ x = .CENTER },
                    childGap = 16
                })
            );
                
                id : u32 = 0;
                landing_page_blob(id, COLOR_BLOB_BORDER_5, "High performance", image_check5); id += 1;
                landing_page_blob(id, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", image_check4); id += 1;
                landing_page_blob(id, COLOR_BLOB_BORDER_3, "Declarative syntax", image_check3); id += 1;
                landing_page_blob(id, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", image_check2); id += 1;
                landing_page_blob(id, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", image_check1); id += 1;
                
                landing_page_blob(id, COLOR_BLOB_BORDER_1, "Very nice Jai bindings", image_check2); id += 1;
                landing_page_blob(id, COLOR_BLOB_BORDER_1, "Live Editing!!! :)", image_check2); id += 1;
            }
        }
    }
}

LOREM_IPSUM_TEXT   :: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
LOREM_IPSUM_CONFIG :: Clay.TextElementConfig.{ fontSize = 18, fontId = FONT_TITLE_56, textColor = COLOR_LIGHT };

high_performance_page_desktop :: (using state: State) {
    using Clay;
    Element(ID("PerformanceDesktop"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFit(.{ min = xx (window_height - 50) }) },
            childAlignment = .{0, .CENTER},
            padding = .{82, 32},
            childGap = 64
        }),
        Rectangle(.{ color = COLOR_RED })
    );
    
    { Element(ID("PerformanceLeftText"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.5) },
            layoutDirection = .TOP_TO_BOTTOM,
            childGap = 8
        })
    );
        Text("High Performance", StoreTextElementConfig(.{
            fontSize = 52,
            fontId = FONT_TITLE_56,
            textColor = COLOR_LIGHT
        }));
        
        { Element(ID("PerformanceSpacer"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 16 }) }})); }
        
        Text("Fast enough to recompute your entire UI every frame.", StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY_36, textColor = COLOR_LIGHT }));
        Text("Small memory footprint (3.5mb default) with static allocation & reuse. No malloc / free.", StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY_36, textColor = COLOR_LIGHT }));
        Text("Simplify animations and reactive UI design by avoiding the standard performance hacks.", StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY_36, textColor = COLOR_LIGHT }));
    }
    
    { Element(ID("PerformanceRightImageOuter"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.50) },
            childAlignment = .{ x = .CENTER }
        })
    );
        lerp_value := Math.sin(animationCounter*2.5)*0.5 + 0.5;
        
        { Element(ID("AnimationDemoContainer"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingFixed(400) } }
            ),
            BorderAll(.{ width = 2, color = COLOR_LIGHT })
        );
            { Element(ID("AnimationDemoContainerLeft"),
                Layout(.{
                    sizing = .{ SizingPercent(0.3 + 0.4 * lerp_value), SizingGrow() },
                    childAlignment = .{y = .CENTER},
                    padding = .{32, 32} }
                ),
                Rectangle(.{ color = cast,force(Color) Math.lerp(cast,force(Math.Vector4) COLOR_RED, cast,force(Math.Vector4) COLOR_ORANGE, lerp_value) })
            );
                Text(LOREM_IPSUM_TEXT, *LOREM_IPSUM_CONFIG);
            }
            
            { Element(ID("AnimationDemoContainerRight"),
                Layout(.{
                    sizing = .{ SizingGrow(), SizingGrow() },
                    childAlignment = .{y = .CENTER},
                    padding = .{32, 32} }
                ),
                Rectangle(.{ color = cast,force(Color) Math.lerp(cast,force(Math.Vector4) COLOR_ORANGE, cast,force(Math.Vector4) COLOR_RED, lerp_value) })
            );
                Text(LOREM_IPSUM_TEXT, *LOREM_IPSUM_CONFIG);
            }
        }
    }
}

#load "../common.jai";
Basic :: #import "Basic";
Math  :: #import "Math";
Clay  :: #import,file "../../../module.jai";


#program_export "layout_update"
layout_update : layout_update_proc_type : (using state: *State) {
    using Clay;
    
    mouseWheelX := mouse_wheel_delta.x;
    mouseWheelY := mouse_wheel_delta.y;
    
    if is_d_key_pressed {
    // if (R.IsKeyPressed(.KEY_D)) {
        debugEnabled = !debugEnabled;
        SetDebugModeEnabled(debugEnabled);
    }
    
    // mouse_position := Math.Vector2.{R.GetMousePosition().x, R.GetMousePosition().y};
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
    
    // delta_time := R.GetFrameTime();
    if (delta_time == delta_time) { // NaN propagation can cause pain here
        animationCounter += delta_time;
    }

    UpdateScrollContainers(true, .{mouseWheelX, mouseWheelY}, delta_time);
    render_commands := create_layout(state);
    render(*render_commands);
}

// this stuff is pretty ugly, would be nice if all of Clay's globals where in a single struct, but we have to 
// do this to reload the state of the library properly.

#program_export "layout_init"
layout_init : layout_init_proc_type : (using state: *State, clay_state: *Clay_State) {
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
layout_get_clay_state : layout_get_clay_state_proc_type : () -> Clay_State {
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

