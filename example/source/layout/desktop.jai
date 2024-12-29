landing_page_desktop :: () {
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
                config := StoreTextElementConfig(.{ fontSize = 56, fontId = FONT_TITLE, textColor = COLOR_RED });
                Text("Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.", config);
                
                { Element(ID("LandingPageSpacer"),
                    Layout(.{
                        sizing = .{ width = SizingGrow(), height = SizingFixed(32) }
                    })
                );
                    config := StoreTextElementConfig(.{ fontSize = 36, fontId = FONT_TITLE, textColor = COLOR_ORANGE });
                    Text("Clay is laying out this webpage right now!", config);
                }
            }
            
            
            { Element(ID("HeroImageOuter"),
                Layout(.{
                    layoutDirection = .TOP_TO_BOTTOM,
                    sizing = .{ width = SizingPercent(0.45) },
                    childAlignment = .{ x = .CENTER },
                    childGap = 16
                })
            );
                
                index : u32 = 0;
                landing_page_blob :: (color: Color, text: string, imageData: *void) #expand {
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
                    
                    Text(text, StoreTextElementConfig(.{
                        fontSize  = 24,
                        fontId    = FONT_BODY,
                        textColor = color 
                    }));
                    
                    index += 1;
                }
                
                landing_page_blob(COLOR_BLOB_BORDER_5, "High performance", image_check5);
                landing_page_blob(COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", image_check4);
                landing_page_blob(COLOR_BLOB_BORDER_3, "Declarative syntax", image_check3);
                landing_page_blob(COLOR_BLOB_BORDER_2, "Single .h file for C/C++", image_check2);
                landing_page_blob(COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", image_check1);
                
                // landing_page_blob(COLOR_BLOB_BORDER_1, "Very nice Jai bindings", image_check1);
                // landing_page_blob(COLOR_BLOB_BORDER_1, "Live Editing!!! :)", image_check1);
            }
        }
    }
}

feature_blocks_desktop :: () {
    using Clay;
    { Element(ID("FeatureBlocksOuter"),
        Layout(.{ sizing = .{ width = SizingGrow() } })
    );
        { Element(ID("FeatureBlocksInner"),
            Layout(.{ sizing = .{ width = SizingGrow() }, childAlignment = .{ y = .CENTER } }),
            Border(.{ betweenChildren = .{ width = 2, color = COLOR_RED } })
        );
        
            text_config := StoreTextElementConfig(.{ fontSize = 24, fontId = FONT_BODY, textColor = COLOR_RED });
            layout_config := LayoutConfig.{
                layoutDirection = .TOP_TO_BOTTOM,
                sizing = .{ width = SizingPercent(0.5) },
                childAlignment = .{0, .CENTER},
                padding = .{50, 32},
                childGap = 8
            };
            
            { Element(ID("HFileBoxOuter"), Layout(layout_config));
                { Element(ID("HFileIncludeOuter"),
                    Layout(.{ padding = .{8, 4}, layoutDirection = .TOP_TO_BOTTOM, }),
                    Rectangle(.{ color = COLOR_RED, cornerRadius = CornerRadiusAll(8)})
                );
                    config := StoreTextElementConfig(.{ fontSize = 24, fontId = FONT_BODY, textColor = COLOR_LIGHT });
                    Text("#define CLAY_IMPLEMENTATION", config);
                    Text("#include clay.h", config);
                }
                Text("~2000 lines of C99.", text_config);
                Text("Zero dependencies, including no C standard library.", text_config);
            }
            { Element(ID("BringYourOwnRendererOuter"), Layout(layout_config));
                Text("Renderer agnostic.", StoreTextElementConfig(.{ fontId = FONT_BODY, fontSize = 24, textColor = COLOR_ORANGE }));
                Text("Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.", text_config);
                Text("Flexible output for easy compositing in your custom engine or environment.", text_config);
            }
        }
    }
}

