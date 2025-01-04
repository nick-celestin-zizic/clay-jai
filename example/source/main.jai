#load "common.jai";
#load "runtime_simp.jai";
#load "runtime_sdl.jai";

main_thread_context: *#Context; // for clay callbacks because they don't have userdata
shared_state: State; // state that we pass to the layout library

main :: () {
    set_working_directory(String.path_strip_filename(System.get_path_of_running_executable()));
    main_thread_context = *context;
    
    shared_state.handle_error = .{
        (using error: Clay.ErrorData) -> void #c_call {
            push_context,defer_pop cast(*#Context) userData;
            assert(false, "CLAY ERROR %: %", errorType, string.{xx errorText.length, xx errorText.chars});
        },
        xx main_thread_context
    };
    
    // Windows is very bad at thread-switching by default unless you do this. Sad.
    #if OS == .WINDOWS {
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }
    
    RUNTIMES[current_runtime_index].start();
    
    layout_library: Library;
    while !shared_state.should_quit {
        reset_temporary_storage();
        
        new_library := load_library(layout_library);
        if   new_library.handle
        then layout_library = new_library;
        
        RUNTIMES[current_runtime_index].update();
        if shared_state.requested_next_runtime {
            shared_state.requested_next_runtime = false;
            RUNTIMES[current_runtime_index].stop();
            Initialize(*shared_state.images);
            
            current_runtime_index = (current_runtime_index+1) % RUNTIMES.count;
            RUNTIMES[current_runtime_index].start();
            
            layout_library.layout_init(*shared_state, null);
            RUNTIMES[current_runtime_index].update();
        }
        
        render_commands := layout_library.layout_update(*shared_state);
        RUNTIMES[current_runtime_index].render(*render_commands);
    }
}

Runtime :: struct {
    start, stop, update: ();
    render: (*Clay.RenderCommandArray);
}

current_runtime_index := 0;
RUNTIMES :: Runtime.[
    RUNTIME_SIMP,
    RUNTIME_SDL,
];

Library :: struct {
    handle: *void;
    using procedures: Layout_Library_Procedures;
}

load_library :: (old_library: Library) -> Library {
    using File_Utilities; using File;
    if !file_exists(LAYOUT_LIBRARY_FILES[0].new) {
        if old_library.handle {
            return .{}; // No new library, do nothing!
        } else {
            // We need a library, but do not have one loaded!
            // Maybe there is an old library we can rename and use instead?
            if file_exists(LAYOUT_LIBRARY_FILES[0].old) {
                for LAYOUT_LIBRARY_FILES atomic_file_replace_or_just_rename_if_destination_file_does_not_exist(it.old, it.new);
            } else {
                log_error("could not find any layout dll!");
                return .{};
            }
        }
    }
    
    // we do this to check that dll is ready to be opened
    // and not still being used by the compiler to generate it
    dummy_library := load_dynamic_library("layout-new", struct{});
    if !dummy_library return .{};
    
    clay_state := ifx old_library.layout_get_clay_state then old_library.layout_get_clay_state();
    
    if old_library.handle then unload_dynamic_library(old_library.handle);
    unload_dynamic_library(dummy_library);
    
    for LAYOUT_LIBRARY_FILES atomic_file_replace_or_just_rename_if_destination_file_does_not_exist(it.new, it.old);
    
    using new_library: Library = ---;
    handle, procedures = load_dynamic_library("layout", Layout_Library_Procedures);
    assert(xx handle);
    assert(xx layout_init);
    assert(xx layout_update);
    assert(xx layout_get_clay_state);
    
    layout_init(*shared_state, ifx old_library.layout_get_clay_state then *clay_state);
    return new_library;
}


// this is kind of dumb, but we want to rename all of the files associated with the layout library
#if OS == .WINDOWS {
    LAYOUT_LIBRARY_FILES :: struct {old, new: string;}.[
        .{"layout.dll", "layout-new.dll"},
        .{"layout.exp", "layout-new.exp"},
        .{"layout.lib", "layout-new.lib"},
        .{"layout.pdb", "layout-new.pdb"},
    ];
    
    load_dynamic_library :: (basename: string, $procedure_table_type: Type) -> *void, procedure_table_type {
        table: procedure_table_type;
        
        handle := Windows.LoadLibraryA(tprint("%.dll\0", basename).data);
        if !handle return null, table;
        
        for type_info(procedure_table_type).members {
                    // cast(cast(*procedures, *u8) + it.offset_in_bytes, **void)
                    // (*table.(*u8) + it.offset_in_bytes).(**void)
            address := (cast(**void)((cast(*u8) *table) + it.offset_in_bytes));
            address.* = Windows.GetProcAddress(handle, it.name.data);
            if !address.* {
                Windows.FreeLibrary(handle);
                empty_table: procedure_table_type;
                // log_error("Could not get % from %.dll: %", it.name, basename, System.get_error_string(System.get_error_value()));
                return null, empty_table;
            }
        }
        
        return handle, table;
    }
    
    unload_dynamic_library :: inline (library_handle: *void) {
        Windows.FreeLibrary(library_handle);
    }
} else {
    #assert false "TODO: implement for this OS";
}


using Basic     :: #import "Basic";
Compiler        :: #import "Compiler";
Program_Print   :: #import "Program_Print";
Math            :: #import "Math";
File            :: #import "File";
Hash            :: #import "Hash";
Hash_Table      :: #import "Hash_Table";
String          :: #import "String";
Pool            :: #import "Pool";
System          :: #import "System";
Window_Creation :: #import "Window_Creation";
Windows         :: #import "Windows";
File_Utilities  :: #import "File_Utilities";
Clay            :: #import,file "../../module.jai";

