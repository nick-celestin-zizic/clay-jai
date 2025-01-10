State :: struct {
    scrollbar_data: struct {
        click_origin    : Math.Vector2;
        position_origin : Math.Vector2;
        mouse_down      : bool;
    };
    
    clay_context: *Clay.Context;
    
    should_quit       := false;
    animation_counter := 0.0;
    show_debugger     := false;
    
    window_width  := 1024 * 1.0;
    window_height := 768 * 1.0;
    
    mouse_position    : Math.Vector2;
    mouse_wheel_delta : Math.Vector2;
    left_mouse_down   : bool;
    
    images: struct {
        syntax: *void; @"../resources/declarative.png"
        debug0: *void; @"../resources/debugger.png"
        check1: *void; @"../resources/check_1.png"
        check2: *void; @"../resources/check_2.png"
        check3: *void; @"../resources/check_3.png"
        check4: *void; @"../resources/check_4.png"
        check5: *void; @"../resources/check_5.png"
    };
    
    Font_Paths :: struct {
        FONT_BODY  :: "../resources/Quicksand-Semibold.ttf";
        FONT_TITLE :: "../resources/Calistoga-Regular.ttf";
        FONT_MONO  :: "../resources/RobotoMono-Medium.ttf";
    }
    
    measure_text: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    handle_error: Clay.ErrorHandler;
}

// here we paste in all of the members of Font_Paths so that they are available as u16 constants!
// this means we don't have to manually make sure that they match up!
#insert -> string {
    using Basic;
    sb: String_Builder;
    for type_info(State.Font_Paths).members print(*sb, "% : u16 : %;\n", it.name, it_index);
    return builder_to_string(*sb);;
}


Layout_Library_Procedures :: struct {
    init   : (*State) -> ();
    update : (*State) -> Clay.RenderCommandArray;
}

logx :: ($code: Code) #expand {
    result := #insert code;
    REPR :: #run -> string {
        using Basic; using Compiler; using Program_Print;
        sb: String_Builder; print_expression(*sb, compiler_get_nodes(code)); return builder_to_string(*sb);
    }
    Basic.log("%: % = %", REPR, type_of(result), result);
}