declarative_syntax_page_desktop :: () {
    using Clay;
    { Element(ID("SyntaxPageDesktop"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFit(.{ min = window_height - 50 }) },
            childAlignment = .{0, .CENTER},
            padding = .{x = 50}
        })
    );
        { Element(ID("SyntaxPage"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingGrow() },
                childAlignment = .{ 0, .CENTER },
                padding = .{ 32, 32 },
                childGap = 32 }
            ),
            Border(.{ left = .{ 2, COLOR_RED }, right = .{ 2, COLOR_RED } })
        );
            { Element(ID("SyntaxPageLeftText"),
                Layout(.{
                    sizing = .{ width = SizingPercent(0.5) },
                    layoutDirection = .TOP_TO_BOTTOM,
                    childGap = 8
                })
            );
                Text("Declarative Syntax", StoreTextElementConfig(.{ fontSize = 52, fontId = FONT_TITLE, textColor = COLOR_RED }));
                { Element(ID("SyntaxSpacer"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 16 }) } })); }
                
                config := StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY, textColor = COLOR_RED });
                Text("Flexible and readable declarative syntax with nested UI element hierarchies.", config);
                Text("Mix elements with standard C code like loops, conditionals and functions.", config);
                Text("Create your own library of re-usable components from UI primitives like text, images and rectangles.", config);
            }
            
            { Element(ID("SyntaxPageRightImage"),
                Layout(
                    .{ sizing = .{ width = SizingPercent(0.50) },
                    childAlignment = .{x = .CENTER}
                }),
            );
                { Element(ID("SyntaxPageRightImageInner"),
                    Layout(.{ sizing = .{ width = SizingGrow(.{ max = 568 }) } }),
                    Image(.{ sourceDimensions = .{1136, 1194}, imageData = image_syntax })
                ); }
            }
        }
    }
}

LOREM_IPSUM_TEXT   :: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
LOREM_IPSUM_CONFIG :: Clay.TextElementConfig.{ fontSize = 24, fontId = FONT_TITLE, textColor = COLOR_LIGHT };

high_performance_page_desktop :: () {
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
            sizing = .{ width = SizingPercent(0.45) },
            layoutDirection = .TOP_TO_BOTTOM,
            childGap = 8
        })
    );
        Text("High Performance", StoreTextElementConfig(.{
            fontSize = 52,
            fontId = FONT_TITLE,
            textColor = COLOR_LIGHT
        }));
        
        { Element(ID("PerformanceSpacer"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 16 }) }})); }
        
        config := StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY, textColor = COLOR_LIGHT });
        Text("Fast enough to recompute your entire UI every frame.", config);
        Text("Small memory footprint (3.5mb default) with static allocation & reuse. No malloc / free.", config);
        Text("Simplify animations and reactive UI design by avoiding the standard performance hacks.", config);
    }
    
    { Element(ID("PerformanceRightImageOuter"),
        Layout(.{
            sizing = .{width = SizingPercent(0.55)},
            childAlignment = .{x = .CENTER}
        })
    );
        lerp_value := Math.sin(animation_counter*2.5)*0.5 + 0.5;
        
        { Element(ID("AnimationDemoContainer"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingFixed(400) } }
            ),
            BorderAll(.{ width = 2, color = COLOR_LIGHT })
        );
            pad   :: Padding.{32, 32};
            align :: ChildAlignment.{y = .CENTER};
            
            { Element(ID("AnimationDemoContainerLeft"),
                Layout(.{
                    sizing = .{SizingPercent(0.3 + 0.4 * lerp_value), SizingGrow()},
                    childAlignment = align,
                    padding = pad
                }),
                Rectangle(.{
                    color = cast,force(Color) Math.lerp(
                        cast,force(Math.Vector4) COLOR_RED, cast,force(Math.Vector4) COLOR_ORANGE, lerp_value
                    )
                }),
            );
                Text(LOREM_IPSUM_TEXT, *LOREM_IPSUM_CONFIG);
            }
            
            { Element(ID("AnimationDemoContainerRight"),
                Layout(.{
                    sizing = .{SizingGrow(), SizingGrow()},
                    childAlignment = align,
                    padding = pad
                }),
                Rectangle(.{
                    color = cast,force(Color) Math.lerp(
                        cast,force(Math.Vector4) COLOR_ORANGE, cast,force(Math.Vector4) COLOR_RED, lerp_value
                    )
                }),
            );
                Text(LOREM_IPSUM_TEXT, *LOREM_IPSUM_CONFIG);
            }
        }
    }
}

