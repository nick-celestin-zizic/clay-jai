build_layout_library :: () -> Workspace {
    w := compiler_create_workspace("Layout Library");
    using options := get_build_options(w);
    
    output_type            = .DYNAMIC_LIBRARY;
    output_path            = "output";
    output_executable_name = "layout-new";
    
    set_development_options(*options);
    set_build_options(options, w);
    
    start_workspace(w, "Check");
    add_build_file("source/layout/layout.jai", w);
    return w;
}

build_runner :: () -> Workspace {
    w := compiler_create_workspace("Clay Test");
    using options := get_build_options(w);
    
    output_type            = .EXECUTABLE;
    output_path            = "output";
    output_executable_name = "jai-test";
    
    set_development_options(*options);
    set_build_options(options, w);

    start_workspace(w, "Check");
    add_build_file("source/main.jai", w);
    return w;
}

set_development_options :: (using options: *Build_Options) {
    dead_code_elimination  = .NONE;
    backend                = .X64;
    text_output_flags      = 0;
    temporary_storage_size = 1000*1024;
    set_optimization(options, .VERY_DEBUG);
}

app: Process;

app_start :: () {
    ok := create_process(*app, "output/jai-test.exe");
    assert(ok);
}

app_running :: () -> bool {
    ok, result := get_process_result(*app, 0);
    return ok && result.type == .STILL_RUNNING;
}

#run {
    set_build_options_dc(.{do_output=false});
    ok := true; // it's all gonna be ok :)
    
    ok = make_directory_if_it_does_not_exist("output");
    assert(ok);
    
    if   compile_workspaces(build_layout_library(), build_runner())
    then app_start();
    
    watcher: File_Watcher(void);
    ok = init(*watcher,
        (watcher: *File_Watcher(void), using change: *File_Change, user_data: *void) {
            clear :: "\e[1;1H\e[2J";
            log("%0% was modified. Reloading...", clear, full_path);
            if contains(full_path, "/layout/") {
                if !compile_workspaces(build_layout_library()) return;
            } else {
                kill_process(*app);
                if !compile_workspaces(build_layout_library(), build_runner()) return;
            }
            if !app_running() then app_start();
        },
        null, events_to_watch = .ALL_EVENTS, verbose = true
    );                                        assert(ok);
    ok = add_directories(*watcher, "source"); assert(ok);
    
    while true {
        reset_temporary_storage();
        changed, needs_wait, wait_seconds := process_changes(*watcher);
        sleep_milliseconds(100);
    }
}

#import "Basic";
#import "Process";
#import "Compiler";
#import "BuildCpp";
#import "Bindings_Generator";
#import "Windows";
#import "String";
#import "File_Utilities";
#import "File_Watcher";
#import "File";

// This is a little snippet i like to use when writting smallish metaprograms.
// It just does all of the boilerplate for initializing and passing messages to plugins

plugins: [..]*Metaprogram_Plugin;

start_workspace :: (w: Workspace, $plugin_names: ..string) #compile_time {
    start := plugins.count;
    #insert #run,stallable -> string {
        sb: String_Builder;
        for plugin_names {
            found, name, params := split_from_left(it, #char "(");
            if found then { params.data -= 1; params.count += 1; } else name = it;
            print(*sb, "P%1 :: #import \"%2\"%3; array_add(*plugins, P%1.get_plugin());\n", it_index, name, params);
        }
        return builder_to_string(*sb);
    };
    
    flags: Intercept_Flags;
    for start..plugins.count-1 {
        p := plugins[it];
        p.workspace = w;
        if   p.before_intercept
        then p.before_intercept(p, *flags);
    }
    
    compiler_begin_intercept(w, flags);
    for start..plugins.count-1 {
        p := plugins[it];
        if   p.add_source
        then p.add_source(p);
    }
}

compile_workspaces :: (workspaces: ..Workspace) -> bool #compile_time {
    completed := 0;
    ok := true;
    while true {
        m := compiler_wait_for_message();
        for plugins if it.workspace == m.workspace && it.message then it.message(it, m);
        if m.kind == .COMPLETE {
            completed += 1;
            complete  := cast(*Message_Complete) m;
            if complete.error_code != .NONE then ok = false;
            if completed >= workspaces.count break;
        }
    }
    
    for workspaces compiler_end_intercept(it);
    for plugins if it.finish   then it.finish(it);
    for plugins if it.shutdown then it.shutdown(it);
    for workspaces compiler_destroy_workspace(it);
    array_reset_keeping_memory(*plugins);
    
    return ok;
}