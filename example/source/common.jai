Scrollbar_Data :: struct {
    click_origin    : Math.Vector2;
    position_origin : Math.Vector2;
    mouse_down      : bool;
}

State :: struct {
    scrollbar_data   := Scrollbar_Data.{};
    animationCounter := 0.0;
    debugEnabled     := false;
    
    window_width  := 1024 * 1.0;
    window_height := 768 * 1.0;
    
    mouse_position    : Math.Vector2;
    mouse_wheel_delta : Math.Vector2;
    is_d_key_pressed  : bool;
    left_mouse_down   : bool;
    delta_time        : float;
    
    image_syntax: *void;
    image_debug0: *void;
    image_check1: *void;
    image_check2: *void;
    image_check3: *void;
    image_check4: *void;
    image_check5: *void;
    
    // measure_text: (text: *void, config: *void) -> Clay.Dimensions #c_call;
    measure_text: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call;
    render: (commands: *void);
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

// Clay._pointerInfo
// Clay._layoutDimensions
// Clay._dynamicElementIndexBaseHash
// Clay._dynamicElementIndex
// Clay._debugModeEnabled
// Clay._disableCulling
// Clay._externalScrollHandlingEnabled
// Clay._debugSelectedElementId
// Clay._debugViewWidth
// Clay._debugViewHighlightColor
// Clay._debugMaxElementsLatch
// Clay._generation
// Clay._arenaResetOffset
// Clay._internalArena

FONT_BODY_16      : u16 : 0;
FONT_BODY_24      : u16 : 1;
FONT_BODY_36      : u16 : 2;
FONT_TITLE_56     : u16 : 3;
FONT_TITLE_36     : u16 : 4;
FONT_MONOSPACE_24 : u16 : 5;

layout_get_clay_state_proc_type :: #type () -> Clay_State;
layout_init_proc_type           :: #type (*State, *Clay_State) -> ();
layout_update_proc_type         :: #type (*State) -> ();