renderer_page_desktop :: () {
    using Clay;
    { Element(ID("RendererPageDesktop"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFit(.{ min = window_height - 50 }) },
            childAlignment = .{0, .CENTER}, padding = .{x = 50}
        })
    );
        { Element(ID("RendererPage"),
            Layout(.{
                sizing = .{ SizingGrow(), SizingGrow() },
                childAlignment = .{ 0, .CENTER },
                padding = .{ 32, 32 },
                childGap = 32
            }),
            Border(.{ left = .{ 2, COLOR_RED }, right = .{ 2, COLOR_RED } })
        );
            { Element(ID("RendererLeftText"),
                Layout(.{
                    sizing = .{ width = SizingPercent(0.55) },
                    layoutDirection = .TOP_TO_BOTTOM,
                    childGap = 8
                })
            );
                Text("Renderer & Platform Agnostic", StoreTextElementConfig(.{
                    fontSize  = 52,
                    fontId    = FONT_TITLE,
                    textColor = COLOR_RED
                }));
                
                { Element(ID("RendererSpacerLeft"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 16 }) } }) );}
                
                config := StoreTextElementConfig(.{
                    fontSize  = 28,
                    fontId    = FONT_BODY,
                    textColor = COLOR_RED
                });
                
                Text("Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.", config);
                Text("Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.", config);
                Text("There's even an HTML renderer - you're looking at it right now!", config);
            }
            { Element(ID("RendererRightText"),
                Layout(.{
                    sizing = .{ width = SizingPercent(0.45) },
                    childAlignment = .{ x = .CENTER },
                    layoutDirection = .TOP_TO_BOTTOM, childGap = 16
                })
            );
                Text("Try changing renderer!", StoreTextElementConfig(.{ fontSize = 36, fontId = FONT_BODY, textColor = COLOR_ORANGE }));
                { Element(ID("RendererSpacerRight"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 32 }) } })); }
                
                renderer_button_active :: (text: string) #expand {
                    id := ID("RendererButtonActive");
                    Element(id,
                        Layout(.{ sizing = .{ width = SizingFixed(300) }, padding = .{16, 16} }),
                        Rectangle(.{
                            color = ifx PointerOver(id) then COLOR_RED_HOVER else COLOR_RED,
                            cornerRadius = CornerRadiusAll(10)
                        })
                    );
                    
                    Text(text, StoreTextElementConfig(.{
                        /*.disablePointerEvents = true,*/
                        fontSize  = 28,
                        fontId    = FONT_BODY,
                        textColor = COLOR_LIGHT 
                    }));
                }
                
                renderer_button_inactive :: (text: string, renderer_index: int) {
                    id := ID("RendererButtonInactive");
                    Element(id,
                        Layout(.{ sizing = .{ width = SizingFixed(300)}, padding = .{16, 16} }),
                        BorderOutsideRadius(2, COLOR_RED, 10),
                        Rectangle(.{
                            color = ifx PointerOver(id) then COLOR_LIGHT_HOVER else COLOR_LIGHT,
                            cornerRadius = CornerRadiusAll(10),
                            /*cursorPointer = true */
                        }),
                    );
                    
                    OnHover((id: ElementId, pointer_info: PointerData, renderer_index: int) #c_call {
                        if pointer_info.state == .PRESSED_THIS_FRAME {
                            SetCullingEnabled(renderer_index == 1);
                            active_renderer_index = renderer_index;
                            // SetExternalScrollHandlingEnabled(renderer_index == 0);
                        }
                    }, renderer_index);
                    
                    Text(text, StoreTextElementConfig(.{
                        /*.disablePointerEvents = true,*/
                        fontSize = 28,
                        fontId = FONT_BODY,
                        textColor = COLOR_RED
                    }));
                }
                
                if (active_renderer_index == 0) {
                    renderer_button_active("HTML Renderer");
                    renderer_button_inactive("Canvas Renderer", 1);
                } else {
                    renderer_button_inactive("HTML Renderer", 0);
                    renderer_button_active("Canvas Renderer");
                }
            }
        }
    }
}

debugger_page_desktop :: () {
    using Clay;
    Element(ID("DebuggerDesktop"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFit(.{ min = window_height - 50 }) },
            childAlignment = .{0, .CENTER},
            padding = .{ 82, 32},
            childGap = 64
        }),
        Rectangle(.{ color = COLOR_RED })
    );
    
    { Element(ID("DebuggerLeftText"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.5) },
            layoutDirection = .TOP_TO_BOTTOM,
            childGap = 8
        })
    );
        Text("Integrated Debug Tools", StoreTextElementConfig(.{
            fontSize  = 52,
            fontId    = FONT_TITLE,
            textColor = COLOR_LIGHT
        }));
        
        { Element(ID("DebuggerSpacer"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 16 }) }})); }
        
        config := StoreTextElementConfig(.{ fontSize = 28, fontId = FONT_BODY, textColor = COLOR_LIGHT });
        Text("Clay includes built in \"Chrome Inspector\"-style debug tooling.", config);
        Text("View your layout hierarchy and config in real time.", config);
        
        { Element(ID("DebuggerPageSpacer"), Layout(.{ sizing = .{ width = SizingGrow(), height = SizingFixed(32) } })); }
        
        Text("Press the \"d\" key to try it out now!", StoreTextElementConfig(.{
            fontSize  = 32,
            fontId    = FONT_TITLE,
            textColor = COLOR_ORANGE
        }));
    }
    
    { Element(ID("DebuggerRightImageOuter"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.50) },
            childAlignment = .{ x = .CENTER }
        })
    );
        Element(ID("DebuggerPageRightImageInner"),
            Layout(.{ sizing = .{ width = SizingGrow(.{ max = 558 }) } }),
            Image(.{ sourceDimensions = .{1620, 1474}, imageData = image_debug0 })
        );
    }
}