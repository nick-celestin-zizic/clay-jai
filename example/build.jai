#run {
    set_build_options_dc(.{do_output=false});
    ok := true; // it's all going to be ok :)
    
    ok = make_directory_if_it_does_not_exist("output");
    assert(ok);
    
    // TODO: maybe just copy all of the dynamic libraries regardless
    // of platform since this is a toy example that should just work
    ok = copy_file(join(compiler_get_base_path(), "/modules/SDL/windows/SDL2.dll",, temp), "output/SDL2.dll");
    assert(ok);
    
    args := get_build_options().compile_time_command_line;
    if array_find(args, "loop") then run_development_loop();        else
    if array_find(args, "html") then compile_to_single_html_page(); else {
        log_error("usage:\n  for hotreloading loop:\n    jai build.jai - loop\n  for compiling to an html file:\n    jai build.jai - html");
    }
}

run_development_loop :: () {    
    set_development_options :: (using options: *Build_Options) {
        dead_code_elimination  = .NONE;
        backend                = .X64;
        text_output_flags      = 0;
        temporary_storage_size = 1000*1024;
        set_optimization(options, .VERY_DEBUG);
    }
    
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
    
    app: Process;
    run :: (app: *Process) { ok := create_process(app, "output/jai-test.exe"); assert(ok); }
    is_running :: (app: *Process) -> bool { ok, result := get_process_result(app, 0); return ok && result.type == .STILL_RUNNING; }
    
    if   compile_workspaces(build_layout_library(), build_runner())
    then run(*app);
    
    watcher: File_Watcher(Process);
    ok := init(*watcher,
        (watcher: *File_Watcher(Process), using change: *File_Change, app: *Process) {
            clear :: "\e[1;1H\e[2J";
            log("%0% was modified. Reloading...", clear, full_path);
            if contains(full_path, "/layout/") {
                if !compile_workspaces(build_layout_library()) return;
            } else {
                kill_process(app);
                if !compile_workspaces(build_layout_library(), build_runner()) return;
            }
            if !is_running(app) then run(app);
        },
        *app, events_to_watch = .ALL_EVENTS, verbose = true
    );                                         assert(ok);
    ok = add_directories(*watcher, "source");  assert(ok);
    ok = add_directories(*watcher, "modules"); assert(ok);
    
    while true {
        reset_temporary_storage();
        changed, needs_wait, wait_seconds := process_changes(*watcher);
        sleep_milliseconds(100);
    }
}

compile_to_single_html_page :: () {
    log_error("TODO: html output");
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
        
        plugin_flags: Intercept_Flags;
        if   p.before_intercept
        then p.before_intercept(p, *plugin_flags);
        
        // we need to do different logic depending on the type of flags
        // the SKIP_ style flags can only be set if all of the plugins do the skipping,
        // while the DO_ style flags need to be set for the workspace if any of 
        // the plugins ask for it.
        
        if it == start
        then flags  = plugin_flags;
        else flags &= (plugin_flags | .DO_PERFORMANCE_REPORT_POLYMORPHS | .DO_PERFORMANCE_REPORT_RUNS);
        
        if plugin_flags & .DO_PERFORMANCE_REPORT_POLYMORPHS
        then flags |= .DO_PERFORMANCE_REPORT_POLYMORPHS;
        
        if plugin_flags & .DO_PERFORMANCE_REPORT_RUNS
        then flags |= .DO_PERFORMANCE_REPORT_RUNS;
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