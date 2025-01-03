RUNTIME_SDL :: Runtime.{ sdl_start, sdl_stop, sdl_update, sdl_render };

#scope_file
SDL :: #import "SDL";
GL  :: #import "GL";

sdl_window: *SDL.SDL_Window;

sdl_start :: () {
    using SDL;
    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    sdl_window = SDL_CreateWindow(
        "Clay with SDL!",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN|SDL_WINDOW_RESIZABLE
    );
    assert(xx sdl_window, to_string(SDL_GetError()));
    
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context := SDL_GL_CreateContext(sdl_window);
    assert(xx gl_context, "Could not create OpenGL context: %\n", to_string(SDL_GetError()));

    GL.gl_load(*GL.gl, SDL_GL_GetProcAddress);
    
    shared_state.measure_text = sdl_measure_text;
    
    // TODO: load assets
}

sdl_stop :: () {
    using SDL;
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
}

sdl_update :: () {
    using SDL;
    
    event: SDL_Event;
    while SDL_PollEvent(*event) {
        if event.type == {
        case SDL_QUIT;  shared_state.should_quit = true;
        case SDL_KEYUP; if event.key.keysym.sym == {
            case SDLK_ESCAPE; shared_state.should_quit = true;
            case SDLK_SPACE;  shared_state.requested_next_runtime = true;
            case SDLK_d;      shared_state.show_debugger = !shared_state.show_debugger;
        }
        case SDL_MOUSEWHEEL; {
            shared_state.mouse_wheel_delta.x = xx event.wheel.x;
            shared_state.mouse_wheel_delta.y = xx event.wheel.y;
        }
        case SDL_WINDOWEVENT; if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
            shared_state.window_width  = xx event.window.data1;
            shared_state.window_height = xx event.window.data2;
        }
        }
    }
    
    {
        x, y: s32;
        SDL_GetMouseState(*x, *y);
        shared_state.mouse_position.x = xx x;
        shared_state.mouse_position.y = xx y;
    }
}

sdl_render :: (commands: *Clay.RenderCommandArray) {
    GL.glViewport(0, 0, xx shared_state.window_width, xx shared_state.window_height);
    GL.glClear(GL.GL_COLOR_BUFFER_BIT);
    
    // TODO: actually draw the stuff!
    
    SDL.SDL_GL_SwapWindow(sdl_window);
}

sdl_measure_text :: (text: *Clay.String, config: *Clay.TextElementConfig) -> Clay.Dimensions #c_call {
    push_context,defer_pop main_thread_context;
    
    // TODO
    
    return .{};
}