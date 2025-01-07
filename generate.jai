// this script is going to fetch the latest version of the clay.h from github and build it!
// so change this url if you want to download a specific release or something!
clay_url :: "https://raw.githubusercontent.com/nicbarker/clay/refs/heads/main/clay.h";
#run {
    set_build_options_dc(.{do_output=false});
    
    assert(download_file(clay_url, "clay.c"));
    
    // we use static if here not because we need to know this at compile-time
    // (it already is compile-time!), but because #if does not introduce a new scope
    #if OS == {
    case .WINDOWS; lib_path :: "windows";
    case; assert(false, "TODO: OS %", OS);
    }
    
    lib := join(lib_path, "/clay",, temp);
    assert(build_cpp_static_lib(lib, "clay.c",
        debug = true, // I default to compilng with debug info, change this if you want to build for release!
        extra = .["-DCLAY_IMPLEMENTATION"],
    ));
    log("OK! compiled %", lib);
    
    // generate bindings for clay
    // NOTE: I am pretty sure that line 6945 of modules/Bindings_Generator/module.jai
    // is a bug as it should not set the is_shared_library flag in the case a static
    // one is being compiled. You will have to comment out that line for the script to work!
    // I will submit a bug report and update this section if that changes.
    {   using options: Generate_Bindings_Options;
        header = clay_header;
        static_library_suffix = STATIC_LIBRARY_SUFFIX;
        array_add(*strip_prefixes, "Clay__", "Clay_", "CLAY_");
        array_add(*extra_clang_arguments, "-DCLAY_IMPLEMENTATION");
        array_add(*source_files, "clay.c");
        array_add(*libpaths, lib_path);
        array_add(*libnames, join("clay", STATIC_LIBRARY_SUFFIX,, temp));
        visitor = (using decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
            names_to_remove :: string.[
                "CLAY_IMPLEMENTATION",
                "CLAY__NULL",
                "CLAY__MAXFLOAT",
                "CLAY__DEBUGVIEW_ROW_HEIGHT",
                "CLAY__DEBUGVIEW_OUTER_PADDING",
                "CLAY__DEBUGVIEW_INDENT_WIDTH",
            ];
            if name == "Clay_Border" {
                output_name = "BorderData";
                return .STOP;
            } else if begins_with(name, "Clay__Align") || array_find(names_to_remove, name) {
                decl_flags |= .OMIT_FROM_OUTPUT;
                return .STOP;
            } else if kind == .DECLARATION && !(decl_flags & .IS_CONST) {
                // some globals have default values, but we want to get rid of that so that they
                // properly get marked as #elsewhere instead of making seperate variables
                expression = null;
                output_name = stripped_name(name); // global vars don't get stripped by default??
                return .STOP;
            }
            return .RECURSE;
        }
        assert(generate_bindings(options, "module.jai"));
    }
    
    // TODO: compile generated module.jai file to generate a globals struct and save/restore procs?
}

clay_header :: #string _JAI
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

Clay__tArray :: struct {
	capacity: u32;
	length: u32;
	internalArray: *void;
}
_JAI;

#import "Basic";
#import "String";
#import "Compiler";
#import "BuildCpp";
#import "Bindings_Generator";
#import "Curl";
#import "File";

download_file :: (url: string, target: string) -> bool {
    curl := curl_easy_init();
    if !curl {
        log_error("An error occured while initting up the Curl connection, but Curl doesn't tell us why.");
        return false;
    }
    defer curl_easy_cleanup(curl);
    defer curl_easy_reset(curl);
    
    // Set output info
    out_file, ok := file_open(target, for_writing=true);
    if !ok {
        log_error("Failed to open the output file '%' for storing the download.", target);
        return false;
    }
    defer file_close(*out_file);
    
    curl_easy_setopt(curl, .URL, temp_c_string(url));
    curl_easy_setopt(curl, .FOLLOWLOCATION, true);
    curl_easy_setopt(curl, .SSL_VERIFYPEER, 0);
    curl_easy_setopt(curl, .USERAGENT, "curl");
    curl_easy_setopt(curl, .WRITEDATA, *out_file);
    curl_easy_setopt(curl, .WRITEFUNCTION, (contents: *u8, count: u64, size: u64, file: *File) -> u64 #c_call {
        total_size := count * size;
        push_context { file_write(file, contents, cast(s64) total_size); }
        return total_size;
    });
    
    error_code := curl_easy_perform(curl);
    if error_code != .OK {
        error_message := to_string(curl_easy_strerror(error_code));
        defer free(error_message);
        log_error("Curl Error: % (%)", error_message, error_code);
        return false;
    }
    
    return true;
}