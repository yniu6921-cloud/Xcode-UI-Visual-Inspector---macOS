#import "PreviewViewController.h"
#import "imgui.h"
#import "imgui_impl_metal.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

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
    _mtkView.clearColor = MTLClearColorMake(0.1, 0.1, 0.1, 1.0);
    _mtkView.preferredFramesPerSecond = 60;
    _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mtkView];

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::GetIO().Fonts->AddFontDefault();
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

    ImGui::ShowDemoWindow();

    ImGui::Render();
    ImDrawData *drawData = ImGui::GetDrawData();

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, encoder);
    [encoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

@end
