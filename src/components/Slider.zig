const std = @import("std");
const backend = @import("../backend.zig");
const Size = @import("../data.zig").Size;
const DataWrapper = @import("../data.zig").DataWrapper;

pub const Orientation = enum { Horizontal, Vertical };

pub const Slider_Impl = struct {
    pub usingnamespace @import("../internal.zig").All(Slider_Impl);

    peer: ?backend.Slider = null,
    handlers: Slider_Impl.Handlers = undefined,
    dataWrappers: Slider_Impl.DataWrappers = .{},
    value: DataWrapper(f32) = DataWrapper(f32).of(0),
    min: DataWrapper(f32) = DataWrapper(f32).of(0),
    max: DataWrapper(f32) = DataWrapper(f32).of(100),
    enabled: DataWrapper(bool) = DataWrapper(bool).of(true),

    pub fn init() Slider_Impl {
        return Slider_Impl.init_events(Slider_Impl{});
    }

    pub fn _pointerMoved(self: *Slider_Impl) void {
        self.enabled.updateBinders();
    }

    fn wrapperValueChanged(newValue: f32, userdata: usize) void {
        const peer = @intToPtr(*?backend.Slider, userdata);
        peer.*.?.setValue(newValue);
    }

    fn wrapperMinChanged(newValue: f32, userdata: usize) void {
        const peer = @intToPtr(*?backend.Slider, userdata);
        peer.*.?.setMinimum(newValue);
    }

    fn wrapperMaxChanged(newValue: f32, userdata: usize) void {
        const peer = @intToPtr(*?backend.Slider, userdata);
        peer.*.?.setMaximum(newValue);
    }

    fn wrapperEnabledChanged(newValue: bool, userdata: usize) void {
        const peer = @intToPtr(*?backend.Slider, userdata);
        peer.*.?.setEnabled(newValue);
    }

    fn onPropertyChange(self: *Slider_Impl, property_name: []const u8, new_value: *const anyopaque) !void {
        if (std.mem.eql(u8, property_name, "value")) {
            const value = @ptrCast(*const f32, @alignCast(@alignOf(f32), new_value));
            self.value.set(value.*);
        }
    }

    pub fn show(self: *Slider_Impl) !void {
        if (self.peer == null) {
            self.peer = try backend.Slider.create();
            self.peer.?.setMinimum(self.min.get());
            self.peer.?.setMaximum(self.max.get());
            self.peer.?.setValue(self.value.get());
            self.peer.?.setEnabled(self.enabled.get());
            try self.show_events();

            _ = try self.value.addChangeListener(.{ .function = wrapperValueChanged, .userdata = @ptrToInt(&self.peer) });
            _ = try self.min.addChangeListener(.{ .function = wrapperMinChanged, .userdata = @ptrToInt(&self.peer) });
            _ = try self.max.addChangeListener(.{ .function = wrapperMaxChanged, .userdata = @ptrToInt(&self.peer) });
            _ = try self.enabled.addChangeListener(.{ .function = wrapperEnabledChanged, .userdata = @ptrToInt(&self.peer) });

            try self.addPropertyChangeHandler(&onPropertyChange);
        }
    }

    pub fn getPreferredSize(self: *Slider_Impl, available: Size) Size {
        _ = available;
        if (self.peer) |peer| {
            return peer.getPreferredSize();
        } else {
            return Size{ .width = 100.0, .height = 40.0 };
        }
    }

    pub fn _deinit(self: *Slider_Impl) void {
        self.enabled.deinit();
    }
};

pub fn Slider(config: Slider_Impl.Config) Slider_Impl {
    var slider = Slider_Impl.init();
    slider.min.set(config.min);
    slider.max.set(config.max);
    slider.value.set(config.value);
    slider.enabled.set(config.enabled);
    slider.dataWrappers.name.set(config.name);
    if (config.onclick) |onclick| {
        slider.addClickHandler(onclick) catch unreachable; // TODO: improve
    }
    return slider;
}