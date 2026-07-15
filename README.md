# Xcode UI Visual Inspector

A real-time UI visual inspection tool built with Metal + ImGui, running as a native macOS Catalyst / iOS app.

一个使用 Metal + ImGui 构建的实时 UI 可视化检测工具，以原生 macOS Catalyst / iOS 应用运行。

---

## Features / 功能

- **Real-time overlay rendering** via Metal + ImGui  
  通过 Metal + ImGui 实现实时叠加渲染

- **Floating inspector panel** with toggle switches and sliders  
  浮动检测面板，支持开关和滑块

- **Visual element inspection**: bounding boxes, spacing guides, alignment indicators  
  可视化元素检测：边界框、间距参考线、对齐指示器

- **FPS counter** and performance overlay  
  FPS 计数器和性能叠加层

- **Draggable panel** with macOS-style menu bar  
  可拖拽面板，带 macOS 风格菜单栏

---

## Screenshots / 截图

> Run the project in Xcode to see the inspector in action.  
> 在 Xcode 中运行项目即可查看检测器效果。

---

## Requirements / 环境要求

| Item | Requirement |
|------|-------------|
| Xcode | 15.0+ |
| macOS (build) | macOS 14.0+ (Sonoma) |
| macOS (run, Catalyst) | macOS 14.0+ |
| iOS (run) | iOS 16.0+ |
| Language | Objective-C / Objective-C++ |
| Frameworks | Metal, MetalKit, UIKit |
| Third-party | [Dear ImGui](https://github.com/ocornut/imgui) (included) |

---

## Build & Run / 编译运行

### 1. Clone

```bash
git clone https://github.com/yniu6921-cloud/xcode-ui-visual-inspector.git
cd xcode-ui-visual-inspector
```

### 2. Open in Xcode

```bash
open MenuPreview.xcodeproj
```

### 3. Select Target

- **My Mac (Designed for iPad)** — runs as macOS Catalyst app
- **iPhone / iPad Simulator** — runs on iOS simulator

### 4. Build & Run

Press `Cmd + R` or click the Run button.

---

## Usage / 使用方法

1. **Launch** the app — you will see a dark canvas with real-time rendered visual elements  
   启动应用后会看到一个深色画布，上面有实时渲染的可视化元素

2. **Tap the floating button** (bottom-right corner) to toggle the macOS-style menu bar  
   点击右下角浮动按钮切换 macOS 风格菜单栏

3. **Use menu items** to enable/disable inspector overlays:  
   使用菜单项启用/禁用检测叠加层：
   - Layout: bounding boxes, spacing, alignment / 布局：边界框、间距、对齐
   - Colors: color picker overlay, contrast checker / 颜色：取色器叠加、对比度检查
   - Typography: font info, baseline grid / 字体：字体信息、基线网格

4. **Drag the floating panel** to reposition it anywhere on screen  
   拖拽浮动面板可放置在屏幕任意位置

---

## Project Structure / 项目结构

```
Sources/
├── main.m                    Entry point / 入口
├── AppDelegate.h/m           App lifecycle + menu bar / 应用生命周期 + 菜单栏
├── SceneDelegate.h/m         Window scene setup / 窗口场景配置
├── PreviewViewController.h/mm   Metal + ImGui rendering / Metal + ImGui 渲染核心
├── FloatingMenu.h/mm         Floating inspector panel / 浮动检测面板
├── Info.plist                App configuration / 应用配置
└── imgui/                    Dear ImGui source (vendored) / ImGui 源码（内置）
```

---

## How It Works / 工作原理

1. `MTKView` provides the Metal rendering surface  
   `MTKView` 提供 Metal 渲染表面

2. Each frame, ImGui draws overlay graphics (boxes, lines, text) via `ImDrawList`  
   每帧通过 `ImDrawList` 绘制叠加图形（框、线、文字）

3. `ImGui_ImplMetal` renders the draw data into the Metal command buffer  
   `ImGui_ImplMetal` 将绘制数据渲染到 Metal 命令缓冲区

4. UIKit views (menu bar, floating panel) sit on top of the Metal layer  
   UIKit 视图（菜单栏、浮动面板）位于 Metal 层之上

---

## Compatibility / 兼容性

| Platform | Status |
|----------|--------|
| macOS (Catalyst) | ✅ Supported |
| iOS (Device) | ✅ Supported |
| iOS Simulator | ✅ Supported |
| iPadOS | ✅ Supported |
| visionOS | ❌ Not tested |

---

## License / 许可证

This project is licensed under **CC BY-NC 4.0** (Creative Commons Attribution-NonCommercial 4.0 International).

本项目使用 **CC BY-NC 4.0** 许可证（知识共享 署名-非商业性使用 4.0 国际）。

- ✅ You may use, modify, and share for personal/educational/research purposes  
  可用于个人/教育/研究目的的使用、修改和分享

- ❌ Commercial use is NOT permitted without written permission  
  未经书面许可，禁止商业使用

See [LICENSE](LICENSE) for full terms.
