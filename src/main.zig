const std = @import("std");
const httpz = @import("httpz");
const handlers = @import("handlers.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app = handlers.App{};

    var server = try httpz.Server(*handlers.App).init(allocator, .{ .address = "0.0.0.0", .port = 8080 }, &app);
    var router = try server.router(.{});

    router.get("/api/v1/sleep/douglas", handlers.handleSleepDouglas, .{});

    const ns_per_s = @as(u64, std.time.ns_per_s);
    const ns_per_ms = @as(u64, std.time.ns_per_ms);
    const ns_per_min = @as(u64, std.time.ns_per_min);
    router.get("/api/v1/sleep/s/:time", handlers.handleRequest, .{
        .data = &ns_per_s,
    });
    router.get("/api/v1/sleep/ms/:time", handlers.handleRequest, .{
        .data = &ns_per_ms,
    });
    router.get("/api/v1/sleep/min/:time", handlers.handleRequest, .{
        .data = &ns_per_min,
    });

    try std.fs.File.stdout().writeAll("saas ready to receive connections on port 8080");

    try server.listen();
}
