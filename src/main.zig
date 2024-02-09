const std = @import("std");
const gl = @import("zgl");
const glfw = @import("mach-glfw");

// Function to pass glfw window to OpenGL
fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.binding.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

fn framebufferSizeCallback(_: glfw.Window, width: u32, height: u32) void {
    gl.viewport(0, 0, width, height);
}

fn logGlfwError(msg: [:0] const u8, err: glfw.Error) void {
    std.log.err("GLFW {s} - {}: {s}\n", .{msg, err.error_code, err.description});
}

fn logGlfwError2(msg: [:0] const u8) void {
    if (glfw.getError()) |err| {
        logGlfwError(msg, err);
        return;
    }
    return;
}

inline fn checkForGlfwError() glfw.ErrorCode!void {
    const e = glfw.ErrorCode;
    if (glfw.getError()) |err| {
        logGlfwError("ERROR", err);
        return switch (err.error_code) {
            e.NotInitialized,
            e.OutOfMemory,
            e.PlatformError,
            e.PlatformUnavailable,
            e.NoWindowContext => err.error_code,
            else => return
        };
    }
    return;
}

pub fn main() anyerror!void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        if (glfw.getError()) |err| {
            std.log.err("failed to initialise GLFW due to {}: {?s}", .{err.error_code, err.description});
            return err.error_code;
        }
    }
    defer glfw.terminate();

    const window = glfw.Window.create(640, 480, "GLFW Test", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 5
    }) orelse {
        logGlfwError2("failed to create a window");
        return;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const proc: glfw.GLProc = undefined;
    try gl.loadExtensions(proc, glGetProcAddress);

    window.setFramebufferSizeCallback(framebufferSizeCallback);

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(1, 0, 1, 1);
        gl.clear(.{.color = true});

        window.swapBuffers();
        glfw.pollEvents();
    }
}

fn processInput(window: glfw.Window) void {
    if (window.getKey(glfw.Key.escape) == glfw.Action.press) {
        window.setShouldClose(true);
    }
}

