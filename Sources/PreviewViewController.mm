#import "PreviewViewController.h"
#import "imgui.h"
#import "imgui_impl_metal.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

struct DemoNode {
    float x, y;
    float width, height;
    const char *label;
    ImU32 color;
};

static DemoNode demoNodes[] = {
    {0.2f, 0.3f, 120.0f, 60.0f, "UIView", IM_COL32(52, 152, 219, 255)},
    {0.5f, 0.2f, 100.0f, 50.0f, "UILabel", IM_COL32(46, 204, 113, 255)},
    {0.7f, 0.5f, 110.0f, 55.0f, "UIButton", IM_COL32(231, 76, 60, 255)},
    {0.3f, 0.6f, 130.0f, 65.0f, "UIImageView", IM_COL32(155, 89, 182, 255)},
    {0.6f, 0.7f, 100.0f, 50.0f, "UIStackView", IM_COL32(241, 196, 15, 255)},
};
static const int demoNodeCount = 5;

@interface PreviewViewController () <MTKViewDelegate>
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    _mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:_device];
    _mtkView.delegate = self;
    _mtkView.clearColor = MTLClearColorMake(0.08, 0.08, 0.12, 1.0);
    _mtkView.preferredFramesPerSecond = 60;
    _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mtkView];

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    io.Fonts->AddFontDefault();
    ImGui::StyleColorsDark();
    ImGui_ImplMetal_Init(_device);
}

- (void)dealloc {
    ImGui_ImplMetal_Shutdown();
    ImGui::DestroyContext();
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

- (void)drawInMTKView:(MTKView *)view {
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);
    CGFloat scale = view.window.screen.scale;
    if (scale < 1.0) scale = 1.0;
    io.DisplayFramebufferScale = ImVec2(scale, scale);

    static double lastTime = 0;
    double now = CACurrentMediaTime();
    io.DeltaTime = lastTime > 0 ? (float)(now - lastTime) : (1.0f / 60.0f);
    lastTime = now;

    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *rpd = view.currentRenderPassDescriptor;
    if (!rpd) return;

    ImGui_ImplMetal_NewFrame(rpd);
    ImGui::NewFrame();

    [self drawInspectorOverlay];

    ImGui::Render();
    ImDrawData *drawData = ImGui::GetDrawData();

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, encoder);
    [encoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

#pragma mark - Inspector Overlay

- (void)drawInspectorOverlay {
    ImDrawList *dl = ImGui::GetForegroundDrawList();
    float W = ImGui::GetIO().DisplaySize.x;
    float H = ImGui::GetIO().DisplaySize.y;

    const char *title = "UI Visual Inspector";
    ImVec2 titleSize = ImGui::CalcTextSize(title);
    dl->AddText(ImVec2((W - titleSize.x) * 0.5f, 10.0f), IM_COL32(255, 255, 255, 255), title);

    char fpsBuf[32];
    snprintf(fpsBuf, sizeof(fpsBuf), "FPS: %.0f", ImGui::GetIO().Framerate);
    dl->AddText(ImVec2(W - 80, 10), IM_COL32(0, 255, 0, 255), fpsBuf);

    float time = (float)CACurrentMediaTime();

    for (int i = 0; i < demoNodeCount; i++) {
        DemoNode &n = demoNodes[i];
        float px = n.x * W + sinf(time * 0.4f + i * 1.5f) * 8.0f;
        float py = n.y * H + cosf(time * 0.3f + i * 0.9f) * 6.0f;

        ImVec2 tl(px - n.width / 2, py - n.height / 2);
        ImVec2 br(px + n.width / 2, py + n.height / 2);

        dl->AddRectFilled(tl, br, IM_COL32(30, 30, 40, 180), 4.0f);
        dl->AddRect(tl, br, n.color, 4.0f, 0, 2.0f);

        ImVec2 labelSize = ImGui::CalcTextSize(n.label);
        dl->AddText(ImVec2(px - labelSize.x / 2, py - labelSize.y / 2),
                    IM_COL32(255, 255, 255, 230), n.label);

        char sizeBuf[32];
        snprintf(sizeBuf, sizeof(sizeBuf), "%.0fx%.0f", n.width, n.height);
        ImVec2 sizeTextSize = ImGui::CalcTextSize(sizeBuf);
        dl->AddText(ImVec2(px - sizeTextSize.x / 2, br.y + 4),
                    IM_COL32(180, 180, 180, 200), sizeBuf);

        if (i > 0) {
            DemoNode &prev = demoNodes[i - 1];
            float prevX = prev.x * W + sinf(time * 0.4f + (i-1) * 1.5f) * 8.0f;
            float prevY = prev.y * H + cosf(time * 0.3f + (i-1) * 0.9f) * 6.0f;
            dl->AddLine(ImVec2(prevX, prevY), ImVec2(px, py),
                        IM_COL32(100, 100, 100, 80), 1.0f);
        }
    }

    float cx = W / 2, cy = H / 2;
    dl->AddLine(ImVec2(cx - 8, cy), ImVec2(cx + 8, cy), IM_COL32(255, 255, 255, 60), 1.0f);
    dl->AddLine(ImVec2(cx, cy - 8), ImVec2(cx, cy + 8), IM_COL32(255, 255, 255, 60), 1.0f);
}

@end
