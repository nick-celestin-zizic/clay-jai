//
// This file was auto-generated using the following command:
//
// jai generate.jai
//
Element :: (id: ElementId, layout: LayoutConfig, configs: ..ElementConfig, $children := #code,null, cc := #caller_code) #expand {
    OpenElement();
    AttachId(id);
    AttachLayoutConfig(StoreLayoutConfig(layout));
    for configs AttachElementConfig((cast(*ElementConfigUnion)*it.config).*, it.type);
    ElementPostConfiguration();
    #if children {
        #insert,scope(cc) children;
        CloseElement();
    } else {
        `defer CloseElement();
    } 
}

ID :: inline (label: string, index: u32 = 0) -> ElementId { return HashString(.{xx label.count, label.data}, index, 0); }

// for consistency with the all of the other parameters
Layout :: inline (config: LayoutConfig) -> LayoutConfig { return config; }

Rectangle :: inline (config: RectangleElementConfig) -> ElementConfig {
    return .{
        type = .RECTANGLE,
        config.rectangleElementConfig = StoreRectangleElementConfig(config)
    };
}

Image :: inline (config: ImageElementConfig) -> ElementConfig {
    return .{
        type = .IMAGE,
        config.imageElementConfig = StoreImageElementConfig(config)
    };
}

Scroll :: inline (config: ScrollElementConfig) -> ElementConfig {
    return .{
        type = .SCROLL_CONTAINER,
        config.scrollElementConfig = StoreScrollElementConfig(config)
    };
}

Border :: inline (config: BorderElementConfig) -> ElementConfig {
    return .{
        type = .BORDER_CONTAINER,
        config.borderElementConfig = StoreBorderElementConfig(config),
    };
}

Floating :: inline (config: FloatingElementConfig) -> ElementConfig {
    return .{
        type = .FLOATING_CONTAINER,
        config.floatingElementConfig = StoreFloatingElementConfig(config),
    };
}

Custom :: inline (config: CustomElementConfig) -> ElementConfig {
    return .{
        type = .CUSTOM,
        config.customElementConfig = StoreCustomElementConfig(config),
    };
}

BorderAll :: inline (data: BorderData) -> ElementConfig {
    return .{
        type = .BORDER_CONTAINER,
        config.borderElementConfig = StoreBorderElementConfig(.{
            left = data,
            right = data,
            top = data,
            bottom = data,
            betweenChildren = data
        })
    };
}

BorderOutsideRadius :: inline (width: u32, color: Color, radius: float) -> ElementConfig {
    border := BorderData.{width, color};
    return .{
        type = .BORDER_CONTAINER,
        config.borderElementConfig = StoreBorderElementConfig(.{
            left = border,
            right = border,
            top = border,
            bottom = border,
            cornerRadius = .{radius, radius, radius, radius}},
        )
    };
}

Text :: inline (text: string, config: *TextElementConfig) { OpenTextElement(.{xx text.count, text.data}, config); }

SizingFit     :: inline (minMax := SizingMinMax.{}) -> SizingAxis { return .{type = .FIT, size.minMax = minMax}; }
SizingGrow    :: inline (minMax := SizingMinMax.{}) -> SizingAxis { return .{type = .GROW, size.minMax = minMax}; }
SizingFixed   :: inline (size: float) -> SizingAxis { return .{type = .FIXED, size.minMax = .{size, size}}; }
SizingPercent :: inline (percent: float) -> SizingAxis { return .{type = .PERCENT, size.percent = percent}; }

CornerRadiusAll :: inline (r: float) -> CornerRadius { return .{r, r, r, r}; }



// Utility Structs -------------------------
// Note: Clay_String is not guaranteed to be null terminated. It may be if created from a literal C string,
// but it is also used to represent slices.
String :: struct {
    length: s32;
    chars:  *u8;
}

StringArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *String;
}

StringSlice :: struct {
    length:    s32;
    chars:     *u8;
    baseChars: *u8; // The source string / char* that this slice was derived from
}

Arena :: struct {
    nextAllocation: u64;
    capacity:       u64;
    memory:         *u8;
}

Dimensions :: struct {
    width:  float;
    height: float;
}

Vector2 :: struct {
    x: float;
    y: float;
}

Color :: struct {
    r: float;
    g: float;
    b: float;
    a: float;
}

BoundingBox :: struct {
    x:      float;
    y:      float;
    width:  float;
    height: float;
}

// baseId + offset = id
ElementId :: struct {
    id:       u32;
    offset:   u32;
    baseId:   u32;
    stringId: String;
}

CornerRadius :: struct {
    topLeft:     float;
    topRight:    float;
    bottomLeft:  float;
    bottomRight: float;
}

ElementConfigType :: enum s32 {
    NONE               :: 0;
    RECTANGLE          :: 1;
    BORDER_CONTAINER   :: 2;
    FLOATING_CONTAINER :: 4;
    SCROLL_CONTAINER   :: 8;
    IMAGE              :: 16;
    TEXT               :: 32;
    CUSTOM             :: 64;
    CLAY__ELEMENT_CONFIG_TYPE_NONE               :: NONE;
    CLAY__ELEMENT_CONFIG_TYPE_RECTANGLE          :: RECTANGLE;
    CLAY__ELEMENT_CONFIG_TYPE_BORDER_CONTAINER   :: BORDER_CONTAINER;
    CLAY__ELEMENT_CONFIG_TYPE_FLOATING_CONTAINER :: FLOATING_CONTAINER;
    CLAY__ELEMENT_CONFIG_TYPE_SCROLL_CONTAINER   :: SCROLL_CONTAINER;
    CLAY__ELEMENT_CONFIG_TYPE_IMAGE              :: IMAGE;
    CLAY__ELEMENT_CONFIG_TYPE_TEXT               :: TEXT;
    CLAY__ELEMENT_CONFIG_TYPE_CUSTOM             :: CUSTOM;
}

LayoutDirection :: enum s32 {
    LEFT_TO_RIGHT :: 0;
    TOP_TO_BOTTOM :: 1;
    CLAY_LEFT_TO_RIGHT :: LEFT_TO_RIGHT;
    CLAY_TOP_TO_BOTTOM :: TOP_TO_BOTTOM;
}

LayoutAlignmentX :: enum s32 {
    LEFT   :: 0;
    RIGHT  :: 1;
    CENTER :: 2;
    CLAY_ALIGN_X_LEFT   :: LEFT;
    CLAY_ALIGN_X_RIGHT  :: RIGHT;
    CLAY_ALIGN_X_CENTER :: CENTER;
}

LayoutAlignmentY :: enum s32 {
    TOP    :: 0;
    BOTTOM :: 1;
    CENTER :: 2;
    CLAY_ALIGN_Y_TOP    :: TOP;
    CLAY_ALIGN_Y_BOTTOM :: BOTTOM;
    CLAY_ALIGN_Y_CENTER :: CENTER;
}

SizingType :: enum s32 {
    FIT     :: 0;
    GROW    :: 1;
    PERCENT :: 2;
    FIXED   :: 3;
    CLAY__SIZING_TYPE_FIT     :: FIT;
    CLAY__SIZING_TYPE_GROW    :: GROW;
    CLAY__SIZING_TYPE_PERCENT :: PERCENT;
    CLAY__SIZING_TYPE_FIXED   :: FIXED;
}

ChildAlignment :: struct {
    x: LayoutAlignmentX;
    y: LayoutAlignmentY;
}

SizingMinMax :: struct {
    min: float;
    max: float;
}

SizingAxis :: struct {
    size: union {
        minMax:  SizingMinMax;
        percent: float;
    };
    type: SizingType;
}

Sizing :: struct {
    width:  SizingAxis;
    height: SizingAxis;
}

Padding :: struct {
    left:   u16;
    right:  u16;
    top:    u16;
    bottom: u16;
}

LayoutConfig :: struct {
    sizing:          Sizing;
    padding:         Padding;
    childGap:        u16;
    childAlignment:  ChildAlignment;
    layoutDirection: LayoutDirection;
}

LAYOUT_DEFAULT: LayoutConfig #elsewhere clay "CLAY_LAYOUT_DEFAULT"; // __GENERATED__ template

// Rectangle
// NOTE: Not declared in the typedef as an ifdef inside macro arguments is UB
RectangleElementConfig :: struct {
    color:        Color;
    cornerRadius: CornerRadius;
}

// Text
TextElementConfigWrapMode :: enum s32 {
    WORDS    :: 0;
    NEWLINES :: 1;
    NONE     :: 2;
    CLAY_TEXT_WRAP_WORDS    :: WORDS;
    CLAY_TEXT_WRAP_NEWLINES :: NEWLINES;
    CLAY_TEXT_WRAP_NONE     :: NONE;
}

TextElementConfig :: struct {
    textColor:     Color;
    fontId:        u16;
    fontSize:      u16;
    letterSpacing: u16;
    lineHeight:    u16;
    wrapMode:      TextElementConfigWrapMode;
}

// Image
ImageElementConfig :: struct {
    imageData:        *void;
    sourceDimensions: Dimensions;
}

FloatingAttachPointType :: enum s32 {
    LEFT_TOP      :: 0;
    LEFT_CENTER   :: 1;
    LEFT_BOTTOM   :: 2;
    CENTER_TOP    :: 3;
    CENTER_CENTER :: 4;
    CENTER_BOTTOM :: 5;
    RIGHT_TOP     :: 6;
    RIGHT_CENTER  :: 7;
    RIGHT_BOTTOM  :: 8;
    CLAY_ATTACH_POINT_LEFT_TOP      :: LEFT_TOP;
    CLAY_ATTACH_POINT_LEFT_CENTER   :: LEFT_CENTER;
    CLAY_ATTACH_POINT_LEFT_BOTTOM   :: LEFT_BOTTOM;
    CLAY_ATTACH_POINT_CENTER_TOP    :: CENTER_TOP;
    CLAY_ATTACH_POINT_CENTER_CENTER :: CENTER_CENTER;
    CLAY_ATTACH_POINT_CENTER_BOTTOM :: CENTER_BOTTOM;
    CLAY_ATTACH_POINT_RIGHT_TOP     :: RIGHT_TOP;
    CLAY_ATTACH_POINT_RIGHT_CENTER  :: RIGHT_CENTER;
    CLAY_ATTACH_POINT_RIGHT_BOTTOM  :: RIGHT_BOTTOM;
}

FloatingAttachPoints :: struct {
    element: FloatingAttachPointType;
    parent:  FloatingAttachPointType;
}

PointerCaptureMode :: enum s32 {
    CAPTURE     :: 0;
    PASSTHROUGH :: 1;
    CLAY_POINTER_CAPTURE_MODE_CAPTURE     :: CAPTURE;
    CLAY_POINTER_CAPTURE_MODE_PASSTHROUGH :: PASSTHROUGH;
}

FloatingElementConfig :: struct {
    offset:             Vector2;
    expand:             Dimensions;
    zIndex:             u16;
    parentId:           u32;
    attachment:         FloatingAttachPoints;
    pointerCaptureMode: PointerCaptureMode;
}

// Custom
CustomElementConfig :: struct {
    customData: *void;
}

// Scroll
ScrollElementConfig :: struct {
    horizontal: bool;
    vertical:   bool;
}

// Border
BorderData :: struct {
    width: u32;
    color: Color;
}

BorderElementConfig :: struct {
    left:            BorderData;
    right:           BorderData;
    top:             BorderData;
    bottom:          BorderData;
    betweenChildren: BorderData;
    cornerRadius:    CornerRadius;
}

ElementConfigUnion :: union {
    rectangleElementConfig: *RectangleElementConfig;
    textElementConfig:      *TextElementConfig;
    imageElementConfig:     *ImageElementConfig;
    floatingElementConfig:  *FloatingElementConfig;
    customElementConfig:    *CustomElementConfig;
    scrollElementConfig:    *ScrollElementConfig;
    borderElementConfig:    *BorderElementConfig;
}

ElementConfig :: struct {
    type:   ElementConfigType;
    config: ElementConfigUnion;
}

// Miscellaneous Structs & Enums ---------------------------------
ScrollContainerData :: struct {
    // Note: This is a pointer to the real internal scroll position, mutating it may cause a change in final layout.
    // Intended for use with external functionality that modifies scroll position, such as scroll bars or auto scrolling.
    scrollPosition:            *Vector2;
    scrollContainerDimensions: Dimensions;
    contentDimensions:         Dimensions;
    config:                    ScrollElementConfig;
    found:                     bool;
}

ElementData :: struct {
    boundingBox: BoundingBox;
    found:       bool;
}

RenderCommandType :: enum s32 {
    NONE          :: 0;
    RECTANGLE     :: 1;
    BORDER        :: 2;
    TEXT          :: 3;
    IMAGE         :: 4;
    SCISSOR_START :: 5;
    SCISSOR_END   :: 6;
    CUSTOM        :: 7;
    CLAY_RENDER_COMMAND_TYPE_NONE          :: NONE;
    CLAY_RENDER_COMMAND_TYPE_RECTANGLE     :: RECTANGLE;
    CLAY_RENDER_COMMAND_TYPE_BORDER        :: BORDER;
    CLAY_RENDER_COMMAND_TYPE_TEXT          :: TEXT;
    CLAY_RENDER_COMMAND_TYPE_IMAGE         :: IMAGE;
    CLAY_RENDER_COMMAND_TYPE_SCISSOR_START :: SCISSOR_START;
    CLAY_RENDER_COMMAND_TYPE_SCISSOR_END   :: SCISSOR_END;
    CLAY_RENDER_COMMAND_TYPE_CUSTOM        :: CUSTOM;
}

RenderCommand :: struct {
    boundingBox: BoundingBox;
    config:      ElementConfigUnion;
    text:        String; // TODO I wish there was a way to avoid having to have this on every render command
    id:          u32;
    commandType: RenderCommandType;
}

RenderCommandArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *RenderCommand;
}

PointerDataInteractionState :: enum s32 {
    PRESSED_THIS_FRAME  :: 0;
    PRESSED             :: 1;
    RELEASED_THIS_FRAME :: 2;
    RELEASED            :: 3;
    CLAY_POINTER_DATA_PRESSED_THIS_FRAME  :: PRESSED_THIS_FRAME;
    CLAY_POINTER_DATA_PRESSED             :: PRESSED;
    CLAY_POINTER_DATA_RELEASED_THIS_FRAME :: RELEASED_THIS_FRAME;
    CLAY_POINTER_DATA_RELEASED            :: RELEASED;
}

PointerData :: struct {
    position: Vector2;
    state:    PointerDataInteractionState;
}

ErrorType :: enum s32 {
    TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED :: 0;
    ARENA_CAPACITY_EXCEEDED                :: 1;
    ELEMENTS_CAPACITY_EXCEEDED             :: 2;
    TEXT_MEASUREMENT_CAPACITY_EXCEEDED     :: 3;
    DUPLICATE_ID                           :: 4;
    FLOATING_CONTAINER_PARENT_NOT_FOUND    :: 5;
    INTERNAL_ERROR                         :: 6;
    CLAY_ERROR_TYPE_TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED :: TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED;
    CLAY_ERROR_TYPE_ARENA_CAPACITY_EXCEEDED                :: ARENA_CAPACITY_EXCEEDED;
    CLAY_ERROR_TYPE_ELEMENTS_CAPACITY_EXCEEDED             :: ELEMENTS_CAPACITY_EXCEEDED;
    CLAY_ERROR_TYPE_TEXT_MEASUREMENT_CAPACITY_EXCEEDED     :: TEXT_MEASUREMENT_CAPACITY_EXCEEDED;
    CLAY_ERROR_TYPE_DUPLICATE_ID                           :: DUPLICATE_ID;
    CLAY_ERROR_TYPE_FLOATING_CONTAINER_PARENT_NOT_FOUND    :: FLOATING_CONTAINER_PARENT_NOT_FOUND;
    CLAY_ERROR_TYPE_INTERNAL_ERROR                         :: INTERNAL_ERROR;
}

ErrorData :: struct {
    errorType: ErrorType;
    errorText: String;
    userData:  u64;
}

ErrorHandler :: struct {
    errorHandlerFunction: #type (errorText: ErrorData) -> void #c_call;
    userData:             u64;
}

// Function Forward Declarations ---------------------------------
// Public API functions ---
MinMemorySize :: () -> u32 #foreign clay "Clay_MinMemorySize";

CreateArenaWithCapacityAndMemory :: (capacity: u32, offset: *void) -> Arena #foreign clay "Clay_CreateArenaWithCapacityAndMemory";

SetPointerState :: (position: Vector2, pointerDown: bool) -> void #foreign clay "Clay_SetPointerState";

Initialize :: (arena: Arena, layoutDimensions: Dimensions, errorHandler: ErrorHandler) -> *Context #foreign clay "Clay_Initialize";

GetCurrentContext :: () -> *Context #foreign clay "Clay_GetCurrentContext";

SetCurrentContext :: (_context: *Context) -> void #foreign clay "Clay_SetCurrentContext";

UpdateScrollContainers :: (enableDragScrolling: bool, scrollDelta: Vector2, deltaTime: float) -> void #foreign clay "Clay_UpdateScrollContainers";

SetLayoutDimensions :: (dimensions: Dimensions) -> void #foreign clay "Clay_SetLayoutDimensions";

BeginLayout :: () -> void #foreign clay "Clay_BeginLayout";

EndLayout :: () -> RenderCommandArray #foreign clay "Clay_EndLayout";

GetElementId :: (idString: String) -> ElementId #foreign clay "Clay_GetElementId";

GetElementIdWithIndex :: (idString: String, index: u32) -> ElementId #foreign clay "Clay_GetElementIdWithIndex";

GetElementData :: (id: ElementId) -> ElementData #foreign clay "Clay_GetElementData";

Hovered :: () -> bool #foreign clay "Clay_Hovered";

OnHover :: (onHoverFunction: #type (elementId: ElementId, pointerData: PointerData, userData: s64) -> void #c_call, userData: s64) -> void #foreign clay "Clay_OnHover";

PointerOver :: (elementId: ElementId) -> bool #foreign clay "Clay_PointerOver";

GetScrollContainerData :: (id: ElementId) -> ScrollContainerData #foreign clay "Clay_GetScrollContainerData";

SetMeasureTextFunction :: (measureTextFunction: #type (text: StringSlice, config: *TextElementConfig, userData: u64) -> Dimensions #c_call, userData: u64) -> void #foreign clay "Clay_SetMeasureTextFunction";

SetQueryScrollOffsetFunction :: (queryScrollOffsetFunction: #type (elementId: u32, userData: u64) -> Vector2 #c_call, userData: u64) -> void #foreign clay "Clay_SetQueryScrollOffsetFunction";

RenderCommandArray_Get :: (array: *RenderCommandArray, index: s32) -> *RenderCommand #foreign clay "Clay_RenderCommandArray_Get";

SetDebugModeEnabled :: (enabled: bool) -> void #foreign clay "Clay_SetDebugModeEnabled";

IsDebugModeEnabled :: () -> bool #foreign clay "Clay_IsDebugModeEnabled";

SetCullingEnabled :: (enabled: bool) -> void #foreign clay "Clay_SetCullingEnabled";

GetMaxElementCount :: () -> s32 #foreign clay "Clay_GetMaxElementCount";

SetMaxElementCount :: (maxElementCount: s32) -> void #foreign clay "Clay_SetMaxElementCount";

GetMaxMeasureTextCacheWordCount :: () -> s32 #foreign clay "Clay_GetMaxMeasureTextCacheWordCount";

SetMaxMeasureTextCacheWordCount :: (maxMeasureTextCacheWordCount: s32) -> void #foreign clay "Clay_SetMaxMeasureTextCacheWordCount";

ResetMeasureTextCache :: () -> void #foreign clay "Clay_ResetMeasureTextCache";

// Internal API functions required by macros
OpenElement :: () -> void #foreign clay "Clay__OpenElement";

CloseElement :: () -> void #foreign clay "Clay__CloseElement";

StoreLayoutConfig :: (config: LayoutConfig) -> *LayoutConfig #foreign clay "Clay__StoreLayoutConfig";

ElementPostConfiguration :: () -> void #foreign clay "Clay__ElementPostConfiguration";

AttachId :: (id: ElementId) -> void #foreign clay "Clay__AttachId";

AttachLayoutConfig :: (config: *LayoutConfig) -> void #foreign clay "Clay__AttachLayoutConfig";

AttachElementConfig :: (config: ElementConfigUnion, type: ElementConfigType) -> void #foreign clay "Clay__AttachElementConfig";

StoreRectangleElementConfig :: (config: RectangleElementConfig) -> *RectangleElementConfig #foreign clay "Clay__StoreRectangleElementConfig";
StoreTextElementConfig :: (config: TextElementConfig) -> *TextElementConfig #foreign clay "Clay__StoreTextElementConfig";
StoreImageElementConfig :: (config: ImageElementConfig) -> *ImageElementConfig #foreign clay "Clay__StoreImageElementConfig";
StoreFloatingElementConfig :: (config: FloatingElementConfig) -> *FloatingElementConfig #foreign clay "Clay__StoreFloatingElementConfig";
StoreCustomElementConfig :: (config: CustomElementConfig) -> *CustomElementConfig #foreign clay "Clay__StoreCustomElementConfig";
StoreScrollElementConfig :: (config: ScrollElementConfig) -> *ScrollElementConfig #foreign clay "Clay__StoreScrollElementConfig";
StoreBorderElementConfig :: (config: BorderElementConfig) -> *BorderElementConfig #foreign clay "Clay__StoreBorderElementConfig";

HashString :: (key: String, offset: u32, seed: u32) -> ElementId #foreign clay "Clay__HashString";

OpenTextElement :: (text: String, textConfig: *TextElementConfig) -> void #foreign clay "Clay__OpenTextElement";

GetParentElementId :: () -> u32 #foreign clay "Clay__GetParentElementId";

debugViewHighlightColor: Color #elsewhere clay "Clay__debugViewHighlightColor";
debugViewWidth: u32 #elsewhere clay "Clay__debugViewWidth";

currentContext: *Context #elsewhere clay "Clay__currentContext";
defaultMaxElementCount: s32 #elsewhere clay "Clay__defaultMaxElementCount";
defaultMaxMeasureTextWordCacheCount: s32 #elsewhere clay "Clay__defaultMaxMeasureTextWordCacheCount";

ErrorHandlerFunctionDefault :: (errorText: ErrorData) -> void #foreign clay "Clay__ErrorHandlerFunctionDefault";

SPACECHAR: String #elsewhere clay "CLAY__SPACECHAR";
STRING_DEFAULT: String #elsewhere clay "CLAY__STRING_DEFAULT";

BooleanWarnings :: struct {
    maxElementsExceeded:           bool;
    maxRenderCommandsExceeded:     bool;
    maxTextMeasureCacheExceeded:   bool;
    textMeasurementFunctionNotSet: bool;
}

Warning :: struct {
    baseMessage:    String;
    dynamicMessage: String;
}

WARNING_DEFAULT: Warning #elsewhere clay "CLAY__WARNING_DEFAULT";

WarningArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *Warning;
}

WarningArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> WarningArray #foreign clay "Clay__WarningArray_Allocate_Arena";

WarningArray_Add :: (array: *WarningArray, item: Warning) -> *Warning #foreign clay "Clay__WarningArray_Add";

Array_Allocate_Arena :: (capacity: s32, itemSize: u32, alignment: u32, arena: *Arena) -> *void #foreign clay "Clay__Array_Allocate_Arena";

Array_RangeCheck :: (index: s32, length: s32) -> bool #foreign clay "Clay__Array_RangeCheck";

Array_AddCapacityCheck :: (length: s32, capacity: s32) -> bool #foreign clay "Clay__Array_AddCapacityCheck";

BoolArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *bool;
}

BoolArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> BoolArray #foreign clay "Clay__BoolArray_Allocate_Arena";

// __GENERATED__ template
ELEMENT_ID_DEFAULT: ElementId #elsewhere clay "CLAY__ELEMENT_ID_DEFAULT";

ElementIdArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *ElementId;
}

ElementIdArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> ElementIdArray #foreign clay "Clay__ElementIdArray_Allocate_Arena";

ElementIdArray_Get :: (array: *ElementIdArray, index: s32) -> *ElementId #foreign clay "Clay__ElementIdArray_Get";

ElementIdArray_Add :: (array: *ElementIdArray, item: ElementId) -> *ElementId #foreign clay "Clay__ElementIdArray_Add";

// __GENERATED__ template
ELEMENT_CONFIG_DEFAULT: ElementConfig #elsewhere clay "CLAY__ELEMENT_CONFIG_DEFAULT";

ElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *ElementConfig;
}

ElementConfigArraySlice :: struct {
    length:        s32;
    internalArray: *ElementConfig;
}

ElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> ElementConfigArray #foreign clay "Clay__ElementConfigArray_Allocate_Arena";

ElementConfigArray_Get :: (array: *ElementConfigArray, index: s32) -> *ElementConfig #foreign clay "Clay__ElementConfigArray_Get";

ElementConfigArray_Add :: (array: *ElementConfigArray, item: ElementConfig) -> *ElementConfig #foreign clay "Clay__ElementConfigArray_Add";

ElementConfigArraySlice_Get :: (slice: *ElementConfigArraySlice, index: s32) -> *ElementConfig #foreign clay "Clay__ElementConfigArraySlice_Get";

LayoutConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *LayoutConfig;
}

LayoutConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutConfigArray #foreign clay "Clay__LayoutConfigArray_Allocate_Arena";

LayoutConfigArray_Add :: (array: *LayoutConfigArray, item: LayoutConfig) -> *LayoutConfig #foreign clay "Clay__LayoutConfigArray_Add";

// __GENERATED__ template
RECTANGLE_ELEMENT_CONFIG_DEFAULT: RectangleElementConfig #elsewhere clay "CLAY__RECTANGLE_ELEMENT_CONFIG_DEFAULT";

RectangleElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *RectangleElementConfig;
}

RectangleElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> RectangleElementConfigArray #foreign clay "Clay__RectangleElementConfigArray_Allocate_Arena";

RectangleElementConfigArray_Add :: (array: *RectangleElementConfigArray, item: RectangleElementConfig) -> *RectangleElementConfig #foreign clay "Clay__RectangleElementConfigArray_Add";

// __GENERATED__ template
TEXT_ELEMENT_CONFIG_DEFAULT: TextElementConfig #elsewhere clay "CLAY__TEXT_ELEMENT_CONFIG_DEFAULT";

TextElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *TextElementConfig;
}

TextElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> TextElementConfigArray #foreign clay "Clay__TextElementConfigArray_Allocate_Arena";

TextElementConfigArray_Add :: (array: *TextElementConfigArray, item: TextElementConfig) -> *TextElementConfig #foreign clay "Clay__TextElementConfigArray_Add";

// __GENERATED__ template
IMAGE_ELEMENT_CONFIG_DEFAULT: ImageElementConfig #elsewhere clay "CLAY__IMAGE_ELEMENT_CONFIG_DEFAULT";

ImageElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *ImageElementConfig;
}

ImageElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> ImageElementConfigArray #foreign clay "Clay__ImageElementConfigArray_Allocate_Arena";

ImageElementConfigArray_Add :: (array: *ImageElementConfigArray, item: ImageElementConfig) -> *ImageElementConfig #foreign clay "Clay__ImageElementConfigArray_Add";

// __GENERATED__ template
FLOATING_ELEMENT_CONFIG_DEFAULT: FloatingElementConfig #elsewhere clay "CLAY__FLOATING_ELEMENT_CONFIG_DEFAULT";

FloatingElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *FloatingElementConfig;
}

FloatingElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> FloatingElementConfigArray #foreign clay "Clay__FloatingElementConfigArray_Allocate_Arena";

FloatingElementConfigArray_Add :: (array: *FloatingElementConfigArray, item: FloatingElementConfig) -> *FloatingElementConfig #foreign clay "Clay__FloatingElementConfigArray_Add";

// __GENERATED__ template
CUSTOM_ELEMENT_CONFIG_DEFAULT: CustomElementConfig #elsewhere clay "CLAY__CUSTOM_ELEMENT_CONFIG_DEFAULT";

CustomElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *CustomElementConfig;
}

CustomElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> CustomElementConfigArray #foreign clay "Clay__CustomElementConfigArray_Allocate_Arena";

CustomElementConfigArray_Add :: (array: *CustomElementConfigArray, item: CustomElementConfig) -> *CustomElementConfig #foreign clay "Clay__CustomElementConfigArray_Add";

// __GENERATED__ template
SCROLL_ELEMENT_CONFIG_DEFAULT: ScrollElementConfig #elsewhere clay "CLAY__SCROLL_ELEMENT_CONFIG_DEFAULT";

ScrollElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *ScrollElementConfig;
}

ScrollElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> ScrollElementConfigArray #foreign clay "Clay__ScrollElementConfigArray_Allocate_Arena";

ScrollElementConfigArray_Add :: (array: *ScrollElementConfigArray, item: ScrollElementConfig) -> *ScrollElementConfig #foreign clay "Clay__ScrollElementConfigArray_Add";

StringArraySlice :: struct {
    length:        s32;
    internalArray: *String;
}

StringArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> StringArray #foreign clay "Clay__StringArray_Allocate_Arena";

StringArray_Add :: (array: *StringArray, item: String) -> *String #foreign clay "Clay__StringArray_Add";

// __GENERATED__ template
WrappedTextLine :: struct {
    dimensions: Dimensions;
    line:       String;
}

WRAPPED_TEXT_LINE_DEFAULT: WrappedTextLine #elsewhere clay "CLAY__WRAPPED_TEXT_LINE_DEFAULT";

WrappedTextLineArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *WrappedTextLine;
}

WrappedTextLineArraySlice :: struct {
    length:        s32;
    internalArray: *WrappedTextLine;
}

WrappedTextLineArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> WrappedTextLineArray #foreign clay "Clay__WrappedTextLineArray_Allocate_Arena";

WrappedTextLineArray_Add :: (array: *WrappedTextLineArray, item: WrappedTextLine) -> *WrappedTextLine #foreign clay "Clay__WrappedTextLineArray_Add";

WrappedTextLineArray_Get :: (array: *WrappedTextLineArray, index: s32) -> *WrappedTextLine #foreign clay "Clay__WrappedTextLineArray_Get";

// __GENERATED__ template
TextElementData :: struct {
    text:                String;
    preferredDimensions: Dimensions;
    elementIndex:        s32;
    wrappedLines:        WrappedTextLineArraySlice;
}

TEXT_ELEMENT_DATA_DEFAULT: TextElementData #elsewhere clay "CLAY__TEXT_ELEMENT_DATA_DEFAULT";

TextElementDataArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *TextElementData;
}

TextElementDataArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> TextElementDataArray #foreign clay "Clay__TextElementDataArray_Allocate_Arena";

TextElementDataArray_Get :: (array: *TextElementDataArray, index: s32) -> *TextElementData #foreign clay "Clay__TextElementDataArray_Get";

TextElementDataArray_Add :: (array: *TextElementDataArray, item: TextElementData) -> *TextElementData #foreign clay "Clay__TextElementDataArray_Add";

// __GENERATED__ template
BORDER_ELEMENT_CONFIG_DEFAULT: BorderElementConfig #elsewhere clay "CLAY__BORDER_ELEMENT_CONFIG_DEFAULT";

BorderElementConfigArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *BorderElementConfig;
}

BorderElementConfigArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> BorderElementConfigArray #foreign clay "Clay__BorderElementConfigArray_Allocate_Arena";

BorderElementConfigArray_Add :: (array: *BorderElementConfigArray, item: BorderElementConfig) -> *BorderElementConfig #foreign clay "Clay__BorderElementConfigArray_Add";

// __GENERATED__ template
LayoutElementChildren :: struct {
    elements: *s32;
    length:   u16;
}

LayoutElement :: struct {
    childrenOrTextContent: union {
        children:        LayoutElementChildren;
        textElementData: *TextElementData;
    };
    dimensions:            Dimensions;
    minDimensions:         Dimensions;
    layoutConfig:          *LayoutConfig;
    elementConfigs:        ElementConfigArraySlice;
    configsEnabled:        u32;
    id:                    u32;
}

LAYOUT_ELEMENT_DEFAULT: LayoutElement #elsewhere clay "CLAY__LAYOUT_ELEMENT_DEFAULT";

LayoutElementArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *LayoutElement;
}

LayoutElementArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutElementArray #foreign clay "Clay_LayoutElementArray_Allocate_Arena";

LayoutElementArray_Add :: (array: *LayoutElementArray, item: LayoutElement) -> *LayoutElement #foreign clay "Clay_LayoutElementArray_Add";

LayoutElementArray_Get :: (array: *LayoutElementArray, index: s32) -> *LayoutElement #foreign clay "Clay_LayoutElementArray_Get";

LayoutElementPointerArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: **LayoutElement;
}

LayoutElementPointerArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutElementPointerArray #foreign clay "Clay__LayoutElementPointerArray_Allocate_Arena";

LayoutElementPointerArray_Add :: (array: *LayoutElementPointerArray, item: *LayoutElement) -> **LayoutElement #foreign clay "Clay__LayoutElementPointerArray_Add";

LayoutElementPointerArray_Get :: (array: *LayoutElementPointerArray, index: s32) -> *LayoutElement #foreign clay "Clay__LayoutElementPointerArray_Get";

LayoutElementPointerArray_RemoveSwapback :: (array: *LayoutElementPointerArray, index: s32) -> *LayoutElement #foreign clay "Clay__LayoutElementPointerArray_RemoveSwapback";

// __GENERATED__ template
RENDER_COMMAND_DEFAULT: RenderCommand #elsewhere clay "CLAY__RENDER_COMMAND_DEFAULT";

RenderCommandArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> RenderCommandArray #foreign clay "Clay_RenderCommandArray_Allocate_Arena";

RenderCommandArray_Add :: (array: *RenderCommandArray, item: RenderCommand) -> *RenderCommand #foreign clay "Clay_RenderCommandArray_Add";

// __GENERATED__ template
ScrollContainerDataInternal :: struct {
    layoutElement:       *LayoutElement;
    boundingBox:         BoundingBox;
    contentSize:         Dimensions;
    scrollOrigin:        Vector2;
    pointerOrigin:       Vector2;
    scrollMomentum:      Vector2;
    scrollPosition:      Vector2;
    previousDelta:       Vector2;
    momentumTime:        float;
    elementId:           u32;
    openThisFrame:       bool;
    pointerScrollActive: bool;
}

SCROLL_CONTAINER_DEFAULT: ScrollContainerDataInternal #elsewhere clay "CLAY__SCROLL_CONTAINER_DEFAULT";

ScrollContainerDataInternalArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *ScrollContainerDataInternal;
}

ScrollContainerDataInternalArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> ScrollContainerDataInternalArray #foreign clay "Clay__ScrollContainerDataInternalArray_Allocate_Arena";

ScrollContainerDataInternalArray_Add :: (array: *ScrollContainerDataInternalArray, item: ScrollContainerDataInternal) -> *ScrollContainerDataInternal #foreign clay "Clay__ScrollContainerDataInternalArray_Add";

ScrollContainerDataInternalArray_Get :: (array: *ScrollContainerDataInternalArray, index: s32) -> *ScrollContainerDataInternal #foreign clay "Clay__ScrollContainerDataInternalArray_Get";

ScrollContainerDataInternalArray_RemoveSwapback :: (array: *ScrollContainerDataInternalArray, index: s32) -> ScrollContainerDataInternal #foreign clay "Clay__ScrollContainerDataInternalArray_RemoveSwapback";

// __GENERATED__ template
DebugElementData :: struct {
    collision: bool;
    collapsed: bool;
}

DEBUG_ELEMENT_DATA_DEFAULT: DebugElementData #elsewhere clay "CLAY__DEBUG_ELEMENT_DATA_DEFAULT";

DebugElementDataArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *DebugElementData;
}

DebugElementDataArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> DebugElementDataArray #foreign clay "Clay__DebugElementDataArray_Allocate_Arena";

DebugElementDataArray_Add :: (array: *DebugElementDataArray, item: DebugElementData) -> *DebugElementData #foreign clay "Clay__DebugElementDataArray_Add";

DebugElementDataArray_Get :: (array: *DebugElementDataArray, index: s32) -> *DebugElementData #foreign clay "Clay__DebugElementDataArray_Get";

// __GENERATED__ template
LayoutElementHashMapItem :: struct {
    boundingBox:           BoundingBox;
    elementId:             ElementId;
    layoutElement:         *LayoutElement;
    onHoverFunction:       #type (elementId: ElementId, pointerInfo: PointerData, userData: s64) -> void #c_call;
    hoverFunctionUserData: s64;
    nextIndex:             s32;
    generation:            u32;
    debugData:             *DebugElementData;
}

LAYOUT_ELEMENT_HASH_MAP_ITEM_DEFAULT: LayoutElementHashMapItem #elsewhere clay "CLAY__LAYOUT_ELEMENT_HASH_MAP_ITEM_DEFAULT";

LayoutElementHashMapItemArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *LayoutElementHashMapItem;
}

LayoutElementHashMapItemArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutElementHashMapItemArray #foreign clay "Clay__LayoutElementHashMapItemArray_Allocate_Arena";

LayoutElementHashMapItemArray_Get :: (array: *LayoutElementHashMapItemArray, index: s32) -> *LayoutElementHashMapItem #foreign clay "Clay__LayoutElementHashMapItemArray_Get";

LayoutElementHashMapItemArray_Add :: (array: *LayoutElementHashMapItemArray, item: LayoutElementHashMapItem) -> *LayoutElementHashMapItem #foreign clay "Clay__LayoutElementHashMapItemArray_Add";

// __GENERATED__ template
MeasuredWord :: struct {
    startOffset: s32;
    length:      s32;
    width:       float;
    next:        s32;
}

MEASURED_WORD_DEFAULT: MeasuredWord #elsewhere clay "CLAY__MEASURED_WORD_DEFAULT";

MeasuredWordArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *MeasuredWord;
}

MeasuredWordArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> MeasuredWordArray #foreign clay "Clay__MeasuredWordArray_Allocate_Arena";

MeasuredWordArray_Get :: (array: *MeasuredWordArray, index: s32) -> *MeasuredWord #foreign clay "Clay__MeasuredWordArray_Get";

MeasuredWordArray_Set :: (array: *MeasuredWordArray, index: s32, value: MeasuredWord) -> void #foreign clay "Clay__MeasuredWordArray_Set";

MeasuredWordArray_Add :: (array: *MeasuredWordArray, item: MeasuredWord) -> *MeasuredWord #foreign clay "Clay__MeasuredWordArray_Add";

// __GENERATED__ template
MeasureTextCacheItem :: struct {
    unwrappedDimensions:     Dimensions;
    measuredWordsStartIndex: s32;
    containsNewlines:        bool;
    id:                      u32; // Hash map data
    nextIndex:               s32;
    generation:              u32;
}

MEASURE_TEXT_CACHE_ITEM_DEFAULT: MeasureTextCacheItem #elsewhere clay "CLAY__MEASURE_TEXT_CACHE_ITEM_DEFAULT";

MeasureTextCacheItemArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *MeasureTextCacheItem;
}

MeasureTextCacheItemArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> MeasureTextCacheItemArray #foreign clay "Clay__MeasureTextCacheItemArray_Allocate_Arena";

MeasureTextCacheItemArray_Get :: (array: *MeasureTextCacheItemArray, index: s32) -> *MeasureTextCacheItem #foreign clay "Clay__MeasureTextCacheItemArray_Get";

MeasureTextCacheItemArray_Add :: (array: *MeasureTextCacheItemArray, item: MeasureTextCacheItem) -> *MeasureTextCacheItem #foreign clay "Clay__MeasureTextCacheItemArray_Add";

MeasureTextCacheItemArray_Set :: (array: *MeasureTextCacheItemArray, index: s32, value: MeasureTextCacheItem) -> void #foreign clay "Clay__MeasureTextCacheItemArray_Set";

int32_tArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *s32;
}

int32_tArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> int32_tArray #foreign clay "Clay__int32_tArray_Allocate_Arena";

int32_tArray_Get :: (array: *int32_tArray, index: s32) -> s32 #foreign clay "Clay__int32_tArray_Get";

int32_tArray_Add :: (array: *int32_tArray, item: s32) -> void #foreign clay "Clay__int32_tArray_Add";

int32_tArray_Set :: (array: *int32_tArray, index: s32, value: s32) -> void #foreign clay "Clay__int32_tArray_Set";

int32_tArray_RemoveSwapback :: (array: *int32_tArray, index: s32) -> s32 #foreign clay "Clay__int32_tArray_RemoveSwapback";

// __GENERATED__ template
LayoutElementTreeNode :: struct {
    layoutElement:   *LayoutElement;
    position:        Vector2;
    nextChildOffset: Vector2;
}

LAYOUT_ELEMENT_TREE_NODE_DEFAULT: LayoutElementTreeNode #elsewhere clay "CLAY__LAYOUT_ELEMENT_TREE_NODE_DEFAULT";

LayoutElementTreeNodeArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *LayoutElementTreeNode;
}

LayoutElementTreeNodeArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutElementTreeNodeArray #foreign clay "Clay__LayoutElementTreeNodeArray_Allocate_Arena";

LayoutElementTreeNodeArray_Add :: (array: *LayoutElementTreeNodeArray, item: LayoutElementTreeNode) -> *LayoutElementTreeNode #foreign clay "Clay__LayoutElementTreeNodeArray_Add";

LayoutElementTreeNodeArray_Get :: (array: *LayoutElementTreeNodeArray, index: s32) -> *LayoutElementTreeNode #foreign clay "Clay__LayoutElementTreeNodeArray_Get";

// __GENERATED__ template
LayoutElementTreeRoot :: struct {
    layoutElementIndex: s32;
    parentId:           u32; // This can be zero in the case of the root layout tree
    clipElementId:      u32; // This can be zero if there is no clip element
    zIndex:             s32;
    pointerOffset:      Vector2; // Only used when scroll containers are managed externally
}

LAYOUT_ELEMENT_TREE_ROOT_DEFAULT: LayoutElementTreeRoot #elsewhere clay "CLAY__LAYOUT_ELEMENT_TREE_ROOT_DEFAULT";

LayoutElementTreeRootArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *LayoutElementTreeRoot;
}

LayoutElementTreeRootArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> LayoutElementTreeRootArray #foreign clay "Clay__LayoutElementTreeRootArray_Allocate_Arena";

LayoutElementTreeRootArray_Add :: (array: *LayoutElementTreeRootArray, item: LayoutElementTreeRoot) -> *LayoutElementTreeRoot #foreign clay "Clay__LayoutElementTreeRootArray_Add";

LayoutElementTreeRootArray_Get :: (array: *LayoutElementTreeRootArray, index: s32) -> *LayoutElementTreeRoot #foreign clay "Clay__LayoutElementTreeRootArray_Get";

LayoutElementTreeRootArray_Set :: (array: *LayoutElementTreeRootArray, index: s32, value: LayoutElementTreeRoot) -> void #foreign clay "Clay__LayoutElementTreeRootArray_Set";

CharArray :: struct {
    capacity:      s32;
    length:        s32;
    internalArray: *u8;
}

CharArray_Allocate_Arena :: (capacity: s32, arena: *Arena) -> CharArray #foreign clay "Clay__CharArray_Allocate_Arena";

// __GENERATED__ template
Context :: struct {
    maxElementCount:                    s32;
    maxMeasureTextCacheWordCount:       s32;
    warningsEnabled:                    bool;
    errorHandler:                       ErrorHandler;
    booleanWarnings:                    BooleanWarnings;
    warnings:                           WarningArray;

    pointerInfo:                        PointerData;
    layoutDimensions:                   Dimensions;
    dynamicElementIndexBaseHash:        ElementId;
    dynamicElementIndex:                u32;
    debugModeEnabled:                   bool;
    disableCulling:                     bool;
    externalScrollHandlingEnabled:      bool;
    debugSelectedElementId:             u32;
    generation:                         u32;
    arenaResetOffset:                   u64;
    mesureTextUserData:                 u64;
    queryScrollOffsetUserData:          u64;
    internalArena:                      Arena;

    // Layout Elements / Render Commands
    layoutElements:                     LayoutElementArray;
    renderCommands:                     RenderCommandArray;
    openLayoutElementStack:             int32_tArray;
    layoutElementChildren:              int32_tArray;
    layoutElementChildrenBuffer:        int32_tArray;
    textElementData:                    TextElementDataArray;
    imageElementPointers:               LayoutElementPointerArray;
    reusableElementIndexBuffer:         int32_tArray;
    layoutElementClipElementIds:        int32_tArray;

    // Configs
    layoutConfigs:                      LayoutConfigArray;
    elementConfigBuffer:                ElementConfigArray;
    elementConfigs:                     ElementConfigArray;
    rectangleElementConfigs:            RectangleElementConfigArray;
    textElementConfigs:                 TextElementConfigArray;
    imageElementConfigs:                ImageElementConfigArray;
    floatingElementConfigs:             FloatingElementConfigArray;
    scrollElementConfigs:               ScrollElementConfigArray;
    customElementConfigs:               CustomElementConfigArray;
    borderElementConfigs:               BorderElementConfigArray;

    // Misc Data Structures
    layoutElementIdStrings:             StringArray;
    wrappedTextLines:                   WrappedTextLineArray;
    layoutElementTreeNodeArray1:        LayoutElementTreeNodeArray;
    layoutElementTreeRoots:             LayoutElementTreeRootArray;
    layoutElementsHashMapInternal:      LayoutElementHashMapItemArray;
    layoutElementsHashMap:              int32_tArray;
    measureTextHashMapInternal:         MeasureTextCacheItemArray;
    measureTextHashMapInternalFreeList: int32_tArray;
    measureTextHashMap:                 int32_tArray;
    measuredWords:                      MeasuredWordArray;
    measuredWordsFreeList:              int32_tArray;
    openClipElementStack:               int32_tArray;
    pointerOverIds:                     ElementIdArray;
    scrollContainerDatas:               ScrollContainerDataInternalArray;
    treeNodeVisited:                    BoolArray;
    dynamicStringData:                  CharArray;
    debugElementData:                   DebugElementDataArray;
}

Context_Allocate_Arena :: (arena: *Arena) -> *Context #foreign clay "Clay__Context_Allocate_Arena";

WriteStringToCharBuffer :: (buffer: *CharArray, _string: String) -> String #foreign clay "Clay__WriteStringToCharBuffer";

MeasureText: #type (text: StringSlice, config: *TextElementConfig, userData: u64) -> Dimensions #c_call #elsewhere clay "Clay__MeasureText";
QueryScrollOffset: #type (elementId: u32, userData: u64) -> Vector2 #c_call #elsewhere clay "Clay__QueryScrollOffset";

GetOpenLayoutElement :: () -> *LayoutElement #foreign clay "Clay__GetOpenLayoutElement";

ElementHasConfig :: (element: *LayoutElement, type: ElementConfigType) -> bool #foreign clay "Clay__ElementHasConfig";

FindElementConfigWithType :: (element: *LayoutElement, type: ElementConfigType) -> ElementConfigUnion #foreign clay "Clay__FindElementConfigWithType";

HashNumber :: (offset: u32, seed: u32) -> ElementId #foreign clay "Clay__HashNumber";

Rehash :: (elementId: ElementId, number: u32) -> ElementId #foreign clay "Clay__Rehash";

RehashWithNumber :: (id: u32, number: u32) -> u32 #foreign clay "Clay__RehashWithNumber";

HashTextWithConfig :: (text: *String, config: *TextElementConfig) -> u32 #foreign clay "Clay__HashTextWithConfig";

AddMeasuredWord :: (word: MeasuredWord, previousWord: *MeasuredWord) -> *MeasuredWord #foreign clay "Clay__AddMeasuredWord";

MeasureTextCached :: (text: *String, config: *TextElementConfig) -> *MeasureTextCacheItem #foreign clay "Clay__MeasureTextCached";

PointIsInsideRect :: (point: Vector2, rect: BoundingBox) -> bool #foreign clay "Clay__PointIsInsideRect";

AddHashMapItem :: (elementId: ElementId, layoutElement: *LayoutElement) -> *LayoutElementHashMapItem #foreign clay "Clay__AddHashMapItem";

GetHashMapItem :: (id: u32) -> *LayoutElementHashMapItem #foreign clay "Clay__GetHashMapItem";

GenerateIdForAnonymousElement :: (openLayoutElement: *LayoutElement) -> void #foreign clay "Clay__GenerateIdForAnonymousElement";

InitializeEphemeralMemory :: (_context: *Context) -> void #foreign clay "Clay__InitializeEphemeralMemory";

InitializePersistentMemory :: (_context: *Context) -> void #foreign clay "Clay__InitializePersistentMemory";

CompressChildrenAlongAxis :: (xAxis: bool, totalSizeToDistribute: float, resizableContainerBuffer: int32_tArray) -> void #foreign clay "Clay__CompressChildrenAlongAxis";

SizeContainersAlongAxis :: (xAxis: bool) -> void #foreign clay "Clay__SizeContainersAlongAxis";

IntToString :: (integer: s32) -> String #foreign clay "Clay__IntToString";

AddRenderCommand :: (renderCommand: RenderCommand) -> void #foreign clay "Clay__AddRenderCommand";

ElementIsOffscreen :: (boundingBox: *BoundingBox) -> bool #foreign clay "Clay__ElementIsOffscreen";

CalculateFinalLayout :: (__args: ..Any) -> void #foreign clay "Clay__CalculateFinalLayout";

DEBUGVIEW_COLOR_1: Color #elsewhere clay "CLAY__DEBUGVIEW_COLOR_1";
DEBUGVIEW_COLOR_2: Color #elsewhere clay "CLAY__DEBUGVIEW_COLOR_2";
DEBUGVIEW_COLOR_3: Color #elsewhere clay "CLAY__DEBUGVIEW_COLOR_3";
DEBUGVIEW_COLOR_4: Color #elsewhere clay "CLAY__DEBUGVIEW_COLOR_4";
DEBUGVIEW_COLOR_SELECTED_ROW: Color #elsewhere clay "CLAY__DEBUGVIEW_COLOR_SELECTED_ROW";

DebugView_TextNameConfig: TextElementConfig #elsewhere clay "Clay__DebugView_TextNameConfig";
DebugView_ScrollViewItemLayoutConfig: LayoutConfig #elsewhere clay "Clay__DebugView_ScrollViewItemLayoutConfig";

DebugElementConfigTypeLabelConfig :: struct {
    label: String;
    color: Color;
}

DebugGetElementConfigTypeLabel :: (type: ElementConfigType) -> DebugElementConfigTypeLabelConfig #foreign clay "Clay__DebugGetElementConfigTypeLabel";

RenderDebugLayoutData :: struct {
    rowCount:                s32;
    selectedElementRowIndex: s32;
}

// Returns row count
RenderDebugLayoutElementsList :: (initialRootsLength: s32, highlightedRowIndex: s32) -> RenderDebugLayoutData #foreign clay "Clay__RenderDebugLayoutElementsList";

RenderDebugLayoutSizing :: (sizing: SizingAxis, infoTextConfig: *TextElementConfig) -> void #foreign clay "Clay__RenderDebugLayoutSizing";

RenderDebugViewElementConfigHeader :: (elementId: String, type: ElementConfigType) -> void #foreign clay "Clay__RenderDebugViewElementConfigHeader";

RenderDebugViewColor :: (color: Color, textConfig: *TextElementConfig) -> void #foreign clay "Clay__RenderDebugViewColor";

RenderDebugViewCornerRadius :: (cornerRadius: CornerRadius, textConfig: *TextElementConfig) -> void #foreign clay "Clay__RenderDebugViewCornerRadius";

RenderDebugViewBorder :: (index: s32, border: BorderData, textConfig: *TextElementConfig) -> void #foreign clay "Clay__RenderDebugViewBorder";

HandleDebugViewCloseButtonInteraction :: (elementId: ElementId, pointerInfo: PointerData, userData: s64) -> void #foreign clay;

RenderDebugView :: (__args: ..Any) -> void #foreign clay "Clay__RenderDebugView";

DebugView_ErrorTextConfig: TextElementConfig #elsewhere clay "Clay__DebugView_ErrorTextConfig";

SetExternalScrollHandlingEnabled :: (enabled: bool) -> void #foreign clay "Clay_SetExternalScrollHandlingEnabled";

#scope_file

#import "Basic"; // For assert

clay :: #library,no_dll "windows/clay";

#run {
    {
        instance: String;
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 0, "String.length has unexpected offset % instead of 0", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(String.length)) == 4, "String.length has unexpected size % instead of 4", size_of(type_of(String.length)));
        assert(((cast(*void)(*instance.chars)) - cast(*void)(*instance)) == 8, "String.chars has unexpected offset % instead of 8", ((cast(*void)(*instance.chars)) - cast(*void)(*instance)));
        assert(size_of(type_of(String.chars)) == 8, "String.chars has unexpected size % instead of 8", size_of(type_of(String.chars)));
        assert(size_of(String) == 16, "String has size % instead of 16", size_of(String));
    }

    {
        instance: StringArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "StringArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringArray.capacity)) == 4, "StringArray.capacity has unexpected size % instead of 4", size_of(type_of(StringArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "StringArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringArray.length)) == 4, "StringArray.length has unexpected size % instead of 4", size_of(type_of(StringArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "StringArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringArray.internalArray)) == 8, "StringArray.internalArray has unexpected size % instead of 8", size_of(type_of(StringArray.internalArray)));
        assert(size_of(StringArray) == 16, "StringArray has size % instead of 16", size_of(StringArray));
    }

    {
        instance: StringSlice;
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 0, "StringSlice.length has unexpected offset % instead of 0", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringSlice.length)) == 4, "StringSlice.length has unexpected size % instead of 4", size_of(type_of(StringSlice.length)));
        assert(((cast(*void)(*instance.chars)) - cast(*void)(*instance)) == 8, "StringSlice.chars has unexpected offset % instead of 8", ((cast(*void)(*instance.chars)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringSlice.chars)) == 8, "StringSlice.chars has unexpected size % instead of 8", size_of(type_of(StringSlice.chars)));
        assert(((cast(*void)(*instance.baseChars)) - cast(*void)(*instance)) == 16, "StringSlice.baseChars has unexpected offset % instead of 16", ((cast(*void)(*instance.baseChars)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringSlice.baseChars)) == 8, "StringSlice.baseChars has unexpected size % instead of 8", size_of(type_of(StringSlice.baseChars)));
        assert(size_of(StringSlice) == 24, "StringSlice has size % instead of 24", size_of(StringSlice));
    }

    {
        instance: Arena;
        assert(((cast(*void)(*instance.nextAllocation)) - cast(*void)(*instance)) == 0, "Arena.nextAllocation has unexpected offset % instead of 0", ((cast(*void)(*instance.nextAllocation)) - cast(*void)(*instance)));
        assert(size_of(type_of(Arena.nextAllocation)) == 8, "Arena.nextAllocation has unexpected size % instead of 8", size_of(type_of(Arena.nextAllocation)));
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 8, "Arena.capacity has unexpected offset % instead of 8", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(Arena.capacity)) == 8, "Arena.capacity has unexpected size % instead of 8", size_of(type_of(Arena.capacity)));
        assert(((cast(*void)(*instance.memory)) - cast(*void)(*instance)) == 16, "Arena.memory has unexpected offset % instead of 16", ((cast(*void)(*instance.memory)) - cast(*void)(*instance)));
        assert(size_of(type_of(Arena.memory)) == 8, "Arena.memory has unexpected size % instead of 8", size_of(type_of(Arena.memory)));
        assert(size_of(Arena) == 24, "Arena has size % instead of 24", size_of(Arena));
    }

    {
        instance: Dimensions;
        assert(((cast(*void)(*instance.width)) - cast(*void)(*instance)) == 0, "Dimensions.width has unexpected offset % instead of 0", ((cast(*void)(*instance.width)) - cast(*void)(*instance)));
        assert(size_of(type_of(Dimensions.width)) == 4, "Dimensions.width has unexpected size % instead of 4", size_of(type_of(Dimensions.width)));
        assert(((cast(*void)(*instance.height)) - cast(*void)(*instance)) == 4, "Dimensions.height has unexpected offset % instead of 4", ((cast(*void)(*instance.height)) - cast(*void)(*instance)));
        assert(size_of(type_of(Dimensions.height)) == 4, "Dimensions.height has unexpected size % instead of 4", size_of(type_of(Dimensions.height)));
        assert(size_of(Dimensions) == 8, "Dimensions has size % instead of 8", size_of(Dimensions));
    }

    {
        instance: Vector2;
        assert(((cast(*void)(*instance.x)) - cast(*void)(*instance)) == 0, "Vector2.x has unexpected offset % instead of 0", ((cast(*void)(*instance.x)) - cast(*void)(*instance)));
        assert(size_of(type_of(Vector2.x)) == 4, "Vector2.x has unexpected size % instead of 4", size_of(type_of(Vector2.x)));
        assert(((cast(*void)(*instance.y)) - cast(*void)(*instance)) == 4, "Vector2.y has unexpected offset % instead of 4", ((cast(*void)(*instance.y)) - cast(*void)(*instance)));
        assert(size_of(type_of(Vector2.y)) == 4, "Vector2.y has unexpected size % instead of 4", size_of(type_of(Vector2.y)));
        assert(size_of(Vector2) == 8, "Vector2 has size % instead of 8", size_of(Vector2));
    }

    {
        instance: Color;
        assert(((cast(*void)(*instance.r)) - cast(*void)(*instance)) == 0, "Color.r has unexpected offset % instead of 0", ((cast(*void)(*instance.r)) - cast(*void)(*instance)));
        assert(size_of(type_of(Color.r)) == 4, "Color.r has unexpected size % instead of 4", size_of(type_of(Color.r)));
        assert(((cast(*void)(*instance.g)) - cast(*void)(*instance)) == 4, "Color.g has unexpected offset % instead of 4", ((cast(*void)(*instance.g)) - cast(*void)(*instance)));
        assert(size_of(type_of(Color.g)) == 4, "Color.g has unexpected size % instead of 4", size_of(type_of(Color.g)));
        assert(((cast(*void)(*instance.b)) - cast(*void)(*instance)) == 8, "Color.b has unexpected offset % instead of 8", ((cast(*void)(*instance.b)) - cast(*void)(*instance)));
        assert(size_of(type_of(Color.b)) == 4, "Color.b has unexpected size % instead of 4", size_of(type_of(Color.b)));
        assert(((cast(*void)(*instance.a)) - cast(*void)(*instance)) == 12, "Color.a has unexpected offset % instead of 12", ((cast(*void)(*instance.a)) - cast(*void)(*instance)));
        assert(size_of(type_of(Color.a)) == 4, "Color.a has unexpected size % instead of 4", size_of(type_of(Color.a)));
        assert(size_of(Color) == 16, "Color has size % instead of 16", size_of(Color));
    }

    {
        instance: BoundingBox;
        assert(((cast(*void)(*instance.x)) - cast(*void)(*instance)) == 0, "BoundingBox.x has unexpected offset % instead of 0", ((cast(*void)(*instance.x)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoundingBox.x)) == 4, "BoundingBox.x has unexpected size % instead of 4", size_of(type_of(BoundingBox.x)));
        assert(((cast(*void)(*instance.y)) - cast(*void)(*instance)) == 4, "BoundingBox.y has unexpected offset % instead of 4", ((cast(*void)(*instance.y)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoundingBox.y)) == 4, "BoundingBox.y has unexpected size % instead of 4", size_of(type_of(BoundingBox.y)));
        assert(((cast(*void)(*instance.width)) - cast(*void)(*instance)) == 8, "BoundingBox.width has unexpected offset % instead of 8", ((cast(*void)(*instance.width)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoundingBox.width)) == 4, "BoundingBox.width has unexpected size % instead of 4", size_of(type_of(BoundingBox.width)));
        assert(((cast(*void)(*instance.height)) - cast(*void)(*instance)) == 12, "BoundingBox.height has unexpected offset % instead of 12", ((cast(*void)(*instance.height)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoundingBox.height)) == 4, "BoundingBox.height has unexpected size % instead of 4", size_of(type_of(BoundingBox.height)));
        assert(size_of(BoundingBox) == 16, "BoundingBox has size % instead of 16", size_of(BoundingBox));
    }

    {
        instance: ElementId;
        assert(((cast(*void)(*instance.id)) - cast(*void)(*instance)) == 0, "ElementId.id has unexpected offset % instead of 0", ((cast(*void)(*instance.id)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementId.id)) == 4, "ElementId.id has unexpected size % instead of 4", size_of(type_of(ElementId.id)));
        assert(((cast(*void)(*instance.offset)) - cast(*void)(*instance)) == 4, "ElementId.offset has unexpected offset % instead of 4", ((cast(*void)(*instance.offset)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementId.offset)) == 4, "ElementId.offset has unexpected size % instead of 4", size_of(type_of(ElementId.offset)));
        assert(((cast(*void)(*instance.baseId)) - cast(*void)(*instance)) == 8, "ElementId.baseId has unexpected offset % instead of 8", ((cast(*void)(*instance.baseId)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementId.baseId)) == 4, "ElementId.baseId has unexpected size % instead of 4", size_of(type_of(ElementId.baseId)));
        assert(((cast(*void)(*instance.stringId)) - cast(*void)(*instance)) == 16, "ElementId.stringId has unexpected offset % instead of 16", ((cast(*void)(*instance.stringId)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementId.stringId)) == 16, "ElementId.stringId has unexpected size % instead of 16", size_of(type_of(ElementId.stringId)));
        assert(size_of(ElementId) == 32, "ElementId has size % instead of 32", size_of(ElementId));
    }

    {
        instance: CornerRadius;
        assert(((cast(*void)(*instance.topLeft)) - cast(*void)(*instance)) == 0, "CornerRadius.topLeft has unexpected offset % instead of 0", ((cast(*void)(*instance.topLeft)) - cast(*void)(*instance)));
        assert(size_of(type_of(CornerRadius.topLeft)) == 4, "CornerRadius.topLeft has unexpected size % instead of 4", size_of(type_of(CornerRadius.topLeft)));
        assert(((cast(*void)(*instance.topRight)) - cast(*void)(*instance)) == 4, "CornerRadius.topRight has unexpected offset % instead of 4", ((cast(*void)(*instance.topRight)) - cast(*void)(*instance)));
        assert(size_of(type_of(CornerRadius.topRight)) == 4, "CornerRadius.topRight has unexpected size % instead of 4", size_of(type_of(CornerRadius.topRight)));
        assert(((cast(*void)(*instance.bottomLeft)) - cast(*void)(*instance)) == 8, "CornerRadius.bottomLeft has unexpected offset % instead of 8", ((cast(*void)(*instance.bottomLeft)) - cast(*void)(*instance)));
        assert(size_of(type_of(CornerRadius.bottomLeft)) == 4, "CornerRadius.bottomLeft has unexpected size % instead of 4", size_of(type_of(CornerRadius.bottomLeft)));
        assert(((cast(*void)(*instance.bottomRight)) - cast(*void)(*instance)) == 12, "CornerRadius.bottomRight has unexpected offset % instead of 12", ((cast(*void)(*instance.bottomRight)) - cast(*void)(*instance)));
        assert(size_of(type_of(CornerRadius.bottomRight)) == 4, "CornerRadius.bottomRight has unexpected size % instead of 4", size_of(type_of(CornerRadius.bottomRight)));
        assert(size_of(CornerRadius) == 16, "CornerRadius has size % instead of 16", size_of(CornerRadius));
    }

    {
        instance: ChildAlignment;
        assert(((cast(*void)(*instance.x)) - cast(*void)(*instance)) == 0, "ChildAlignment.x has unexpected offset % instead of 0", ((cast(*void)(*instance.x)) - cast(*void)(*instance)));
        assert(size_of(type_of(ChildAlignment.x)) == 4, "ChildAlignment.x has unexpected size % instead of 4", size_of(type_of(ChildAlignment.x)));
        assert(((cast(*void)(*instance.y)) - cast(*void)(*instance)) == 4, "ChildAlignment.y has unexpected offset % instead of 4", ((cast(*void)(*instance.y)) - cast(*void)(*instance)));
        assert(size_of(type_of(ChildAlignment.y)) == 4, "ChildAlignment.y has unexpected size % instead of 4", size_of(type_of(ChildAlignment.y)));
        assert(size_of(ChildAlignment) == 8, "ChildAlignment has size % instead of 8", size_of(ChildAlignment));
    }

    {
        instance: SizingMinMax;
        assert(((cast(*void)(*instance.min)) - cast(*void)(*instance)) == 0, "SizingMinMax.min has unexpected offset % instead of 0", ((cast(*void)(*instance.min)) - cast(*void)(*instance)));
        assert(size_of(type_of(SizingMinMax.min)) == 4, "SizingMinMax.min has unexpected size % instead of 4", size_of(type_of(SizingMinMax.min)));
        assert(((cast(*void)(*instance.max)) - cast(*void)(*instance)) == 4, "SizingMinMax.max has unexpected offset % instead of 4", ((cast(*void)(*instance.max)) - cast(*void)(*instance)));
        assert(size_of(type_of(SizingMinMax.max)) == 4, "SizingMinMax.max has unexpected size % instead of 4", size_of(type_of(SizingMinMax.max)));
        assert(size_of(SizingMinMax) == 8, "SizingMinMax has size % instead of 8", size_of(SizingMinMax));
    }

    {
        instance: SizingAxis;
        assert(((cast(*void)(*instance.size)) - cast(*void)(*instance)) == 0, "SizingAxis.size has unexpected offset % instead of 0", ((cast(*void)(*instance.size)) - cast(*void)(*instance)));
        assert(size_of(type_of(SizingAxis.size)) == 8, "SizingAxis.size has unexpected size % instead of 8", size_of(type_of(SizingAxis.size)));
        assert(((cast(*void)(*instance.type)) - cast(*void)(*instance)) == 8, "SizingAxis.type has unexpected offset % instead of 8", ((cast(*void)(*instance.type)) - cast(*void)(*instance)));
        assert(size_of(type_of(SizingAxis.type)) == 4, "SizingAxis.type has unexpected size % instead of 4", size_of(type_of(SizingAxis.type)));
        assert(size_of(SizingAxis) == 12, "SizingAxis has size % instead of 12", size_of(SizingAxis));
    }

    {
        instance: Sizing;
        assert(((cast(*void)(*instance.width)) - cast(*void)(*instance)) == 0, "Sizing.width has unexpected offset % instead of 0", ((cast(*void)(*instance.width)) - cast(*void)(*instance)));
        assert(size_of(type_of(Sizing.width)) == 12, "Sizing.width has unexpected size % instead of 12", size_of(type_of(Sizing.width)));
        assert(((cast(*void)(*instance.height)) - cast(*void)(*instance)) == 12, "Sizing.height has unexpected offset % instead of 12", ((cast(*void)(*instance.height)) - cast(*void)(*instance)));
        assert(size_of(type_of(Sizing.height)) == 12, "Sizing.height has unexpected size % instead of 12", size_of(type_of(Sizing.height)));
        assert(size_of(Sizing) == 24, "Sizing has size % instead of 24", size_of(Sizing));
    }

    {
        instance: Padding;
        assert(((cast(*void)(*instance.left)) - cast(*void)(*instance)) == 0, "Padding.left has unexpected offset % instead of 0", ((cast(*void)(*instance.left)) - cast(*void)(*instance)));
        assert(size_of(type_of(Padding.left)) == 2, "Padding.left has unexpected size % instead of 2", size_of(type_of(Padding.left)));
        assert(((cast(*void)(*instance.right)) - cast(*void)(*instance)) == 2, "Padding.right has unexpected offset % instead of 2", ((cast(*void)(*instance.right)) - cast(*void)(*instance)));
        assert(size_of(type_of(Padding.right)) == 2, "Padding.right has unexpected size % instead of 2", size_of(type_of(Padding.right)));
        assert(((cast(*void)(*instance.top)) - cast(*void)(*instance)) == 4, "Padding.top has unexpected offset % instead of 4", ((cast(*void)(*instance.top)) - cast(*void)(*instance)));
        assert(size_of(type_of(Padding.top)) == 2, "Padding.top has unexpected size % instead of 2", size_of(type_of(Padding.top)));
        assert(((cast(*void)(*instance.bottom)) - cast(*void)(*instance)) == 6, "Padding.bottom has unexpected offset % instead of 6", ((cast(*void)(*instance.bottom)) - cast(*void)(*instance)));
        assert(size_of(type_of(Padding.bottom)) == 2, "Padding.bottom has unexpected size % instead of 2", size_of(type_of(Padding.bottom)));
        assert(size_of(Padding) == 8, "Padding has size % instead of 8", size_of(Padding));
    }

    {
        instance: LayoutConfig;
        assert(((cast(*void)(*instance.sizing)) - cast(*void)(*instance)) == 0, "LayoutConfig.sizing has unexpected offset % instead of 0", ((cast(*void)(*instance.sizing)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfig.sizing)) == 24, "LayoutConfig.sizing has unexpected size % instead of 24", size_of(type_of(LayoutConfig.sizing)));
        assert(((cast(*void)(*instance.padding)) - cast(*void)(*instance)) == 24, "LayoutConfig.padding has unexpected offset % instead of 24", ((cast(*void)(*instance.padding)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfig.padding)) == 8, "LayoutConfig.padding has unexpected size % instead of 8", size_of(type_of(LayoutConfig.padding)));
        assert(((cast(*void)(*instance.childGap)) - cast(*void)(*instance)) == 32, "LayoutConfig.childGap has unexpected offset % instead of 32", ((cast(*void)(*instance.childGap)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfig.childGap)) == 2, "LayoutConfig.childGap has unexpected size % instead of 2", size_of(type_of(LayoutConfig.childGap)));
        assert(((cast(*void)(*instance.childAlignment)) - cast(*void)(*instance)) == 36, "LayoutConfig.childAlignment has unexpected offset % instead of 36", ((cast(*void)(*instance.childAlignment)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfig.childAlignment)) == 8, "LayoutConfig.childAlignment has unexpected size % instead of 8", size_of(type_of(LayoutConfig.childAlignment)));
        assert(((cast(*void)(*instance.layoutDirection)) - cast(*void)(*instance)) == 44, "LayoutConfig.layoutDirection has unexpected offset % instead of 44", ((cast(*void)(*instance.layoutDirection)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfig.layoutDirection)) == 4, "LayoutConfig.layoutDirection has unexpected size % instead of 4", size_of(type_of(LayoutConfig.layoutDirection)));
        assert(size_of(LayoutConfig) == 48, "LayoutConfig has size % instead of 48", size_of(LayoutConfig));
    }

    {
        instance: RectangleElementConfig;
        assert(((cast(*void)(*instance.color)) - cast(*void)(*instance)) == 0, "RectangleElementConfig.color has unexpected offset % instead of 0", ((cast(*void)(*instance.color)) - cast(*void)(*instance)));
        assert(size_of(type_of(RectangleElementConfig.color)) == 16, "RectangleElementConfig.color has unexpected size % instead of 16", size_of(type_of(RectangleElementConfig.color)));
        assert(((cast(*void)(*instance.cornerRadius)) - cast(*void)(*instance)) == 16, "RectangleElementConfig.cornerRadius has unexpected offset % instead of 16", ((cast(*void)(*instance.cornerRadius)) - cast(*void)(*instance)));
        assert(size_of(type_of(RectangleElementConfig.cornerRadius)) == 16, "RectangleElementConfig.cornerRadius has unexpected size % instead of 16", size_of(type_of(RectangleElementConfig.cornerRadius)));
        assert(size_of(RectangleElementConfig) == 32, "RectangleElementConfig has size % instead of 32", size_of(RectangleElementConfig));
    }

    {
        instance: TextElementConfig;
        assert(((cast(*void)(*instance.textColor)) - cast(*void)(*instance)) == 0, "TextElementConfig.textColor has unexpected offset % instead of 0", ((cast(*void)(*instance.textColor)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.textColor)) == 16, "TextElementConfig.textColor has unexpected size % instead of 16", size_of(type_of(TextElementConfig.textColor)));
        assert(((cast(*void)(*instance.fontId)) - cast(*void)(*instance)) == 16, "TextElementConfig.fontId has unexpected offset % instead of 16", ((cast(*void)(*instance.fontId)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.fontId)) == 2, "TextElementConfig.fontId has unexpected size % instead of 2", size_of(type_of(TextElementConfig.fontId)));
        assert(((cast(*void)(*instance.fontSize)) - cast(*void)(*instance)) == 18, "TextElementConfig.fontSize has unexpected offset % instead of 18", ((cast(*void)(*instance.fontSize)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.fontSize)) == 2, "TextElementConfig.fontSize has unexpected size % instead of 2", size_of(type_of(TextElementConfig.fontSize)));
        assert(((cast(*void)(*instance.letterSpacing)) - cast(*void)(*instance)) == 20, "TextElementConfig.letterSpacing has unexpected offset % instead of 20", ((cast(*void)(*instance.letterSpacing)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.letterSpacing)) == 2, "TextElementConfig.letterSpacing has unexpected size % instead of 2", size_of(type_of(TextElementConfig.letterSpacing)));
        assert(((cast(*void)(*instance.lineHeight)) - cast(*void)(*instance)) == 22, "TextElementConfig.lineHeight has unexpected offset % instead of 22", ((cast(*void)(*instance.lineHeight)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.lineHeight)) == 2, "TextElementConfig.lineHeight has unexpected size % instead of 2", size_of(type_of(TextElementConfig.lineHeight)));
        assert(((cast(*void)(*instance.wrapMode)) - cast(*void)(*instance)) == 24, "TextElementConfig.wrapMode has unexpected offset % instead of 24", ((cast(*void)(*instance.wrapMode)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfig.wrapMode)) == 4, "TextElementConfig.wrapMode has unexpected size % instead of 4", size_of(type_of(TextElementConfig.wrapMode)));
        assert(size_of(TextElementConfig) == 28, "TextElementConfig has size % instead of 28", size_of(TextElementConfig));
    }

    {
        instance: ImageElementConfig;
        assert(((cast(*void)(*instance.imageData)) - cast(*void)(*instance)) == 0, "ImageElementConfig.imageData has unexpected offset % instead of 0", ((cast(*void)(*instance.imageData)) - cast(*void)(*instance)));
        assert(size_of(type_of(ImageElementConfig.imageData)) == 8, "ImageElementConfig.imageData has unexpected size % instead of 8", size_of(type_of(ImageElementConfig.imageData)));
        assert(((cast(*void)(*instance.sourceDimensions)) - cast(*void)(*instance)) == 8, "ImageElementConfig.sourceDimensions has unexpected offset % instead of 8", ((cast(*void)(*instance.sourceDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(ImageElementConfig.sourceDimensions)) == 8, "ImageElementConfig.sourceDimensions has unexpected size % instead of 8", size_of(type_of(ImageElementConfig.sourceDimensions)));
        assert(size_of(ImageElementConfig) == 16, "ImageElementConfig has size % instead of 16", size_of(ImageElementConfig));
    }

    {
        instance: FloatingAttachPoints;
        assert(((cast(*void)(*instance.element)) - cast(*void)(*instance)) == 0, "FloatingAttachPoints.element has unexpected offset % instead of 0", ((cast(*void)(*instance.element)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingAttachPoints.element)) == 4, "FloatingAttachPoints.element has unexpected size % instead of 4", size_of(type_of(FloatingAttachPoints.element)));
        assert(((cast(*void)(*instance.parent)) - cast(*void)(*instance)) == 4, "FloatingAttachPoints.parent has unexpected offset % instead of 4", ((cast(*void)(*instance.parent)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingAttachPoints.parent)) == 4, "FloatingAttachPoints.parent has unexpected size % instead of 4", size_of(type_of(FloatingAttachPoints.parent)));
        assert(size_of(FloatingAttachPoints) == 8, "FloatingAttachPoints has size % instead of 8", size_of(FloatingAttachPoints));
    }

    {
        instance: FloatingElementConfig;
        assert(((cast(*void)(*instance.offset)) - cast(*void)(*instance)) == 0, "FloatingElementConfig.offset has unexpected offset % instead of 0", ((cast(*void)(*instance.offset)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.offset)) == 8, "FloatingElementConfig.offset has unexpected size % instead of 8", size_of(type_of(FloatingElementConfig.offset)));
        assert(((cast(*void)(*instance.expand)) - cast(*void)(*instance)) == 8, "FloatingElementConfig.expand has unexpected offset % instead of 8", ((cast(*void)(*instance.expand)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.expand)) == 8, "FloatingElementConfig.expand has unexpected size % instead of 8", size_of(type_of(FloatingElementConfig.expand)));
        assert(((cast(*void)(*instance.zIndex)) - cast(*void)(*instance)) == 16, "FloatingElementConfig.zIndex has unexpected offset % instead of 16", ((cast(*void)(*instance.zIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.zIndex)) == 2, "FloatingElementConfig.zIndex has unexpected size % instead of 2", size_of(type_of(FloatingElementConfig.zIndex)));
        assert(((cast(*void)(*instance.parentId)) - cast(*void)(*instance)) == 20, "FloatingElementConfig.parentId has unexpected offset % instead of 20", ((cast(*void)(*instance.parentId)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.parentId)) == 4, "FloatingElementConfig.parentId has unexpected size % instead of 4", size_of(type_of(FloatingElementConfig.parentId)));
        assert(((cast(*void)(*instance.attachment)) - cast(*void)(*instance)) == 24, "FloatingElementConfig.attachment has unexpected offset % instead of 24", ((cast(*void)(*instance.attachment)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.attachment)) == 8, "FloatingElementConfig.attachment has unexpected size % instead of 8", size_of(type_of(FloatingElementConfig.attachment)));
        assert(((cast(*void)(*instance.pointerCaptureMode)) - cast(*void)(*instance)) == 32, "FloatingElementConfig.pointerCaptureMode has unexpected offset % instead of 32", ((cast(*void)(*instance.pointerCaptureMode)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfig.pointerCaptureMode)) == 4, "FloatingElementConfig.pointerCaptureMode has unexpected size % instead of 4", size_of(type_of(FloatingElementConfig.pointerCaptureMode)));
        assert(size_of(FloatingElementConfig) == 36, "FloatingElementConfig has size % instead of 36", size_of(FloatingElementConfig));
    }

    {
        instance: CustomElementConfig;
        assert(((cast(*void)(*instance.customData)) - cast(*void)(*instance)) == 0, "CustomElementConfig.customData has unexpected offset % instead of 0", ((cast(*void)(*instance.customData)) - cast(*void)(*instance)));
        assert(size_of(type_of(CustomElementConfig.customData)) == 8, "CustomElementConfig.customData has unexpected size % instead of 8", size_of(type_of(CustomElementConfig.customData)));
        assert(size_of(CustomElementConfig) == 8, "CustomElementConfig has size % instead of 8", size_of(CustomElementConfig));
    }

    {
        instance: ScrollElementConfig;
        assert(((cast(*void)(*instance.horizontal)) - cast(*void)(*instance)) == 0, "ScrollElementConfig.horizontal has unexpected offset % instead of 0", ((cast(*void)(*instance.horizontal)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollElementConfig.horizontal)) == 1, "ScrollElementConfig.horizontal has unexpected size % instead of 1", size_of(type_of(ScrollElementConfig.horizontal)));
        assert(((cast(*void)(*instance.vertical)) - cast(*void)(*instance)) == 1, "ScrollElementConfig.vertical has unexpected offset % instead of 1", ((cast(*void)(*instance.vertical)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollElementConfig.vertical)) == 1, "ScrollElementConfig.vertical has unexpected size % instead of 1", size_of(type_of(ScrollElementConfig.vertical)));
        assert(size_of(ScrollElementConfig) == 2, "ScrollElementConfig has size % instead of 2", size_of(ScrollElementConfig));
    }

    {
        instance: BorderData;
        assert(((cast(*void)(*instance.width)) - cast(*void)(*instance)) == 0, "BorderData.width has unexpected offset % instead of 0", ((cast(*void)(*instance.width)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderData.width)) == 4, "BorderData.width has unexpected size % instead of 4", size_of(type_of(BorderData.width)));
        assert(((cast(*void)(*instance.color)) - cast(*void)(*instance)) == 4, "BorderData.color has unexpected offset % instead of 4", ((cast(*void)(*instance.color)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderData.color)) == 16, "BorderData.color has unexpected size % instead of 16", size_of(type_of(BorderData.color)));
        assert(size_of(BorderData) == 20, "BorderData has size % instead of 20", size_of(BorderData));
    }

    {
        instance: BorderElementConfig;
        assert(((cast(*void)(*instance.left)) - cast(*void)(*instance)) == 0, "BorderElementConfig.left has unexpected offset % instead of 0", ((cast(*void)(*instance.left)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.left)) == 20, "BorderElementConfig.left has unexpected size % instead of 20", size_of(type_of(BorderElementConfig.left)));
        assert(((cast(*void)(*instance.right)) - cast(*void)(*instance)) == 20, "BorderElementConfig.right has unexpected offset % instead of 20", ((cast(*void)(*instance.right)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.right)) == 20, "BorderElementConfig.right has unexpected size % instead of 20", size_of(type_of(BorderElementConfig.right)));
        assert(((cast(*void)(*instance.top)) - cast(*void)(*instance)) == 40, "BorderElementConfig.top has unexpected offset % instead of 40", ((cast(*void)(*instance.top)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.top)) == 20, "BorderElementConfig.top has unexpected size % instead of 20", size_of(type_of(BorderElementConfig.top)));
        assert(((cast(*void)(*instance.bottom)) - cast(*void)(*instance)) == 60, "BorderElementConfig.bottom has unexpected offset % instead of 60", ((cast(*void)(*instance.bottom)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.bottom)) == 20, "BorderElementConfig.bottom has unexpected size % instead of 20", size_of(type_of(BorderElementConfig.bottom)));
        assert(((cast(*void)(*instance.betweenChildren)) - cast(*void)(*instance)) == 80, "BorderElementConfig.betweenChildren has unexpected offset % instead of 80", ((cast(*void)(*instance.betweenChildren)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.betweenChildren)) == 20, "BorderElementConfig.betweenChildren has unexpected size % instead of 20", size_of(type_of(BorderElementConfig.betweenChildren)));
        assert(((cast(*void)(*instance.cornerRadius)) - cast(*void)(*instance)) == 100, "BorderElementConfig.cornerRadius has unexpected offset % instead of 100", ((cast(*void)(*instance.cornerRadius)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfig.cornerRadius)) == 16, "BorderElementConfig.cornerRadius has unexpected size % instead of 16", size_of(type_of(BorderElementConfig.cornerRadius)));
        assert(size_of(BorderElementConfig) == 116, "BorderElementConfig has size % instead of 116", size_of(BorderElementConfig));
    }

    {
        instance: ElementConfigUnion;
        assert(((cast(*void)(*instance.rectangleElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.rectangleElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.rectangleElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.rectangleElementConfig)) == 8, "ElementConfigUnion.rectangleElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.rectangleElementConfig)));
        assert(((cast(*void)(*instance.textElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.textElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.textElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.textElementConfig)) == 8, "ElementConfigUnion.textElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.textElementConfig)));
        assert(((cast(*void)(*instance.imageElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.imageElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.imageElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.imageElementConfig)) == 8, "ElementConfigUnion.imageElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.imageElementConfig)));
        assert(((cast(*void)(*instance.floatingElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.floatingElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.floatingElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.floatingElementConfig)) == 8, "ElementConfigUnion.floatingElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.floatingElementConfig)));
        assert(((cast(*void)(*instance.customElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.customElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.customElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.customElementConfig)) == 8, "ElementConfigUnion.customElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.customElementConfig)));
        assert(((cast(*void)(*instance.scrollElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.scrollElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.scrollElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.scrollElementConfig)) == 8, "ElementConfigUnion.scrollElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.scrollElementConfig)));
        assert(((cast(*void)(*instance.borderElementConfig)) - cast(*void)(*instance)) == 0, "ElementConfigUnion.borderElementConfig has unexpected offset % instead of 0", ((cast(*void)(*instance.borderElementConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigUnion.borderElementConfig)) == 8, "ElementConfigUnion.borderElementConfig has unexpected size % instead of 8", size_of(type_of(ElementConfigUnion.borderElementConfig)));
        assert(size_of(ElementConfigUnion) == 8, "ElementConfigUnion has size % instead of 8", size_of(ElementConfigUnion));
    }

    {
        instance: ElementConfig;
        assert(((cast(*void)(*instance.type)) - cast(*void)(*instance)) == 0, "ElementConfig.type has unexpected offset % instead of 0", ((cast(*void)(*instance.type)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfig.type)) == 4, "ElementConfig.type has unexpected size % instead of 4", size_of(type_of(ElementConfig.type)));
        assert(((cast(*void)(*instance.config)) - cast(*void)(*instance)) == 8, "ElementConfig.config has unexpected offset % instead of 8", ((cast(*void)(*instance.config)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfig.config)) == 8, "ElementConfig.config has unexpected size % instead of 8", size_of(type_of(ElementConfig.config)));
        assert(size_of(ElementConfig) == 16, "ElementConfig has size % instead of 16", size_of(ElementConfig));
    }

    {
        instance: ScrollContainerData;
        assert(((cast(*void)(*instance.scrollPosition)) - cast(*void)(*instance)) == 0, "ScrollContainerData.scrollPosition has unexpected offset % instead of 0", ((cast(*void)(*instance.scrollPosition)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerData.scrollPosition)) == 8, "ScrollContainerData.scrollPosition has unexpected size % instead of 8", size_of(type_of(ScrollContainerData.scrollPosition)));
        assert(((cast(*void)(*instance.scrollContainerDimensions)) - cast(*void)(*instance)) == 8, "ScrollContainerData.scrollContainerDimensions has unexpected offset % instead of 8", ((cast(*void)(*instance.scrollContainerDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerData.scrollContainerDimensions)) == 8, "ScrollContainerData.scrollContainerDimensions has unexpected size % instead of 8", size_of(type_of(ScrollContainerData.scrollContainerDimensions)));
        assert(((cast(*void)(*instance.contentDimensions)) - cast(*void)(*instance)) == 16, "ScrollContainerData.contentDimensions has unexpected offset % instead of 16", ((cast(*void)(*instance.contentDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerData.contentDimensions)) == 8, "ScrollContainerData.contentDimensions has unexpected size % instead of 8", size_of(type_of(ScrollContainerData.contentDimensions)));
        assert(((cast(*void)(*instance.config)) - cast(*void)(*instance)) == 24, "ScrollContainerData.config has unexpected offset % instead of 24", ((cast(*void)(*instance.config)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerData.config)) == 2, "ScrollContainerData.config has unexpected size % instead of 2", size_of(type_of(ScrollContainerData.config)));
        assert(((cast(*void)(*instance.found)) - cast(*void)(*instance)) == 26, "ScrollContainerData.found has unexpected offset % instead of 26", ((cast(*void)(*instance.found)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerData.found)) == 1, "ScrollContainerData.found has unexpected size % instead of 1", size_of(type_of(ScrollContainerData.found)));
        assert(size_of(ScrollContainerData) == 32, "ScrollContainerData has size % instead of 32", size_of(ScrollContainerData));
    }

    {
        instance: ElementData;
        assert(((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)) == 0, "ElementData.boundingBox has unexpected offset % instead of 0", ((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementData.boundingBox)) == 16, "ElementData.boundingBox has unexpected size % instead of 16", size_of(type_of(ElementData.boundingBox)));
        assert(((cast(*void)(*instance.found)) - cast(*void)(*instance)) == 16, "ElementData.found has unexpected offset % instead of 16", ((cast(*void)(*instance.found)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementData.found)) == 1, "ElementData.found has unexpected size % instead of 1", size_of(type_of(ElementData.found)));
        assert(size_of(ElementData) == 20, "ElementData has size % instead of 20", size_of(ElementData));
    }

    {
        instance: RenderCommand;
        assert(((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)) == 0, "RenderCommand.boundingBox has unexpected offset % instead of 0", ((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommand.boundingBox)) == 16, "RenderCommand.boundingBox has unexpected size % instead of 16", size_of(type_of(RenderCommand.boundingBox)));
        assert(((cast(*void)(*instance.config)) - cast(*void)(*instance)) == 16, "RenderCommand.config has unexpected offset % instead of 16", ((cast(*void)(*instance.config)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommand.config)) == 8, "RenderCommand.config has unexpected size % instead of 8", size_of(type_of(RenderCommand.config)));
        assert(((cast(*void)(*instance.text)) - cast(*void)(*instance)) == 24, "RenderCommand.text has unexpected offset % instead of 24", ((cast(*void)(*instance.text)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommand.text)) == 16, "RenderCommand.text has unexpected size % instead of 16", size_of(type_of(RenderCommand.text)));
        assert(((cast(*void)(*instance.id)) - cast(*void)(*instance)) == 40, "RenderCommand.id has unexpected offset % instead of 40", ((cast(*void)(*instance.id)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommand.id)) == 4, "RenderCommand.id has unexpected size % instead of 4", size_of(type_of(RenderCommand.id)));
        assert(((cast(*void)(*instance.commandType)) - cast(*void)(*instance)) == 44, "RenderCommand.commandType has unexpected offset % instead of 44", ((cast(*void)(*instance.commandType)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommand.commandType)) == 4, "RenderCommand.commandType has unexpected size % instead of 4", size_of(type_of(RenderCommand.commandType)));
        assert(size_of(RenderCommand) == 48, "RenderCommand has size % instead of 48", size_of(RenderCommand));
    }

    {
        instance: RenderCommandArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "RenderCommandArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommandArray.capacity)) == 4, "RenderCommandArray.capacity has unexpected size % instead of 4", size_of(type_of(RenderCommandArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "RenderCommandArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommandArray.length)) == 4, "RenderCommandArray.length has unexpected size % instead of 4", size_of(type_of(RenderCommandArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "RenderCommandArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderCommandArray.internalArray)) == 8, "RenderCommandArray.internalArray has unexpected size % instead of 8", size_of(type_of(RenderCommandArray.internalArray)));
        assert(size_of(RenderCommandArray) == 16, "RenderCommandArray has size % instead of 16", size_of(RenderCommandArray));
    }

    {
        instance: PointerData;
        assert(((cast(*void)(*instance.position)) - cast(*void)(*instance)) == 0, "PointerData.position has unexpected offset % instead of 0", ((cast(*void)(*instance.position)) - cast(*void)(*instance)));
        assert(size_of(type_of(PointerData.position)) == 8, "PointerData.position has unexpected size % instead of 8", size_of(type_of(PointerData.position)));
        assert(((cast(*void)(*instance.state)) - cast(*void)(*instance)) == 8, "PointerData.state has unexpected offset % instead of 8", ((cast(*void)(*instance.state)) - cast(*void)(*instance)));
        assert(size_of(type_of(PointerData.state)) == 4, "PointerData.state has unexpected size % instead of 4", size_of(type_of(PointerData.state)));
        assert(size_of(PointerData) == 12, "PointerData has size % instead of 12", size_of(PointerData));
    }

    {
        instance: ErrorData;
        assert(((cast(*void)(*instance.errorType)) - cast(*void)(*instance)) == 0, "ErrorData.errorType has unexpected offset % instead of 0", ((cast(*void)(*instance.errorType)) - cast(*void)(*instance)));
        assert(size_of(type_of(ErrorData.errorType)) == 4, "ErrorData.errorType has unexpected size % instead of 4", size_of(type_of(ErrorData.errorType)));
        assert(((cast(*void)(*instance.errorText)) - cast(*void)(*instance)) == 8, "ErrorData.errorText has unexpected offset % instead of 8", ((cast(*void)(*instance.errorText)) - cast(*void)(*instance)));
        assert(size_of(type_of(ErrorData.errorText)) == 16, "ErrorData.errorText has unexpected size % instead of 16", size_of(type_of(ErrorData.errorText)));
        assert(((cast(*void)(*instance.userData)) - cast(*void)(*instance)) == 24, "ErrorData.userData has unexpected offset % instead of 24", ((cast(*void)(*instance.userData)) - cast(*void)(*instance)));
        assert(size_of(type_of(ErrorData.userData)) == 8, "ErrorData.userData has unexpected size % instead of 8", size_of(type_of(ErrorData.userData)));
        assert(size_of(ErrorData) == 32, "ErrorData has size % instead of 32", size_of(ErrorData));
    }

    {
        instance: ErrorHandler;
        assert(((cast(*void)(*instance.errorHandlerFunction)) - cast(*void)(*instance)) == 0, "ErrorHandler.errorHandlerFunction has unexpected offset % instead of 0", ((cast(*void)(*instance.errorHandlerFunction)) - cast(*void)(*instance)));
        assert(size_of(type_of(ErrorHandler.errorHandlerFunction)) == 8, "ErrorHandler.errorHandlerFunction has unexpected size % instead of 8", size_of(type_of(ErrorHandler.errorHandlerFunction)));
        assert(((cast(*void)(*instance.userData)) - cast(*void)(*instance)) == 8, "ErrorHandler.userData has unexpected offset % instead of 8", ((cast(*void)(*instance.userData)) - cast(*void)(*instance)));
        assert(size_of(type_of(ErrorHandler.userData)) == 8, "ErrorHandler.userData has unexpected size % instead of 8", size_of(type_of(ErrorHandler.userData)));
        assert(size_of(ErrorHandler) == 16, "ErrorHandler has size % instead of 16", size_of(ErrorHandler));
    }

    {
        instance: BooleanWarnings;
        assert(((cast(*void)(*instance.maxElementsExceeded)) - cast(*void)(*instance)) == 0, "BooleanWarnings.maxElementsExceeded has unexpected offset % instead of 0", ((cast(*void)(*instance.maxElementsExceeded)) - cast(*void)(*instance)));
        assert(size_of(type_of(BooleanWarnings.maxElementsExceeded)) == 1, "BooleanWarnings.maxElementsExceeded has unexpected size % instead of 1", size_of(type_of(BooleanWarnings.maxElementsExceeded)));
        assert(((cast(*void)(*instance.maxRenderCommandsExceeded)) - cast(*void)(*instance)) == 1, "BooleanWarnings.maxRenderCommandsExceeded has unexpected offset % instead of 1", ((cast(*void)(*instance.maxRenderCommandsExceeded)) - cast(*void)(*instance)));
        assert(size_of(type_of(BooleanWarnings.maxRenderCommandsExceeded)) == 1, "BooleanWarnings.maxRenderCommandsExceeded has unexpected size % instead of 1", size_of(type_of(BooleanWarnings.maxRenderCommandsExceeded)));
        assert(((cast(*void)(*instance.maxTextMeasureCacheExceeded)) - cast(*void)(*instance)) == 2, "BooleanWarnings.maxTextMeasureCacheExceeded has unexpected offset % instead of 2", ((cast(*void)(*instance.maxTextMeasureCacheExceeded)) - cast(*void)(*instance)));
        assert(size_of(type_of(BooleanWarnings.maxTextMeasureCacheExceeded)) == 1, "BooleanWarnings.maxTextMeasureCacheExceeded has unexpected size % instead of 1", size_of(type_of(BooleanWarnings.maxTextMeasureCacheExceeded)));
        assert(((cast(*void)(*instance.textMeasurementFunctionNotSet)) - cast(*void)(*instance)) == 3, "BooleanWarnings.textMeasurementFunctionNotSet has unexpected offset % instead of 3", ((cast(*void)(*instance.textMeasurementFunctionNotSet)) - cast(*void)(*instance)));
        assert(size_of(type_of(BooleanWarnings.textMeasurementFunctionNotSet)) == 1, "BooleanWarnings.textMeasurementFunctionNotSet has unexpected size % instead of 1", size_of(type_of(BooleanWarnings.textMeasurementFunctionNotSet)));
        assert(size_of(BooleanWarnings) == 4, "BooleanWarnings has size % instead of 4", size_of(BooleanWarnings));
    }

    {
        instance: Warning;
        assert(((cast(*void)(*instance.baseMessage)) - cast(*void)(*instance)) == 0, "Warning.baseMessage has unexpected offset % instead of 0", ((cast(*void)(*instance.baseMessage)) - cast(*void)(*instance)));
        assert(size_of(type_of(Warning.baseMessage)) == 16, "Warning.baseMessage has unexpected size % instead of 16", size_of(type_of(Warning.baseMessage)));
        assert(((cast(*void)(*instance.dynamicMessage)) - cast(*void)(*instance)) == 16, "Warning.dynamicMessage has unexpected offset % instead of 16", ((cast(*void)(*instance.dynamicMessage)) - cast(*void)(*instance)));
        assert(size_of(type_of(Warning.dynamicMessage)) == 16, "Warning.dynamicMessage has unexpected size % instead of 16", size_of(type_of(Warning.dynamicMessage)));
        assert(size_of(Warning) == 32, "Warning has size % instead of 32", size_of(Warning));
    }

    {
        instance: WarningArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "WarningArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(WarningArray.capacity)) == 4, "WarningArray.capacity has unexpected size % instead of 4", size_of(type_of(WarningArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "WarningArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(WarningArray.length)) == 4, "WarningArray.length has unexpected size % instead of 4", size_of(type_of(WarningArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "WarningArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(WarningArray.internalArray)) == 8, "WarningArray.internalArray has unexpected size % instead of 8", size_of(type_of(WarningArray.internalArray)));
        assert(size_of(WarningArray) == 16, "WarningArray has size % instead of 16", size_of(WarningArray));
    }

    {
        instance: BoolArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "BoolArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoolArray.capacity)) == 4, "BoolArray.capacity has unexpected size % instead of 4", size_of(type_of(BoolArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "BoolArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoolArray.length)) == 4, "BoolArray.length has unexpected size % instead of 4", size_of(type_of(BoolArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "BoolArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(BoolArray.internalArray)) == 8, "BoolArray.internalArray has unexpected size % instead of 8", size_of(type_of(BoolArray.internalArray)));
        assert(size_of(BoolArray) == 16, "BoolArray has size % instead of 16", size_of(BoolArray));
    }

    {
        instance: ElementIdArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "ElementIdArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementIdArray.capacity)) == 4, "ElementIdArray.capacity has unexpected size % instead of 4", size_of(type_of(ElementIdArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "ElementIdArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementIdArray.length)) == 4, "ElementIdArray.length has unexpected size % instead of 4", size_of(type_of(ElementIdArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ElementIdArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementIdArray.internalArray)) == 8, "ElementIdArray.internalArray has unexpected size % instead of 8", size_of(type_of(ElementIdArray.internalArray)));
        assert(size_of(ElementIdArray) == 16, "ElementIdArray has size % instead of 16", size_of(ElementIdArray));
    }

    {
        instance: ElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "ElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigArray.capacity)) == 4, "ElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(ElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "ElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigArray.length)) == 4, "ElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(ElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigArray.internalArray)) == 8, "ElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(ElementConfigArray.internalArray)));
        assert(size_of(ElementConfigArray) == 16, "ElementConfigArray has size % instead of 16", size_of(ElementConfigArray));
    }

    {
        instance: ElementConfigArraySlice;
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 0, "ElementConfigArraySlice.length has unexpected offset % instead of 0", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigArraySlice.length)) == 4, "ElementConfigArraySlice.length has unexpected size % instead of 4", size_of(type_of(ElementConfigArraySlice.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ElementConfigArraySlice.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ElementConfigArraySlice.internalArray)) == 8, "ElementConfigArraySlice.internalArray has unexpected size % instead of 8", size_of(type_of(ElementConfigArraySlice.internalArray)));
        assert(size_of(ElementConfigArraySlice) == 16, "ElementConfigArraySlice has size % instead of 16", size_of(ElementConfigArraySlice));
    }

    {
        instance: LayoutConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfigArray.capacity)) == 4, "LayoutConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfigArray.length)) == 4, "LayoutConfigArray.length has unexpected size % instead of 4", size_of(type_of(LayoutConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutConfigArray.internalArray)) == 8, "LayoutConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutConfigArray.internalArray)));
        assert(size_of(LayoutConfigArray) == 16, "LayoutConfigArray has size % instead of 16", size_of(LayoutConfigArray));
    }

    {
        instance: RectangleElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "RectangleElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(RectangleElementConfigArray.capacity)) == 4, "RectangleElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(RectangleElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "RectangleElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(RectangleElementConfigArray.length)) == 4, "RectangleElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(RectangleElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "RectangleElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(RectangleElementConfigArray.internalArray)) == 8, "RectangleElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(RectangleElementConfigArray.internalArray)));
        assert(size_of(RectangleElementConfigArray) == 16, "RectangleElementConfigArray has size % instead of 16", size_of(RectangleElementConfigArray));
    }

    {
        instance: TextElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "TextElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfigArray.capacity)) == 4, "TextElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(TextElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "TextElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfigArray.length)) == 4, "TextElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(TextElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "TextElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementConfigArray.internalArray)) == 8, "TextElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(TextElementConfigArray.internalArray)));
        assert(size_of(TextElementConfigArray) == 16, "TextElementConfigArray has size % instead of 16", size_of(TextElementConfigArray));
    }

    {
        instance: ImageElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "ImageElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(ImageElementConfigArray.capacity)) == 4, "ImageElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(ImageElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "ImageElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ImageElementConfigArray.length)) == 4, "ImageElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(ImageElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ImageElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ImageElementConfigArray.internalArray)) == 8, "ImageElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(ImageElementConfigArray.internalArray)));
        assert(size_of(ImageElementConfigArray) == 16, "ImageElementConfigArray has size % instead of 16", size_of(ImageElementConfigArray));
    }

    {
        instance: FloatingElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "FloatingElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfigArray.capacity)) == 4, "FloatingElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(FloatingElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "FloatingElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfigArray.length)) == 4, "FloatingElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(FloatingElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "FloatingElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(FloatingElementConfigArray.internalArray)) == 8, "FloatingElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(FloatingElementConfigArray.internalArray)));
        assert(size_of(FloatingElementConfigArray) == 16, "FloatingElementConfigArray has size % instead of 16", size_of(FloatingElementConfigArray));
    }

    {
        instance: CustomElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "CustomElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(CustomElementConfigArray.capacity)) == 4, "CustomElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(CustomElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "CustomElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(CustomElementConfigArray.length)) == 4, "CustomElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(CustomElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "CustomElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(CustomElementConfigArray.internalArray)) == 8, "CustomElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(CustomElementConfigArray.internalArray)));
        assert(size_of(CustomElementConfigArray) == 16, "CustomElementConfigArray has size % instead of 16", size_of(CustomElementConfigArray));
    }

    {
        instance: ScrollElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "ScrollElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollElementConfigArray.capacity)) == 4, "ScrollElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(ScrollElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "ScrollElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollElementConfigArray.length)) == 4, "ScrollElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(ScrollElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ScrollElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollElementConfigArray.internalArray)) == 8, "ScrollElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(ScrollElementConfigArray.internalArray)));
        assert(size_of(ScrollElementConfigArray) == 16, "ScrollElementConfigArray has size % instead of 16", size_of(ScrollElementConfigArray));
    }

    {
        instance: StringArraySlice;
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 0, "StringArraySlice.length has unexpected offset % instead of 0", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringArraySlice.length)) == 4, "StringArraySlice.length has unexpected size % instead of 4", size_of(type_of(StringArraySlice.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "StringArraySlice.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(StringArraySlice.internalArray)) == 8, "StringArraySlice.internalArray has unexpected size % instead of 8", size_of(type_of(StringArraySlice.internalArray)));
        assert(size_of(StringArraySlice) == 16, "StringArraySlice has size % instead of 16", size_of(StringArraySlice));
    }

    {
        instance: WrappedTextLine;
        assert(((cast(*void)(*instance.dimensions)) - cast(*void)(*instance)) == 0, "WrappedTextLine.dimensions has unexpected offset % instead of 0", ((cast(*void)(*instance.dimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLine.dimensions)) == 8, "WrappedTextLine.dimensions has unexpected size % instead of 8", size_of(type_of(WrappedTextLine.dimensions)));
        assert(((cast(*void)(*instance.line)) - cast(*void)(*instance)) == 8, "WrappedTextLine.line has unexpected offset % instead of 8", ((cast(*void)(*instance.line)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLine.line)) == 16, "WrappedTextLine.line has unexpected size % instead of 16", size_of(type_of(WrappedTextLine.line)));
        assert(size_of(WrappedTextLine) == 24, "WrappedTextLine has size % instead of 24", size_of(WrappedTextLine));
    }

    {
        instance: WrappedTextLineArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "WrappedTextLineArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLineArray.capacity)) == 4, "WrappedTextLineArray.capacity has unexpected size % instead of 4", size_of(type_of(WrappedTextLineArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "WrappedTextLineArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLineArray.length)) == 4, "WrappedTextLineArray.length has unexpected size % instead of 4", size_of(type_of(WrappedTextLineArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "WrappedTextLineArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLineArray.internalArray)) == 8, "WrappedTextLineArray.internalArray has unexpected size % instead of 8", size_of(type_of(WrappedTextLineArray.internalArray)));
        assert(size_of(WrappedTextLineArray) == 16, "WrappedTextLineArray has size % instead of 16", size_of(WrappedTextLineArray));
    }

    {
        instance: WrappedTextLineArraySlice;
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 0, "WrappedTextLineArraySlice.length has unexpected offset % instead of 0", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLineArraySlice.length)) == 4, "WrappedTextLineArraySlice.length has unexpected size % instead of 4", size_of(type_of(WrappedTextLineArraySlice.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "WrappedTextLineArraySlice.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(WrappedTextLineArraySlice.internalArray)) == 8, "WrappedTextLineArraySlice.internalArray has unexpected size % instead of 8", size_of(type_of(WrappedTextLineArraySlice.internalArray)));
        assert(size_of(WrappedTextLineArraySlice) == 16, "WrappedTextLineArraySlice has size % instead of 16", size_of(WrappedTextLineArraySlice));
    }

    {
        instance: TextElementData;
        assert(((cast(*void)(*instance.text)) - cast(*void)(*instance)) == 0, "TextElementData.text has unexpected offset % instead of 0", ((cast(*void)(*instance.text)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementData.text)) == 16, "TextElementData.text has unexpected size % instead of 16", size_of(type_of(TextElementData.text)));
        assert(((cast(*void)(*instance.preferredDimensions)) - cast(*void)(*instance)) == 16, "TextElementData.preferredDimensions has unexpected offset % instead of 16", ((cast(*void)(*instance.preferredDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementData.preferredDimensions)) == 8, "TextElementData.preferredDimensions has unexpected size % instead of 8", size_of(type_of(TextElementData.preferredDimensions)));
        assert(((cast(*void)(*instance.elementIndex)) - cast(*void)(*instance)) == 24, "TextElementData.elementIndex has unexpected offset % instead of 24", ((cast(*void)(*instance.elementIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementData.elementIndex)) == 4, "TextElementData.elementIndex has unexpected size % instead of 4", size_of(type_of(TextElementData.elementIndex)));
        assert(((cast(*void)(*instance.wrappedLines)) - cast(*void)(*instance)) == 32, "TextElementData.wrappedLines has unexpected offset % instead of 32", ((cast(*void)(*instance.wrappedLines)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementData.wrappedLines)) == 16, "TextElementData.wrappedLines has unexpected size % instead of 16", size_of(type_of(TextElementData.wrappedLines)));
        assert(size_of(TextElementData) == 48, "TextElementData has size % instead of 48", size_of(TextElementData));
    }

    {
        instance: TextElementDataArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "TextElementDataArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementDataArray.capacity)) == 4, "TextElementDataArray.capacity has unexpected size % instead of 4", size_of(type_of(TextElementDataArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "TextElementDataArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementDataArray.length)) == 4, "TextElementDataArray.length has unexpected size % instead of 4", size_of(type_of(TextElementDataArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "TextElementDataArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(TextElementDataArray.internalArray)) == 8, "TextElementDataArray.internalArray has unexpected size % instead of 8", size_of(type_of(TextElementDataArray.internalArray)));
        assert(size_of(TextElementDataArray) == 16, "TextElementDataArray has size % instead of 16", size_of(TextElementDataArray));
    }

    {
        instance: BorderElementConfigArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "BorderElementConfigArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfigArray.capacity)) == 4, "BorderElementConfigArray.capacity has unexpected size % instead of 4", size_of(type_of(BorderElementConfigArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "BorderElementConfigArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfigArray.length)) == 4, "BorderElementConfigArray.length has unexpected size % instead of 4", size_of(type_of(BorderElementConfigArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "BorderElementConfigArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(BorderElementConfigArray.internalArray)) == 8, "BorderElementConfigArray.internalArray has unexpected size % instead of 8", size_of(type_of(BorderElementConfigArray.internalArray)));
        assert(size_of(BorderElementConfigArray) == 16, "BorderElementConfigArray has size % instead of 16", size_of(BorderElementConfigArray));
    }

    {
        instance: LayoutElementChildren;
        assert(((cast(*void)(*instance.elements)) - cast(*void)(*instance)) == 0, "LayoutElementChildren.elements has unexpected offset % instead of 0", ((cast(*void)(*instance.elements)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementChildren.elements)) == 8, "LayoutElementChildren.elements has unexpected size % instead of 8", size_of(type_of(LayoutElementChildren.elements)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 8, "LayoutElementChildren.length has unexpected offset % instead of 8", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementChildren.length)) == 2, "LayoutElementChildren.length has unexpected size % instead of 2", size_of(type_of(LayoutElementChildren.length)));
        assert(size_of(LayoutElementChildren) == 16, "LayoutElementChildren has size % instead of 16", size_of(LayoutElementChildren));
    }

    {
        instance: LayoutElement;
        assert(((cast(*void)(*instance.childrenOrTextContent)) - cast(*void)(*instance)) == 0, "LayoutElement.childrenOrTextContent has unexpected offset % instead of 0", ((cast(*void)(*instance.childrenOrTextContent)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.childrenOrTextContent)) == 16, "LayoutElement.childrenOrTextContent has unexpected size % instead of 16", size_of(type_of(LayoutElement.childrenOrTextContent)));
        assert(((cast(*void)(*instance.dimensions)) - cast(*void)(*instance)) == 16, "LayoutElement.dimensions has unexpected offset % instead of 16", ((cast(*void)(*instance.dimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.dimensions)) == 8, "LayoutElement.dimensions has unexpected size % instead of 8", size_of(type_of(LayoutElement.dimensions)));
        assert(((cast(*void)(*instance.minDimensions)) - cast(*void)(*instance)) == 24, "LayoutElement.minDimensions has unexpected offset % instead of 24", ((cast(*void)(*instance.minDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.minDimensions)) == 8, "LayoutElement.minDimensions has unexpected size % instead of 8", size_of(type_of(LayoutElement.minDimensions)));
        assert(((cast(*void)(*instance.layoutConfig)) - cast(*void)(*instance)) == 32, "LayoutElement.layoutConfig has unexpected offset % instead of 32", ((cast(*void)(*instance.layoutConfig)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.layoutConfig)) == 8, "LayoutElement.layoutConfig has unexpected size % instead of 8", size_of(type_of(LayoutElement.layoutConfig)));
        assert(((cast(*void)(*instance.elementConfigs)) - cast(*void)(*instance)) == 40, "LayoutElement.elementConfigs has unexpected offset % instead of 40", ((cast(*void)(*instance.elementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.elementConfigs)) == 16, "LayoutElement.elementConfigs has unexpected size % instead of 16", size_of(type_of(LayoutElement.elementConfigs)));
        assert(((cast(*void)(*instance.configsEnabled)) - cast(*void)(*instance)) == 56, "LayoutElement.configsEnabled has unexpected offset % instead of 56", ((cast(*void)(*instance.configsEnabled)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.configsEnabled)) == 4, "LayoutElement.configsEnabled has unexpected size % instead of 4", size_of(type_of(LayoutElement.configsEnabled)));
        assert(((cast(*void)(*instance.id)) - cast(*void)(*instance)) == 60, "LayoutElement.id has unexpected offset % instead of 60", ((cast(*void)(*instance.id)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElement.id)) == 4, "LayoutElement.id has unexpected size % instead of 4", size_of(type_of(LayoutElement.id)));
        assert(size_of(LayoutElement) == 64, "LayoutElement has size % instead of 64", size_of(LayoutElement));
    }

    {
        instance: LayoutElementArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutElementArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementArray.capacity)) == 4, "LayoutElementArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutElementArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutElementArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementArray.length)) == 4, "LayoutElementArray.length has unexpected size % instead of 4", size_of(type_of(LayoutElementArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutElementArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementArray.internalArray)) == 8, "LayoutElementArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutElementArray.internalArray)));
        assert(size_of(LayoutElementArray) == 16, "LayoutElementArray has size % instead of 16", size_of(LayoutElementArray));
    }

    {
        instance: LayoutElementPointerArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutElementPointerArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementPointerArray.capacity)) == 4, "LayoutElementPointerArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutElementPointerArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutElementPointerArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementPointerArray.length)) == 4, "LayoutElementPointerArray.length has unexpected size % instead of 4", size_of(type_of(LayoutElementPointerArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutElementPointerArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementPointerArray.internalArray)) == 8, "LayoutElementPointerArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutElementPointerArray.internalArray)));
        assert(size_of(LayoutElementPointerArray) == 16, "LayoutElementPointerArray has size % instead of 16", size_of(LayoutElementPointerArray));
    }

    {
        instance: ScrollContainerDataInternal;
        assert(((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)) == 0, "ScrollContainerDataInternal.layoutElement has unexpected offset % instead of 0", ((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.layoutElement)) == 8, "ScrollContainerDataInternal.layoutElement has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.layoutElement)));
        assert(((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)) == 8, "ScrollContainerDataInternal.boundingBox has unexpected offset % instead of 8", ((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.boundingBox)) == 16, "ScrollContainerDataInternal.boundingBox has unexpected size % instead of 16", size_of(type_of(ScrollContainerDataInternal.boundingBox)));
        assert(((cast(*void)(*instance.contentSize)) - cast(*void)(*instance)) == 24, "ScrollContainerDataInternal.contentSize has unexpected offset % instead of 24", ((cast(*void)(*instance.contentSize)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.contentSize)) == 8, "ScrollContainerDataInternal.contentSize has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.contentSize)));
        assert(((cast(*void)(*instance.scrollOrigin)) - cast(*void)(*instance)) == 32, "ScrollContainerDataInternal.scrollOrigin has unexpected offset % instead of 32", ((cast(*void)(*instance.scrollOrigin)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.scrollOrigin)) == 8, "ScrollContainerDataInternal.scrollOrigin has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.scrollOrigin)));
        assert(((cast(*void)(*instance.pointerOrigin)) - cast(*void)(*instance)) == 40, "ScrollContainerDataInternal.pointerOrigin has unexpected offset % instead of 40", ((cast(*void)(*instance.pointerOrigin)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.pointerOrigin)) == 8, "ScrollContainerDataInternal.pointerOrigin has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.pointerOrigin)));
        assert(((cast(*void)(*instance.scrollMomentum)) - cast(*void)(*instance)) == 48, "ScrollContainerDataInternal.scrollMomentum has unexpected offset % instead of 48", ((cast(*void)(*instance.scrollMomentum)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.scrollMomentum)) == 8, "ScrollContainerDataInternal.scrollMomentum has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.scrollMomentum)));
        assert(((cast(*void)(*instance.scrollPosition)) - cast(*void)(*instance)) == 56, "ScrollContainerDataInternal.scrollPosition has unexpected offset % instead of 56", ((cast(*void)(*instance.scrollPosition)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.scrollPosition)) == 8, "ScrollContainerDataInternal.scrollPosition has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.scrollPosition)));
        assert(((cast(*void)(*instance.previousDelta)) - cast(*void)(*instance)) == 64, "ScrollContainerDataInternal.previousDelta has unexpected offset % instead of 64", ((cast(*void)(*instance.previousDelta)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.previousDelta)) == 8, "ScrollContainerDataInternal.previousDelta has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternal.previousDelta)));
        assert(((cast(*void)(*instance.momentumTime)) - cast(*void)(*instance)) == 72, "ScrollContainerDataInternal.momentumTime has unexpected offset % instead of 72", ((cast(*void)(*instance.momentumTime)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.momentumTime)) == 4, "ScrollContainerDataInternal.momentumTime has unexpected size % instead of 4", size_of(type_of(ScrollContainerDataInternal.momentumTime)));
        assert(((cast(*void)(*instance.elementId)) - cast(*void)(*instance)) == 76, "ScrollContainerDataInternal.elementId has unexpected offset % instead of 76", ((cast(*void)(*instance.elementId)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.elementId)) == 4, "ScrollContainerDataInternal.elementId has unexpected size % instead of 4", size_of(type_of(ScrollContainerDataInternal.elementId)));
        assert(((cast(*void)(*instance.openThisFrame)) - cast(*void)(*instance)) == 80, "ScrollContainerDataInternal.openThisFrame has unexpected offset % instead of 80", ((cast(*void)(*instance.openThisFrame)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.openThisFrame)) == 1, "ScrollContainerDataInternal.openThisFrame has unexpected size % instead of 1", size_of(type_of(ScrollContainerDataInternal.openThisFrame)));
        assert(((cast(*void)(*instance.pointerScrollActive)) - cast(*void)(*instance)) == 81, "ScrollContainerDataInternal.pointerScrollActive has unexpected offset % instead of 81", ((cast(*void)(*instance.pointerScrollActive)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternal.pointerScrollActive)) == 1, "ScrollContainerDataInternal.pointerScrollActive has unexpected size % instead of 1", size_of(type_of(ScrollContainerDataInternal.pointerScrollActive)));
        assert(size_of(ScrollContainerDataInternal) == 88, "ScrollContainerDataInternal has size % instead of 88", size_of(ScrollContainerDataInternal));
    }

    {
        instance: ScrollContainerDataInternalArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "ScrollContainerDataInternalArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternalArray.capacity)) == 4, "ScrollContainerDataInternalArray.capacity has unexpected size % instead of 4", size_of(type_of(ScrollContainerDataInternalArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "ScrollContainerDataInternalArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternalArray.length)) == 4, "ScrollContainerDataInternalArray.length has unexpected size % instead of 4", size_of(type_of(ScrollContainerDataInternalArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "ScrollContainerDataInternalArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(ScrollContainerDataInternalArray.internalArray)) == 8, "ScrollContainerDataInternalArray.internalArray has unexpected size % instead of 8", size_of(type_of(ScrollContainerDataInternalArray.internalArray)));
        assert(size_of(ScrollContainerDataInternalArray) == 16, "ScrollContainerDataInternalArray has size % instead of 16", size_of(ScrollContainerDataInternalArray));
    }

    {
        instance: DebugElementData;
        assert(((cast(*void)(*instance.collision)) - cast(*void)(*instance)) == 0, "DebugElementData.collision has unexpected offset % instead of 0", ((cast(*void)(*instance.collision)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementData.collision)) == 1, "DebugElementData.collision has unexpected size % instead of 1", size_of(type_of(DebugElementData.collision)));
        assert(((cast(*void)(*instance.collapsed)) - cast(*void)(*instance)) == 1, "DebugElementData.collapsed has unexpected offset % instead of 1", ((cast(*void)(*instance.collapsed)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementData.collapsed)) == 1, "DebugElementData.collapsed has unexpected size % instead of 1", size_of(type_of(DebugElementData.collapsed)));
        assert(size_of(DebugElementData) == 2, "DebugElementData has size % instead of 2", size_of(DebugElementData));
    }

    {
        instance: DebugElementDataArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "DebugElementDataArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementDataArray.capacity)) == 4, "DebugElementDataArray.capacity has unexpected size % instead of 4", size_of(type_of(DebugElementDataArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "DebugElementDataArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementDataArray.length)) == 4, "DebugElementDataArray.length has unexpected size % instead of 4", size_of(type_of(DebugElementDataArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "DebugElementDataArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementDataArray.internalArray)) == 8, "DebugElementDataArray.internalArray has unexpected size % instead of 8", size_of(type_of(DebugElementDataArray.internalArray)));
        assert(size_of(DebugElementDataArray) == 16, "DebugElementDataArray has size % instead of 16", size_of(DebugElementDataArray));
    }

    {
        instance: LayoutElementHashMapItem;
        assert(((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)) == 0, "LayoutElementHashMapItem.boundingBox has unexpected offset % instead of 0", ((cast(*void)(*instance.boundingBox)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.boundingBox)) == 16, "LayoutElementHashMapItem.boundingBox has unexpected size % instead of 16", size_of(type_of(LayoutElementHashMapItem.boundingBox)));
        assert(((cast(*void)(*instance.elementId)) - cast(*void)(*instance)) == 16, "LayoutElementHashMapItem.elementId has unexpected offset % instead of 16", ((cast(*void)(*instance.elementId)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.elementId)) == 32, "LayoutElementHashMapItem.elementId has unexpected size % instead of 32", size_of(type_of(LayoutElementHashMapItem.elementId)));
        assert(((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)) == 48, "LayoutElementHashMapItem.layoutElement has unexpected offset % instead of 48", ((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.layoutElement)) == 8, "LayoutElementHashMapItem.layoutElement has unexpected size % instead of 8", size_of(type_of(LayoutElementHashMapItem.layoutElement)));
        assert(((cast(*void)(*instance.onHoverFunction)) - cast(*void)(*instance)) == 56, "LayoutElementHashMapItem.onHoverFunction has unexpected offset % instead of 56", ((cast(*void)(*instance.onHoverFunction)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.onHoverFunction)) == 8, "LayoutElementHashMapItem.onHoverFunction has unexpected size % instead of 8", size_of(type_of(LayoutElementHashMapItem.onHoverFunction)));
        assert(((cast(*void)(*instance.hoverFunctionUserData)) - cast(*void)(*instance)) == 64, "LayoutElementHashMapItem.hoverFunctionUserData has unexpected offset % instead of 64", ((cast(*void)(*instance.hoverFunctionUserData)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.hoverFunctionUserData)) == 8, "LayoutElementHashMapItem.hoverFunctionUserData has unexpected size % instead of 8", size_of(type_of(LayoutElementHashMapItem.hoverFunctionUserData)));
        assert(((cast(*void)(*instance.nextIndex)) - cast(*void)(*instance)) == 72, "LayoutElementHashMapItem.nextIndex has unexpected offset % instead of 72", ((cast(*void)(*instance.nextIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.nextIndex)) == 4, "LayoutElementHashMapItem.nextIndex has unexpected size % instead of 4", size_of(type_of(LayoutElementHashMapItem.nextIndex)));
        assert(((cast(*void)(*instance.generation)) - cast(*void)(*instance)) == 76, "LayoutElementHashMapItem.generation has unexpected offset % instead of 76", ((cast(*void)(*instance.generation)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.generation)) == 4, "LayoutElementHashMapItem.generation has unexpected size % instead of 4", size_of(type_of(LayoutElementHashMapItem.generation)));
        assert(((cast(*void)(*instance.debugData)) - cast(*void)(*instance)) == 80, "LayoutElementHashMapItem.debugData has unexpected offset % instead of 80", ((cast(*void)(*instance.debugData)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItem.debugData)) == 8, "LayoutElementHashMapItem.debugData has unexpected size % instead of 8", size_of(type_of(LayoutElementHashMapItem.debugData)));
        assert(size_of(LayoutElementHashMapItem) == 88, "LayoutElementHashMapItem has size % instead of 88", size_of(LayoutElementHashMapItem));
    }

    {
        instance: LayoutElementHashMapItemArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutElementHashMapItemArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItemArray.capacity)) == 4, "LayoutElementHashMapItemArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutElementHashMapItemArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutElementHashMapItemArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItemArray.length)) == 4, "LayoutElementHashMapItemArray.length has unexpected size % instead of 4", size_of(type_of(LayoutElementHashMapItemArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutElementHashMapItemArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementHashMapItemArray.internalArray)) == 8, "LayoutElementHashMapItemArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutElementHashMapItemArray.internalArray)));
        assert(size_of(LayoutElementHashMapItemArray) == 16, "LayoutElementHashMapItemArray has size % instead of 16", size_of(LayoutElementHashMapItemArray));
    }

    {
        instance: MeasuredWord;
        assert(((cast(*void)(*instance.startOffset)) - cast(*void)(*instance)) == 0, "MeasuredWord.startOffset has unexpected offset % instead of 0", ((cast(*void)(*instance.startOffset)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWord.startOffset)) == 4, "MeasuredWord.startOffset has unexpected size % instead of 4", size_of(type_of(MeasuredWord.startOffset)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "MeasuredWord.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWord.length)) == 4, "MeasuredWord.length has unexpected size % instead of 4", size_of(type_of(MeasuredWord.length)));
        assert(((cast(*void)(*instance.width)) - cast(*void)(*instance)) == 8, "MeasuredWord.width has unexpected offset % instead of 8", ((cast(*void)(*instance.width)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWord.width)) == 4, "MeasuredWord.width has unexpected size % instead of 4", size_of(type_of(MeasuredWord.width)));
        assert(((cast(*void)(*instance.next)) - cast(*void)(*instance)) == 12, "MeasuredWord.next has unexpected offset % instead of 12", ((cast(*void)(*instance.next)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWord.next)) == 4, "MeasuredWord.next has unexpected size % instead of 4", size_of(type_of(MeasuredWord.next)));
        assert(size_of(MeasuredWord) == 16, "MeasuredWord has size % instead of 16", size_of(MeasuredWord));
    }

    {
        instance: MeasuredWordArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "MeasuredWordArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWordArray.capacity)) == 4, "MeasuredWordArray.capacity has unexpected size % instead of 4", size_of(type_of(MeasuredWordArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "MeasuredWordArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWordArray.length)) == 4, "MeasuredWordArray.length has unexpected size % instead of 4", size_of(type_of(MeasuredWordArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "MeasuredWordArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasuredWordArray.internalArray)) == 8, "MeasuredWordArray.internalArray has unexpected size % instead of 8", size_of(type_of(MeasuredWordArray.internalArray)));
        assert(size_of(MeasuredWordArray) == 16, "MeasuredWordArray has size % instead of 16", size_of(MeasuredWordArray));
    }

    {
        instance: MeasureTextCacheItem;
        assert(((cast(*void)(*instance.unwrappedDimensions)) - cast(*void)(*instance)) == 0, "MeasureTextCacheItem.unwrappedDimensions has unexpected offset % instead of 0", ((cast(*void)(*instance.unwrappedDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.unwrappedDimensions)) == 8, "MeasureTextCacheItem.unwrappedDimensions has unexpected size % instead of 8", size_of(type_of(MeasureTextCacheItem.unwrappedDimensions)));
        assert(((cast(*void)(*instance.measuredWordsStartIndex)) - cast(*void)(*instance)) == 8, "MeasureTextCacheItem.measuredWordsStartIndex has unexpected offset % instead of 8", ((cast(*void)(*instance.measuredWordsStartIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.measuredWordsStartIndex)) == 4, "MeasureTextCacheItem.measuredWordsStartIndex has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItem.measuredWordsStartIndex)));
        assert(((cast(*void)(*instance.containsNewlines)) - cast(*void)(*instance)) == 12, "MeasureTextCacheItem.containsNewlines has unexpected offset % instead of 12", ((cast(*void)(*instance.containsNewlines)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.containsNewlines)) == 1, "MeasureTextCacheItem.containsNewlines has unexpected size % instead of 1", size_of(type_of(MeasureTextCacheItem.containsNewlines)));
        assert(((cast(*void)(*instance.id)) - cast(*void)(*instance)) == 16, "MeasureTextCacheItem.id has unexpected offset % instead of 16", ((cast(*void)(*instance.id)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.id)) == 4, "MeasureTextCacheItem.id has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItem.id)));
        assert(((cast(*void)(*instance.nextIndex)) - cast(*void)(*instance)) == 20, "MeasureTextCacheItem.nextIndex has unexpected offset % instead of 20", ((cast(*void)(*instance.nextIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.nextIndex)) == 4, "MeasureTextCacheItem.nextIndex has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItem.nextIndex)));
        assert(((cast(*void)(*instance.generation)) - cast(*void)(*instance)) == 24, "MeasureTextCacheItem.generation has unexpected offset % instead of 24", ((cast(*void)(*instance.generation)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItem.generation)) == 4, "MeasureTextCacheItem.generation has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItem.generation)));
        assert(size_of(MeasureTextCacheItem) == 28, "MeasureTextCacheItem has size % instead of 28", size_of(MeasureTextCacheItem));
    }

    {
        instance: MeasureTextCacheItemArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "MeasureTextCacheItemArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItemArray.capacity)) == 4, "MeasureTextCacheItemArray.capacity has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItemArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "MeasureTextCacheItemArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItemArray.length)) == 4, "MeasureTextCacheItemArray.length has unexpected size % instead of 4", size_of(type_of(MeasureTextCacheItemArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "MeasureTextCacheItemArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(MeasureTextCacheItemArray.internalArray)) == 8, "MeasureTextCacheItemArray.internalArray has unexpected size % instead of 8", size_of(type_of(MeasureTextCacheItemArray.internalArray)));
        assert(size_of(MeasureTextCacheItemArray) == 16, "MeasureTextCacheItemArray has size % instead of 16", size_of(MeasureTextCacheItemArray));
    }

    {
        instance: int32_tArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "int32_tArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(int32_tArray.capacity)) == 4, "int32_tArray.capacity has unexpected size % instead of 4", size_of(type_of(int32_tArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "int32_tArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(int32_tArray.length)) == 4, "int32_tArray.length has unexpected size % instead of 4", size_of(type_of(int32_tArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "int32_tArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(int32_tArray.internalArray)) == 8, "int32_tArray.internalArray has unexpected size % instead of 8", size_of(type_of(int32_tArray.internalArray)));
        assert(size_of(int32_tArray) == 16, "int32_tArray has size % instead of 16", size_of(int32_tArray));
    }

    {
        instance: LayoutElementTreeNode;
        assert(((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)) == 0, "LayoutElementTreeNode.layoutElement has unexpected offset % instead of 0", ((cast(*void)(*instance.layoutElement)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNode.layoutElement)) == 8, "LayoutElementTreeNode.layoutElement has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeNode.layoutElement)));
        assert(((cast(*void)(*instance.position)) - cast(*void)(*instance)) == 8, "LayoutElementTreeNode.position has unexpected offset % instead of 8", ((cast(*void)(*instance.position)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNode.position)) == 8, "LayoutElementTreeNode.position has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeNode.position)));
        assert(((cast(*void)(*instance.nextChildOffset)) - cast(*void)(*instance)) == 16, "LayoutElementTreeNode.nextChildOffset has unexpected offset % instead of 16", ((cast(*void)(*instance.nextChildOffset)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNode.nextChildOffset)) == 8, "LayoutElementTreeNode.nextChildOffset has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeNode.nextChildOffset)));
        assert(size_of(LayoutElementTreeNode) == 24, "LayoutElementTreeNode has size % instead of 24", size_of(LayoutElementTreeNode));
    }

    {
        instance: LayoutElementTreeNodeArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutElementTreeNodeArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNodeArray.capacity)) == 4, "LayoutElementTreeNodeArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeNodeArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutElementTreeNodeArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNodeArray.length)) == 4, "LayoutElementTreeNodeArray.length has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeNodeArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutElementTreeNodeArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeNodeArray.internalArray)) == 8, "LayoutElementTreeNodeArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeNodeArray.internalArray)));
        assert(size_of(LayoutElementTreeNodeArray) == 16, "LayoutElementTreeNodeArray has size % instead of 16", size_of(LayoutElementTreeNodeArray));
    }

    {
        instance: LayoutElementTreeRoot;
        assert(((cast(*void)(*instance.layoutElementIndex)) - cast(*void)(*instance)) == 0, "LayoutElementTreeRoot.layoutElementIndex has unexpected offset % instead of 0", ((cast(*void)(*instance.layoutElementIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRoot.layoutElementIndex)) == 4, "LayoutElementTreeRoot.layoutElementIndex has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRoot.layoutElementIndex)));
        assert(((cast(*void)(*instance.parentId)) - cast(*void)(*instance)) == 4, "LayoutElementTreeRoot.parentId has unexpected offset % instead of 4", ((cast(*void)(*instance.parentId)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRoot.parentId)) == 4, "LayoutElementTreeRoot.parentId has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRoot.parentId)));
        assert(((cast(*void)(*instance.clipElementId)) - cast(*void)(*instance)) == 8, "LayoutElementTreeRoot.clipElementId has unexpected offset % instead of 8", ((cast(*void)(*instance.clipElementId)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRoot.clipElementId)) == 4, "LayoutElementTreeRoot.clipElementId has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRoot.clipElementId)));
        assert(((cast(*void)(*instance.zIndex)) - cast(*void)(*instance)) == 12, "LayoutElementTreeRoot.zIndex has unexpected offset % instead of 12", ((cast(*void)(*instance.zIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRoot.zIndex)) == 4, "LayoutElementTreeRoot.zIndex has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRoot.zIndex)));
        assert(((cast(*void)(*instance.pointerOffset)) - cast(*void)(*instance)) == 16, "LayoutElementTreeRoot.pointerOffset has unexpected offset % instead of 16", ((cast(*void)(*instance.pointerOffset)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRoot.pointerOffset)) == 8, "LayoutElementTreeRoot.pointerOffset has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeRoot.pointerOffset)));
        assert(size_of(LayoutElementTreeRoot) == 24, "LayoutElementTreeRoot has size % instead of 24", size_of(LayoutElementTreeRoot));
    }

    {
        instance: LayoutElementTreeRootArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "LayoutElementTreeRootArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRootArray.capacity)) == 4, "LayoutElementTreeRootArray.capacity has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRootArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "LayoutElementTreeRootArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRootArray.length)) == 4, "LayoutElementTreeRootArray.length has unexpected size % instead of 4", size_of(type_of(LayoutElementTreeRootArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "LayoutElementTreeRootArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(LayoutElementTreeRootArray.internalArray)) == 8, "LayoutElementTreeRootArray.internalArray has unexpected size % instead of 8", size_of(type_of(LayoutElementTreeRootArray.internalArray)));
        assert(size_of(LayoutElementTreeRootArray) == 16, "LayoutElementTreeRootArray has size % instead of 16", size_of(LayoutElementTreeRootArray));
    }

    {
        instance: CharArray;
        assert(((cast(*void)(*instance.capacity)) - cast(*void)(*instance)) == 0, "CharArray.capacity has unexpected offset % instead of 0", ((cast(*void)(*instance.capacity)) - cast(*void)(*instance)));
        assert(size_of(type_of(CharArray.capacity)) == 4, "CharArray.capacity has unexpected size % instead of 4", size_of(type_of(CharArray.capacity)));
        assert(((cast(*void)(*instance.length)) - cast(*void)(*instance)) == 4, "CharArray.length has unexpected offset % instead of 4", ((cast(*void)(*instance.length)) - cast(*void)(*instance)));
        assert(size_of(type_of(CharArray.length)) == 4, "CharArray.length has unexpected size % instead of 4", size_of(type_of(CharArray.length)));
        assert(((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)) == 8, "CharArray.internalArray has unexpected offset % instead of 8", ((cast(*void)(*instance.internalArray)) - cast(*void)(*instance)));
        assert(size_of(type_of(CharArray.internalArray)) == 8, "CharArray.internalArray has unexpected size % instead of 8", size_of(type_of(CharArray.internalArray)));
        assert(size_of(CharArray) == 16, "CharArray has size % instead of 16", size_of(CharArray));
    }

    {
        instance: Context;
        assert(((cast(*void)(*instance.maxElementCount)) - cast(*void)(*instance)) == 0, "Context.maxElementCount has unexpected offset % instead of 0", ((cast(*void)(*instance.maxElementCount)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.maxElementCount)) == 4, "Context.maxElementCount has unexpected size % instead of 4", size_of(type_of(Context.maxElementCount)));
        assert(((cast(*void)(*instance.maxMeasureTextCacheWordCount)) - cast(*void)(*instance)) == 4, "Context.maxMeasureTextCacheWordCount has unexpected offset % instead of 4", ((cast(*void)(*instance.maxMeasureTextCacheWordCount)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.maxMeasureTextCacheWordCount)) == 4, "Context.maxMeasureTextCacheWordCount has unexpected size % instead of 4", size_of(type_of(Context.maxMeasureTextCacheWordCount)));
        assert(((cast(*void)(*instance.warningsEnabled)) - cast(*void)(*instance)) == 8, "Context.warningsEnabled has unexpected offset % instead of 8", ((cast(*void)(*instance.warningsEnabled)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.warningsEnabled)) == 1, "Context.warningsEnabled has unexpected size % instead of 1", size_of(type_of(Context.warningsEnabled)));
        assert(((cast(*void)(*instance.errorHandler)) - cast(*void)(*instance)) == 16, "Context.errorHandler has unexpected offset % instead of 16", ((cast(*void)(*instance.errorHandler)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.errorHandler)) == 16, "Context.errorHandler has unexpected size % instead of 16", size_of(type_of(Context.errorHandler)));
        assert(((cast(*void)(*instance.booleanWarnings)) - cast(*void)(*instance)) == 32, "Context.booleanWarnings has unexpected offset % instead of 32", ((cast(*void)(*instance.booleanWarnings)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.booleanWarnings)) == 4, "Context.booleanWarnings has unexpected size % instead of 4", size_of(type_of(Context.booleanWarnings)));
        assert(((cast(*void)(*instance.warnings)) - cast(*void)(*instance)) == 40, "Context.warnings has unexpected offset % instead of 40", ((cast(*void)(*instance.warnings)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.warnings)) == 16, "Context.warnings has unexpected size % instead of 16", size_of(type_of(Context.warnings)));
        assert(((cast(*void)(*instance.pointerInfo)) - cast(*void)(*instance)) == 56, "Context.pointerInfo has unexpected offset % instead of 56", ((cast(*void)(*instance.pointerInfo)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.pointerInfo)) == 12, "Context.pointerInfo has unexpected size % instead of 12", size_of(type_of(Context.pointerInfo)));
        assert(((cast(*void)(*instance.layoutDimensions)) - cast(*void)(*instance)) == 68, "Context.layoutDimensions has unexpected offset % instead of 68", ((cast(*void)(*instance.layoutDimensions)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutDimensions)) == 8, "Context.layoutDimensions has unexpected size % instead of 8", size_of(type_of(Context.layoutDimensions)));
        assert(((cast(*void)(*instance.dynamicElementIndexBaseHash)) - cast(*void)(*instance)) == 80, "Context.dynamicElementIndexBaseHash has unexpected offset % instead of 80", ((cast(*void)(*instance.dynamicElementIndexBaseHash)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.dynamicElementIndexBaseHash)) == 32, "Context.dynamicElementIndexBaseHash has unexpected size % instead of 32", size_of(type_of(Context.dynamicElementIndexBaseHash)));
        assert(((cast(*void)(*instance.dynamicElementIndex)) - cast(*void)(*instance)) == 112, "Context.dynamicElementIndex has unexpected offset % instead of 112", ((cast(*void)(*instance.dynamicElementIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.dynamicElementIndex)) == 4, "Context.dynamicElementIndex has unexpected size % instead of 4", size_of(type_of(Context.dynamicElementIndex)));
        assert(((cast(*void)(*instance.debugModeEnabled)) - cast(*void)(*instance)) == 116, "Context.debugModeEnabled has unexpected offset % instead of 116", ((cast(*void)(*instance.debugModeEnabled)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.debugModeEnabled)) == 1, "Context.debugModeEnabled has unexpected size % instead of 1", size_of(type_of(Context.debugModeEnabled)));
        assert(((cast(*void)(*instance.disableCulling)) - cast(*void)(*instance)) == 117, "Context.disableCulling has unexpected offset % instead of 117", ((cast(*void)(*instance.disableCulling)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.disableCulling)) == 1, "Context.disableCulling has unexpected size % instead of 1", size_of(type_of(Context.disableCulling)));
        assert(((cast(*void)(*instance.externalScrollHandlingEnabled)) - cast(*void)(*instance)) == 118, "Context.externalScrollHandlingEnabled has unexpected offset % instead of 118", ((cast(*void)(*instance.externalScrollHandlingEnabled)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.externalScrollHandlingEnabled)) == 1, "Context.externalScrollHandlingEnabled has unexpected size % instead of 1", size_of(type_of(Context.externalScrollHandlingEnabled)));
        assert(((cast(*void)(*instance.debugSelectedElementId)) - cast(*void)(*instance)) == 120, "Context.debugSelectedElementId has unexpected offset % instead of 120", ((cast(*void)(*instance.debugSelectedElementId)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.debugSelectedElementId)) == 4, "Context.debugSelectedElementId has unexpected size % instead of 4", size_of(type_of(Context.debugSelectedElementId)));
        assert(((cast(*void)(*instance.generation)) - cast(*void)(*instance)) == 124, "Context.generation has unexpected offset % instead of 124", ((cast(*void)(*instance.generation)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.generation)) == 4, "Context.generation has unexpected size % instead of 4", size_of(type_of(Context.generation)));
        assert(((cast(*void)(*instance.arenaResetOffset)) - cast(*void)(*instance)) == 128, "Context.arenaResetOffset has unexpected offset % instead of 128", ((cast(*void)(*instance.arenaResetOffset)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.arenaResetOffset)) == 8, "Context.arenaResetOffset has unexpected size % instead of 8", size_of(type_of(Context.arenaResetOffset)));
        assert(((cast(*void)(*instance.mesureTextUserData)) - cast(*void)(*instance)) == 136, "Context.mesureTextUserData has unexpected offset % instead of 136", ((cast(*void)(*instance.mesureTextUserData)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.mesureTextUserData)) == 8, "Context.mesureTextUserData has unexpected size % instead of 8", size_of(type_of(Context.mesureTextUserData)));
        assert(((cast(*void)(*instance.queryScrollOffsetUserData)) - cast(*void)(*instance)) == 144, "Context.queryScrollOffsetUserData has unexpected offset % instead of 144", ((cast(*void)(*instance.queryScrollOffsetUserData)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.queryScrollOffsetUserData)) == 8, "Context.queryScrollOffsetUserData has unexpected size % instead of 8", size_of(type_of(Context.queryScrollOffsetUserData)));
        assert(((cast(*void)(*instance.internalArena)) - cast(*void)(*instance)) == 152, "Context.internalArena has unexpected offset % instead of 152", ((cast(*void)(*instance.internalArena)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.internalArena)) == 24, "Context.internalArena has unexpected size % instead of 24", size_of(type_of(Context.internalArena)));
        assert(((cast(*void)(*instance.layoutElements)) - cast(*void)(*instance)) == 176, "Context.layoutElements has unexpected offset % instead of 176", ((cast(*void)(*instance.layoutElements)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElements)) == 16, "Context.layoutElements has unexpected size % instead of 16", size_of(type_of(Context.layoutElements)));
        assert(((cast(*void)(*instance.renderCommands)) - cast(*void)(*instance)) == 192, "Context.renderCommands has unexpected offset % instead of 192", ((cast(*void)(*instance.renderCommands)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.renderCommands)) == 16, "Context.renderCommands has unexpected size % instead of 16", size_of(type_of(Context.renderCommands)));
        assert(((cast(*void)(*instance.openLayoutElementStack)) - cast(*void)(*instance)) == 208, "Context.openLayoutElementStack has unexpected offset % instead of 208", ((cast(*void)(*instance.openLayoutElementStack)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.openLayoutElementStack)) == 16, "Context.openLayoutElementStack has unexpected size % instead of 16", size_of(type_of(Context.openLayoutElementStack)));
        assert(((cast(*void)(*instance.layoutElementChildren)) - cast(*void)(*instance)) == 224, "Context.layoutElementChildren has unexpected offset % instead of 224", ((cast(*void)(*instance.layoutElementChildren)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementChildren)) == 16, "Context.layoutElementChildren has unexpected size % instead of 16", size_of(type_of(Context.layoutElementChildren)));
        assert(((cast(*void)(*instance.layoutElementChildrenBuffer)) - cast(*void)(*instance)) == 240, "Context.layoutElementChildrenBuffer has unexpected offset % instead of 240", ((cast(*void)(*instance.layoutElementChildrenBuffer)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementChildrenBuffer)) == 16, "Context.layoutElementChildrenBuffer has unexpected size % instead of 16", size_of(type_of(Context.layoutElementChildrenBuffer)));
        assert(((cast(*void)(*instance.textElementData)) - cast(*void)(*instance)) == 256, "Context.textElementData has unexpected offset % instead of 256", ((cast(*void)(*instance.textElementData)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.textElementData)) == 16, "Context.textElementData has unexpected size % instead of 16", size_of(type_of(Context.textElementData)));
        assert(((cast(*void)(*instance.imageElementPointers)) - cast(*void)(*instance)) == 272, "Context.imageElementPointers has unexpected offset % instead of 272", ((cast(*void)(*instance.imageElementPointers)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.imageElementPointers)) == 16, "Context.imageElementPointers has unexpected size % instead of 16", size_of(type_of(Context.imageElementPointers)));
        assert(((cast(*void)(*instance.reusableElementIndexBuffer)) - cast(*void)(*instance)) == 288, "Context.reusableElementIndexBuffer has unexpected offset % instead of 288", ((cast(*void)(*instance.reusableElementIndexBuffer)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.reusableElementIndexBuffer)) == 16, "Context.reusableElementIndexBuffer has unexpected size % instead of 16", size_of(type_of(Context.reusableElementIndexBuffer)));
        assert(((cast(*void)(*instance.layoutElementClipElementIds)) - cast(*void)(*instance)) == 304, "Context.layoutElementClipElementIds has unexpected offset % instead of 304", ((cast(*void)(*instance.layoutElementClipElementIds)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementClipElementIds)) == 16, "Context.layoutElementClipElementIds has unexpected size % instead of 16", size_of(type_of(Context.layoutElementClipElementIds)));
        assert(((cast(*void)(*instance.layoutConfigs)) - cast(*void)(*instance)) == 320, "Context.layoutConfigs has unexpected offset % instead of 320", ((cast(*void)(*instance.layoutConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutConfigs)) == 16, "Context.layoutConfigs has unexpected size % instead of 16", size_of(type_of(Context.layoutConfigs)));
        assert(((cast(*void)(*instance.elementConfigBuffer)) - cast(*void)(*instance)) == 336, "Context.elementConfigBuffer has unexpected offset % instead of 336", ((cast(*void)(*instance.elementConfigBuffer)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.elementConfigBuffer)) == 16, "Context.elementConfigBuffer has unexpected size % instead of 16", size_of(type_of(Context.elementConfigBuffer)));
        assert(((cast(*void)(*instance.elementConfigs)) - cast(*void)(*instance)) == 352, "Context.elementConfigs has unexpected offset % instead of 352", ((cast(*void)(*instance.elementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.elementConfigs)) == 16, "Context.elementConfigs has unexpected size % instead of 16", size_of(type_of(Context.elementConfigs)));
        assert(((cast(*void)(*instance.rectangleElementConfigs)) - cast(*void)(*instance)) == 368, "Context.rectangleElementConfigs has unexpected offset % instead of 368", ((cast(*void)(*instance.rectangleElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.rectangleElementConfigs)) == 16, "Context.rectangleElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.rectangleElementConfigs)));
        assert(((cast(*void)(*instance.textElementConfigs)) - cast(*void)(*instance)) == 384, "Context.textElementConfigs has unexpected offset % instead of 384", ((cast(*void)(*instance.textElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.textElementConfigs)) == 16, "Context.textElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.textElementConfigs)));
        assert(((cast(*void)(*instance.imageElementConfigs)) - cast(*void)(*instance)) == 400, "Context.imageElementConfigs has unexpected offset % instead of 400", ((cast(*void)(*instance.imageElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.imageElementConfigs)) == 16, "Context.imageElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.imageElementConfigs)));
        assert(((cast(*void)(*instance.floatingElementConfigs)) - cast(*void)(*instance)) == 416, "Context.floatingElementConfigs has unexpected offset % instead of 416", ((cast(*void)(*instance.floatingElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.floatingElementConfigs)) == 16, "Context.floatingElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.floatingElementConfigs)));
        assert(((cast(*void)(*instance.scrollElementConfigs)) - cast(*void)(*instance)) == 432, "Context.scrollElementConfigs has unexpected offset % instead of 432", ((cast(*void)(*instance.scrollElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.scrollElementConfigs)) == 16, "Context.scrollElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.scrollElementConfigs)));
        assert(((cast(*void)(*instance.customElementConfigs)) - cast(*void)(*instance)) == 448, "Context.customElementConfigs has unexpected offset % instead of 448", ((cast(*void)(*instance.customElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.customElementConfigs)) == 16, "Context.customElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.customElementConfigs)));
        assert(((cast(*void)(*instance.borderElementConfigs)) - cast(*void)(*instance)) == 464, "Context.borderElementConfigs has unexpected offset % instead of 464", ((cast(*void)(*instance.borderElementConfigs)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.borderElementConfigs)) == 16, "Context.borderElementConfigs has unexpected size % instead of 16", size_of(type_of(Context.borderElementConfigs)));
        assert(((cast(*void)(*instance.layoutElementIdStrings)) - cast(*void)(*instance)) == 480, "Context.layoutElementIdStrings has unexpected offset % instead of 480", ((cast(*void)(*instance.layoutElementIdStrings)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementIdStrings)) == 16, "Context.layoutElementIdStrings has unexpected size % instead of 16", size_of(type_of(Context.layoutElementIdStrings)));
        assert(((cast(*void)(*instance.wrappedTextLines)) - cast(*void)(*instance)) == 496, "Context.wrappedTextLines has unexpected offset % instead of 496", ((cast(*void)(*instance.wrappedTextLines)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.wrappedTextLines)) == 16, "Context.wrappedTextLines has unexpected size % instead of 16", size_of(type_of(Context.wrappedTextLines)));
        assert(((cast(*void)(*instance.layoutElementTreeNodeArray1)) - cast(*void)(*instance)) == 512, "Context.layoutElementTreeNodeArray1 has unexpected offset % instead of 512", ((cast(*void)(*instance.layoutElementTreeNodeArray1)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementTreeNodeArray1)) == 16, "Context.layoutElementTreeNodeArray1 has unexpected size % instead of 16", size_of(type_of(Context.layoutElementTreeNodeArray1)));
        assert(((cast(*void)(*instance.layoutElementTreeRoots)) - cast(*void)(*instance)) == 528, "Context.layoutElementTreeRoots has unexpected offset % instead of 528", ((cast(*void)(*instance.layoutElementTreeRoots)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementTreeRoots)) == 16, "Context.layoutElementTreeRoots has unexpected size % instead of 16", size_of(type_of(Context.layoutElementTreeRoots)));
        assert(((cast(*void)(*instance.layoutElementsHashMapInternal)) - cast(*void)(*instance)) == 544, "Context.layoutElementsHashMapInternal has unexpected offset % instead of 544", ((cast(*void)(*instance.layoutElementsHashMapInternal)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementsHashMapInternal)) == 16, "Context.layoutElementsHashMapInternal has unexpected size % instead of 16", size_of(type_of(Context.layoutElementsHashMapInternal)));
        assert(((cast(*void)(*instance.layoutElementsHashMap)) - cast(*void)(*instance)) == 560, "Context.layoutElementsHashMap has unexpected offset % instead of 560", ((cast(*void)(*instance.layoutElementsHashMap)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.layoutElementsHashMap)) == 16, "Context.layoutElementsHashMap has unexpected size % instead of 16", size_of(type_of(Context.layoutElementsHashMap)));
        assert(((cast(*void)(*instance.measureTextHashMapInternal)) - cast(*void)(*instance)) == 576, "Context.measureTextHashMapInternal has unexpected offset % instead of 576", ((cast(*void)(*instance.measureTextHashMapInternal)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.measureTextHashMapInternal)) == 16, "Context.measureTextHashMapInternal has unexpected size % instead of 16", size_of(type_of(Context.measureTextHashMapInternal)));
        assert(((cast(*void)(*instance.measureTextHashMapInternalFreeList)) - cast(*void)(*instance)) == 592, "Context.measureTextHashMapInternalFreeList has unexpected offset % instead of 592", ((cast(*void)(*instance.measureTextHashMapInternalFreeList)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.measureTextHashMapInternalFreeList)) == 16, "Context.measureTextHashMapInternalFreeList has unexpected size % instead of 16", size_of(type_of(Context.measureTextHashMapInternalFreeList)));
        assert(((cast(*void)(*instance.measureTextHashMap)) - cast(*void)(*instance)) == 608, "Context.measureTextHashMap has unexpected offset % instead of 608", ((cast(*void)(*instance.measureTextHashMap)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.measureTextHashMap)) == 16, "Context.measureTextHashMap has unexpected size % instead of 16", size_of(type_of(Context.measureTextHashMap)));
        assert(((cast(*void)(*instance.measuredWords)) - cast(*void)(*instance)) == 624, "Context.measuredWords has unexpected offset % instead of 624", ((cast(*void)(*instance.measuredWords)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.measuredWords)) == 16, "Context.measuredWords has unexpected size % instead of 16", size_of(type_of(Context.measuredWords)));
        assert(((cast(*void)(*instance.measuredWordsFreeList)) - cast(*void)(*instance)) == 640, "Context.measuredWordsFreeList has unexpected offset % instead of 640", ((cast(*void)(*instance.measuredWordsFreeList)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.measuredWordsFreeList)) == 16, "Context.measuredWordsFreeList has unexpected size % instead of 16", size_of(type_of(Context.measuredWordsFreeList)));
        assert(((cast(*void)(*instance.openClipElementStack)) - cast(*void)(*instance)) == 656, "Context.openClipElementStack has unexpected offset % instead of 656", ((cast(*void)(*instance.openClipElementStack)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.openClipElementStack)) == 16, "Context.openClipElementStack has unexpected size % instead of 16", size_of(type_of(Context.openClipElementStack)));
        assert(((cast(*void)(*instance.pointerOverIds)) - cast(*void)(*instance)) == 672, "Context.pointerOverIds has unexpected offset % instead of 672", ((cast(*void)(*instance.pointerOverIds)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.pointerOverIds)) == 16, "Context.pointerOverIds has unexpected size % instead of 16", size_of(type_of(Context.pointerOverIds)));
        assert(((cast(*void)(*instance.scrollContainerDatas)) - cast(*void)(*instance)) == 688, "Context.scrollContainerDatas has unexpected offset % instead of 688", ((cast(*void)(*instance.scrollContainerDatas)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.scrollContainerDatas)) == 16, "Context.scrollContainerDatas has unexpected size % instead of 16", size_of(type_of(Context.scrollContainerDatas)));
        assert(((cast(*void)(*instance.treeNodeVisited)) - cast(*void)(*instance)) == 704, "Context.treeNodeVisited has unexpected offset % instead of 704", ((cast(*void)(*instance.treeNodeVisited)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.treeNodeVisited)) == 16, "Context.treeNodeVisited has unexpected size % instead of 16", size_of(type_of(Context.treeNodeVisited)));
        assert(((cast(*void)(*instance.dynamicStringData)) - cast(*void)(*instance)) == 720, "Context.dynamicStringData has unexpected offset % instead of 720", ((cast(*void)(*instance.dynamicStringData)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.dynamicStringData)) == 16, "Context.dynamicStringData has unexpected size % instead of 16", size_of(type_of(Context.dynamicStringData)));
        assert(((cast(*void)(*instance.debugElementData)) - cast(*void)(*instance)) == 736, "Context.debugElementData has unexpected offset % instead of 736", ((cast(*void)(*instance.debugElementData)) - cast(*void)(*instance)));
        assert(size_of(type_of(Context.debugElementData)) == 16, "Context.debugElementData has unexpected size % instead of 16", size_of(type_of(Context.debugElementData)));
        assert(size_of(Context) == 752, "Context has size % instead of 752", size_of(Context));
    }

    {
        instance: DebugElementConfigTypeLabelConfig;
        assert(((cast(*void)(*instance.label)) - cast(*void)(*instance)) == 0, "DebugElementConfigTypeLabelConfig.label has unexpected offset % instead of 0", ((cast(*void)(*instance.label)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementConfigTypeLabelConfig.label)) == 16, "DebugElementConfigTypeLabelConfig.label has unexpected size % instead of 16", size_of(type_of(DebugElementConfigTypeLabelConfig.label)));
        assert(((cast(*void)(*instance.color)) - cast(*void)(*instance)) == 16, "DebugElementConfigTypeLabelConfig.color has unexpected offset % instead of 16", ((cast(*void)(*instance.color)) - cast(*void)(*instance)));
        assert(size_of(type_of(DebugElementConfigTypeLabelConfig.color)) == 16, "DebugElementConfigTypeLabelConfig.color has unexpected size % instead of 16", size_of(type_of(DebugElementConfigTypeLabelConfig.color)));
        assert(size_of(DebugElementConfigTypeLabelConfig) == 32, "DebugElementConfigTypeLabelConfig has size % instead of 32", size_of(DebugElementConfigTypeLabelConfig));
    }

    {
        instance: RenderDebugLayoutData;
        assert(((cast(*void)(*instance.rowCount)) - cast(*void)(*instance)) == 0, "RenderDebugLayoutData.rowCount has unexpected offset % instead of 0", ((cast(*void)(*instance.rowCount)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderDebugLayoutData.rowCount)) == 4, "RenderDebugLayoutData.rowCount has unexpected size % instead of 4", size_of(type_of(RenderDebugLayoutData.rowCount)));
        assert(((cast(*void)(*instance.selectedElementRowIndex)) - cast(*void)(*instance)) == 4, "RenderDebugLayoutData.selectedElementRowIndex has unexpected offset % instead of 4", ((cast(*void)(*instance.selectedElementRowIndex)) - cast(*void)(*instance)));
        assert(size_of(type_of(RenderDebugLayoutData.selectedElementRowIndex)) == 4, "RenderDebugLayoutData.selectedElementRowIndex has unexpected size % instead of 4", size_of(type_of(RenderDebugLayoutData.selectedElementRowIndex)));
        assert(size_of(RenderDebugLayoutData) == 8, "RenderDebugLayoutData has size % instead of 8", size_of(RenderDebugLayoutData));
    }
}

