# Clay bindings for Jai
- Currently only provide precompiled libraries for Windows.
- If you run `jai generate.jai` the latest version of clay will be fetched and compiled for your platform.
- The example allows you to edit the layout code in real time!

https://github.com/user-attachments/assets/d5473715-cbd4-4705-8fcb-4821877e2a9d

# Macro Api
- The library provide macros similar to the ones in the C library and they can be found at the top of module.jai
```go
component :: () {
    Element(ID("OuterElement"),
        Layout(.{
            sizing = .{ SizingGrow(), SizingFit(.{ min = window_height -  50}) },
            childAlignment = .{0, .CENTER},
            padding = .{x = 50}
        })
    );
    
    // all code below this point is a child of OuterElement
    // since the children parameter was not provided to the
    // Element macro
    
    config := StoreTextElementConfig(.{ fontSize = 12, fontId = FONT_BODY, textColor = COLOR_RED });
    
    // here is how you specify an element with children
    Element(ID("TextContainer"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.5) },
            layoutDirection = .TOP_TO_BOTTOM,
            childGap = 12
        }),
        children = #code {
        Text("Heading", config);
        { Element(ID("Spacer"), Layout(.{ sizing = .{ width = SizingGrow(.{ max = 25 }) } })); }
        Text("Foo", config);
        Text("Bar", config);
        Text("Baz", config);
    });
    
    Element(ID("Image"),
        Layout(.{
            sizing = .{ width = SizingPercent(0.50) },
            childAlignment = .{x = .CENTER}
        }),
        Image(.{ sourceDimensions = .{1136, 1194}, imageData = image_data }),
        children = Text("Very nice!", config);
    );
}
```


