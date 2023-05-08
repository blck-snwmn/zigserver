const std = @import("std");

pub fn main() !void {
    var server = std.http.Server.init(std.heap.page_allocator, .{ .reuse_address = true });
    defer server.deinit();

    try server.listen(try std.net.Address.parseIp("127.0.0.1", 8080));

    while (true) {
        const res = try server.accept(.{ .dynamic = 8192 });

        const thread = try std.Thread.spawn(.{}, handler, .{res});
        thread.detach();
    }
}

fn handler(res: *std.http.Server.Response) !void {
    defer res.reset();

    try res.wait();
    std.debug.print("requested: {}\n", .{res.request});
    const message = "Hello, World!\nThis is a zig http server.\n";

    res.transfer_encoding = .{ .content_length = message.len };
    try res.do();
    _ = try res.write(message);
}
