Scrollbar_Data :: struct {
    click_origin    : Math.Vector2;
    position_origin : Math.Vector2;
    mouse_down      : bool;
}

State :: struct {
    scrollbar_data    := Scrollbar_Data.{};
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
        FONT_TITLE :: "../resources/Calistoga-Regular.ttf";
        FONT_BODY  :: "../resources/Quicksand-Semibold.ttf";
        FONT_MONO  :: "../resources/RobotoMono-Medium.ttf";
    }
    
    measure_text: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    render: (commands: *Clay.RenderCommandArray);
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
    layout_get_clay_state : () -> Clay_State;
    layout_init           : (*State, *Clay_State) -> ();
    layout_update         : (*State) -> ();
}

Clay_State :: struct {
    pointerInfo: Clay.PointerData;
    layoutDimensions: Clay.Dimensions;
    dynamicElementIndexBaseHash: Clay.ElementId;
    dynamicElementIndex: u32;
    debugModeEnabled: bool;
    disableCulling: bool;
    externalScrollHandlingEnabled: bool;
    debugSelectedElementId: u32;
    debugViewWidth: u32;
    debugViewHighlightColor: Clay.Color;
    debugMaxElementsLatch: bool;
    generation: u32;
    arenaResetOffset: u64;
    internalArena: Clay.Arena;
    
    layoutElements: Clay.Clay__tArray;
    renderCommands: Clay.Clay__tArray;
    openLayoutElementStack: Clay.Clay__tArray;
    layoutElementChildren: Clay.Clay__tArray;
    layoutElementChildrenBuffer: Clay.Clay__tArray;
    textElementData: Clay.Clay__tArray;
    imageElementPointers: Clay.Clay__tArray;
    reusableElementIndexBuffer: Clay.Clay__tArray;
    layoutElementClipElementIds: Clay.Clay__tArray;
    
    layoutConfigs: Clay.Clay__tArray;
    elementConfigBuffer: Clay.Clay__tArray;
    elementConfigs: Clay.Clay__tArray;
    rectangleElementConfigs: Clay.Clay__tArray;
    textElementConfigs: Clay.Clay__tArray;
    imageElementConfigs: Clay.Clay__tArray;
    floatingElementConfigs: Clay.Clay__tArray;
    scrollElementConfigs: Clay.Clay__tArray;
    customElementConfigs: Clay.Clay__tArray;
    borderElementConfigs: Clay.Clay__tArray;
    
    layoutElementIdStrings: Clay.Clay__tArray;
    wrappedTextLines: Clay.Clay__tArray;
    layoutElementTreeNodeArray1: Clay.Clay__tArray;
    layoutElementTreeRoots: Clay.Clay__tArray;
    layoutElementsHashMapInternal: Clay.Clay__tArray;
    layoutElementsHashMap: Clay.Clay__tArray;
    measureTextHashMapInternal: Clay.Clay__tArray;
    measureTextHashMapInternalFreeList: Clay.Clay__tArray;
    measureTextHashMap: Clay.Clay__tArray;
    measuredWords: Clay.Clay__tArray;
    measuredWordsFreeList: Clay.Clay__tArray;
    openClipElementStack: Clay.Clay__tArray;
    pointerOverIds: Clay.Clay__tArray;
    scrollContainerDatas: Clay.Clay__tArray;
    treeNodeVisited: Clay.Clay__tArray;
    dynamicStringData: Clay.Clay__tArray;
    debugElementData: Clay.Clay__tArray;
    
    MeasureText: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    QueryScrollOffset: (elementId: u32) -> Clay.Vector2 #c_call;
}

logx :: ($code: Code) #expand {
    result := #insert code;
    REPR :: #run -> string {
        using Basic; using Compiler; using Program_Print;
        sb: String_Builder; print_expression(*sb, compiler_get_nodes(code)); return builder_to_string(*sb);
    }
    Basic.log("%: % = %", REPR, type_of(result), result);
}