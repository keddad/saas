const httpz = @import("httpz");
const std = @import("std");

pub const App = struct {};

pub fn handleRequest(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const time = req.param("time");

    if (time == null) {
        res.status = 400;
        res.body = "Time to wait not set";
        return;
    }

    const timeInt = std.fmt.parseInt(u64, time.?, 10) catch |err| {
        res.status = 400;
        res.body = try std.fmt.allocPrint(res.arena, "Invalid time format: {s}", .{@errorName(err)});
        return;
    };

    const timeMultiplier: *const u64 = @ptrCast(@alignCast(req.route_data));

    if (timeInt * timeMultiplier.* > 5 * std.time.ns_per_min) {
        res.status = 400;
        res.body = "To wait for times longer then 5 minutes, subscribe too Sleep-As-A-Service Pro Max";
        return;
    }

    std.Thread.sleep(timeInt * timeMultiplier.*);
}

pub fn handleSleepDouglas(_: *App, _: *httpz.Request, _: *httpz.Response) !void {
    std.Thread.sleep(std.time.ns_per_s * 42);
}
