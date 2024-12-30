Scrollbar_Data :: struct {
    click_origin    : Math.Vector2;
    position_origin : Math.Vector2;
    mouse_down      : bool;
}

State :: struct {
    scrollbar_data    := Scrollbar_Data.{};
    animation_counter := 0.0;
    debugEnabled      := false;
    
    window_width  := 1024 * 1.0;
    window_height := 768 * 1.0;
    
    mouse_position    : Math.Vector2;
    mouse_wheel_delta : Math.Vector2;
    is_d_key_pressed  : bool;
    left_mouse_down   : bool;
    
    Image :: struct {
        path: string;
        data: Simp.Texture;
    }
    
    images: struct {
        syntax := Image.{path="../resources/declarative.png"};
        debug0 := Image.{path="../resources/debugger.png"};
        check1 := Image.{path="../resources/check_1.png"};
        check2 := Image.{path="../resources/check_2.png"};
        check3 := Image.{path="../resources/check_3.png"};
        check4 := Image.{path="../resources/check_4.png"};
        check5 := Image.{path="../resources/check_5.png"};
    };
    
    // measure_text: (text: *void, config: *void) -> Clay.Dimensions #c_call;
    measure_text: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    render: (commands: *Clay.RenderCommandArray);
}

FONT_PATHS :: string.[
    "../resources/Calistoga-Regular.ttf",  // FONT_TITLE_PATH
    "../resources/Quicksand-Semibold.ttf", // FONT_BODY_PATH
    "../resources/RobotoMono-Medium.ttf",  // FONT_MONOSPACE_PATH
];

FONT_TITLE     : u16 : 0;
FONT_BODY      : u16 : 1;
FONT_MONOSPACE : u16 : 2;

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

logx :: ($code: Code, $show_lhs := true, $show_type := true , loc := #caller_location) #expand {
    result   := #insert code;
    filename := String.path_filename(loc.fully_pathed_filename);

    #if show_lhs {
        REPR :: #run -> string {
            using Compiler;
            using Program_Print;
            sb: String_Builder;
            print_expression(*sb, compiler_get_nodes(code));
            return builder_to_string(*sb);
        }
        #if  show_type
        then Basic.log("%: % = %", REPR, type_of(result), result);
        else Basic.log("% := %", REPR, result);
    } else {
        #if  show_type
        then Basic.log("% (%)", result, type_of(result));
        else Basic.log("%", result);
    }
}