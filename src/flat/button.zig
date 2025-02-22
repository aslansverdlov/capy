const std = @import("std");
const backend = @import("../backend.zig");
const Size = @import("../data.zig").Size;
const Color = @import("../color.zig").Color;

/// Button flat peer
pub const FlatButton = struct {
    peer: backend.PeerType,
    canvas: backend.Canvas,

    label: [:0]const u8 = "",
    enabled: bool = true,

    pub usingnamespace backend.Events(FlatButton);

    pub fn create() !FlatButton {
        const canvas = try backend.Canvas.create();
        const events = backend.getEventUserData(canvas.peer);
        events.class.drawHandler = draw;

        return FlatButton{ .peer = canvas.peer, .canvas = canvas };
    }

    // TODO: themes and custom styling
    fn draw(ctx: *backend.Canvas.DrawContext, data: usize) void {
        const events = @intToPtr(*backend.EventUserData, data);
        const self = @intToPtr(?*FlatButton, events.classUserdata).?;

        const width = @intCast(u32, backend.getWidthFromPeer(events.peer));
        const height = @intCast(u32, backend.getHeightFromPeer(events.peer));

        ctx.setColorByte(Color.comptimeFromString("#ffffffb3"));
        // ctx.setColorByte(Color.comptimeFromString("#f9f9f94d"));
        ctx.roundedRectangle(0, 0, width, height, 4);
        ctx.fill();

        ctx.setColorByte(Color.comptimeFromString("#ffffffb3"));
        ctx.setLinearGradient(.{
            .x0 = 0,
            .y0 = 0,
            .x1 = 0,
            .y1 = @intToFloat(f32, height) * 3,
            .stops = &.{
                .{ .offset = 0.33, .color = Color.comptimeFromString("#00000029") },
                .{ .offset = 1.00, .color = Color.comptimeFromString("#0000000F") },
            },
        });
        ctx.roundedRectangle(0, 0, width, height, 4);
        ctx.stroke();

        const text = self.label;
        var layout = backend.Canvas.DrawContext.TextLayout.init();
        defer layout.deinit();
        layout.setFont(.{ .face = "Segoe UI", .size = 14.0 / 96.0 * 72.0 });
        const textSize = layout.getTextSize(text);

        ctx.setColorByte(Color.comptimeFromString("#000000e4"));
        ctx.text(@intCast(i32, (width -| textSize.width) / 2), @intCast(i32, (height -| textSize.height) / 2), layout, text);
        ctx.fill();
    }

    pub fn setLabel(self: *FlatButton, label: [:0]const u8) void {
        self.label = label;
        const events = backend.getEventUserData(self.peer);
        events.classUserdata = @ptrToInt(self);
        self.requestDraw() catch {};
    }

    pub fn getLabel(self: *const FlatButton) [:0]const u8 {
        return self.label;
    }

    pub fn setEnabled(self: *FlatButton, enabled: bool) void {
        self.enabled = enabled;
    }

    pub fn getPreferredSize_impl(self: *const FlatButton) Size {
        _ = self;
        return Size.init(300, 50);
    }
};
