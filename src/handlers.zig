const httpz = @import("httpz");
const std = @import("std");

pub const App = struct {};

pub fn handleSleepDouglas(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    std.Thread.sleep(std.time.ns_per_s * 42);

    _ = app;
    _ = req;
    _ = res;
}
