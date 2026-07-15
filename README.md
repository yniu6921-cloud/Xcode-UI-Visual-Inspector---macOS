# Xcode UI Visual Inspector - macOS

A minimal Xcode project template demonstrating ImGui rendering on Apple platforms using Metal.

## 中文说明

一个最小化的Xcode项目模板，演示如何在Apple平台上使用Metal渲染ImGui。

### 功能

- ImGui集成（Metal后端）
- 60 FPS实时渲染循环
- ImGui Demo Window展示所有控件
- UIKit生命周期管理（SceneDelegate）

### 系统要求

- macOS 13+ (用于Mac Catalyst构建)
- 或 iOS 15+ / iPadOS 15+
- Xcode 14+
- 支持Metal的设备

### 使用方法

1. 用Xcode打开 `MenuPreview.xcodeproj`
2. 选择目标设备（Mac Catalyst / iOS Simulator / 真机）
3. Command + R 运行

---

## English

### Features

- ImGui integration (Metal backend)
- 60 FPS real-time render loop
- ImGui Demo Window showcasing all widgets
- UIKit lifecycle management (SceneDelegate)

### System Requirements

- macOS 13+ (for Mac Catalyst builds)
- or iOS 15+ / iPadOS 15+
- Xcode 14+
- Metal-capable device

### Usage

1. Open `MenuPreview.xcodeproj` in Xcode
2. Select target device (Mac Catalyst / iOS Simulator / Physical device)
3. Command + R to run

---

## Project Structure

```
Sources/
├── imgui/                  # ImGui library (v1.89+)
│   ├── imgui.h
│   ├── imgui.mm
│   ├── imgui_draw.cpp
│   ├── imgui_tables.cpp
│   ├── imgui_widgets.cpp
│   ├── imgui_impl_metal.h
│   └── imgui_impl_metal.mm
├── PreviewViewController.mm  # Metal + ImGui render loop
├── AppDelegate.m             # App entry
├── SceneDelegate.m           # Window scene setup
└── main.m                    # main()
```

## License

CC BY-NC 4.0 — Non-commercial use only. See [LICENSE](LICENSE) for details.

禁止商用。详见 [LICENSE](LICENSE)。
