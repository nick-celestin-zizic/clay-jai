State :: struct {
    scrollbar_data: struct {
        click_origin    : Math.Vector2;
        position_origin : Math.Vector2;
        mouse_down      : bool;
    };
    
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
    layout_get_clay_state : () -> Clay_State;
    layout_init           : (*State, *Clay_State) -> ();
    layout_update         : (*State) -> Clay.RenderCommandArray;
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
    
    generation: u32;
    arenaResetOffset: u64;
    internalArena: Clay.Arena;
    
    // Layout Elements / Render Commands
    layoutElements: Clay.LayoutElementArray;
    renderCommands: Clay.RenderCommandArray;
    openLayoutElementStack: Clay.int32_tArray;
    layoutElementChildren: Clay.int32_tArray;
    layoutElementChildrenBuffer: Clay.int32_tArray;
    textElementData: Clay.TextElementDataArray;
    imageElementPointers: Clay.LayoutElementPointerArray;
    reusableElementIndexBuffer: Clay.int32_tArray;
    layoutElementClipElementIds: Clay.int32_tArray;
    
    // Configs
    layoutConfigs: Clay.LayoutConfigArray;
    elementConfigBuffer: Clay.ElementConfigArray;
    elementConfigs: Clay.ElementConfigArray;
    rectangleElementConfigs: Clay.RectangleElementConfigArray;
    textElementConfigs: Clay.TextElementConfigArray;
    imageElementConfigs: Clay.ImageElementConfigArray;
    floatingElementConfigs: Clay.FloatingElementConfigArray;
    scrollElementConfigs: Clay.ScrollElementConfigArray;
    customElementConfigs: Clay.CustomElementConfigArray;
    borderElementConfigs: Clay.BorderElementConfigArray;
    
    // Misc Data Structures
    layoutElementIdStrings: Clay.StringArray;
    wrappedTextLines: Clay.WrappedTextLineArray;
    layoutElementTreeNodeArray1: Clay.LayoutElementTreeNodeArray;
    layoutElementTreeRoots: Clay.LayoutElementTreeRootArray;
    layoutElementsHashMapInternal: Clay.LayoutElementHashMapItemArray;
    layoutElementsHashMap: Clay.int32_tArray;
    measureTextHashMapInternal: Clay.MeasureTextCacheItemArray;
    measureTextHashMapInternalFreeList: Clay.int32_tArray;
    measureTextHashMap: Clay.int32_tArray;
    measuredWords: Clay.MeasuredWordArray;
    measuredWordsFreeList: Clay.int32_tArray;
    openClipElementStack: Clay.int32_tArray;
    pointerOverIds: Clay.ElementIdArray;
    scrollContainerDatas: Clay.ScrollContainerDataInternalArray;
    treeNodeVisited: Clay.BoolArray;
    dynamicStringData: Clay.CharArray;
    debugElementData: Clay.DebugElementDataArray;
    
    MeasureText: #type (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    QueryScrollOffset: #type (elementId: u32) -> Clay.Vector2 #c_call;
    
    // other globals that are not in the globals block
    debugViewHighlightColor: Clay.Color;
    debugViewWidth: u32;
    warningsEnabled: bool;
    maxElementCount: s32;
    maxMeasureTextCacheWordCount: s32;
    errorHandler: Clay.ErrorHandler;
    booleanWarnings: Clay.BooleanWarnings;
    warnings: Clay.WarningArray;
}

logx :: ($code: Code) #expand {
    result := #insert code;
    REPR :: #run -> string {
        using Basic; using Compiler; using Program_Print;
        sb: String_Builder; print_expression(*sb, compiler_get_nodes(code)); return builder_to_string(*sb);
    }
    Basic.log("%: % = %", REPR, type_of(result), result);
}