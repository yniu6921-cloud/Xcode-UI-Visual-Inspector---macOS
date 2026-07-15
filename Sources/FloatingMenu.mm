#import "FloatingMenu.h"

static const CGFloat kMenuW  = 260;
static const CGFloat kItemH  = 28;
static const CGFloat kHeaderH = 22;

#define kBgColor       [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:0.97]
#define kTextColor     [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0]
#define kSecColor      [UIColor colorWithRed:0.44 green:0.44 blue:0.46 alpha:1.0]
#define kSepColor      [UIColor colorWithRed:0.80 green:0.80 blue:0.82 alpha:1.0]
#define kAccentColor   [UIColor colorWithRed:0.0  green:0.44 blue:0.97 alpha:1.0]

@interface InspectorItemView : UIControl
@property (nonatomic, assign) BOOL itemOn;
@property (nonatomic, copy) NSString *itemTitle;
@end

@implementation InspectorItemView {
    UILabel *_checkLabel;
    UILabel *_titleLabel;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (!self) return nil;
    self.itemTitle = title;
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 5;

    _checkLabel = [[UILabel alloc] init];
    _checkLabel.text = @"";
    _checkLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    _checkLabel.textColor = kAccentColor;
    _checkLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_checkLabel];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = title;
    _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    _titleLabel.textColor = kTextColor;
    [self addSubview:_titleLabel];

    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)tapped {
    self.itemOn = !self.itemOn;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setItemOn:(BOOL)on {
    _itemOn = on;
    _checkLabel.text = on ? @"✓" : @"";
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? kAccentColor : [UIColor clearColor];
    _titleLabel.textColor = highlighted ? [UIColor whiteColor] : kTextColor;
    _checkLabel.textColor = highlighted ? [UIColor whiteColor] : kAccentColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat h = self.bounds.size.height;
    _checkLabel.frame = CGRectMake(4, 0, 22, h);
    _titleLabel.frame = CGRectMake(28, 0, self.bounds.size.width - 36, h);
}
@end

@interface InspectorSliderRow : UIView
@end

@implementation InspectorSliderRow {
    UILabel *_title;
    UILabel *_valLabel;
    UISlider *_slider;
}

- (instancetype)initWithTitle:(NSString *)title min:(float)mn max:(float)mx val:(float)v {
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];

    _title = [[UILabel alloc] init];
    _title.text = title;
    _title.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _title.textColor = kTextColor;
    [self addSubview:_title];

    _valLabel = [[UILabel alloc] init];
    _valLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
    _valLabel.textColor = kSecColor;
    _valLabel.text = [NSString stringWithFormat:@"%.1f", v];
    _valLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_valLabel];

    _slider = [[UISlider alloc] init];
    _slider.minimumValue = mn;
    _slider.maximumValue = mx;
    _slider.value = v;
    [_slider addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_slider];
    return self;
}

- (void)changed:(UISlider *)s {
    _valLabel.text = [NSString stringWithFormat:@"%.1f", s.value];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    _title.frame    = CGRectMake(28,  4, 100, 18);
    _valLabel.frame = CGRectMake(w - 44, 4, 40, 18);
    _slider.frame   = CGRectMake(28, 22, w - 40, 22);
}
@end

@interface FloatingMenu ()
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation FloatingMenu

+ (instancetype)sharedInstance {
    static FloatingMenu *inst;
    static dispatch_once_t tok;
    dispatch_once(&tok, ^{ inst = [[self alloc] initWithFrame:CGRectZero]; });
    return inst;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && !self.panel) {
        self.frame = self.superview.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self buildPanel];
    }
}

- (void)buildPanel {
    CGRect screen = self.bounds;
    if (screen.size.width < 1) screen = [UIScreen mainScreen].bounds;

    CGFloat contentH = [self measureContentHeight];
    CGFloat panelH = MIN(contentH + 8, screen.size.height * 0.8);

    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMenuW, panelH)];
    panel.center = CGPointMake(screen.size.width / 2, screen.size.height / 2);
    panel.backgroundColor = kBgColor;
    panel.layer.cornerRadius = 9;
    panel.layer.masksToBounds = NO;
    panel.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
    panel.layer.shadowOffset = CGSizeMake(0, 8);
    panel.layer.shadowRadius = 20;
    panel.layer.shadowOpacity = 1.0;
    panel.layer.borderWidth = 0.5;
    panel.layer.borderColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.72 alpha:0.6].CGColor;
    [self addSubview:panel];
    self.panel = panel;

    UIView *clip = [[UIView alloc] initWithFrame:panel.bounds];
    clip.layer.cornerRadius = 9;
    clip.layer.masksToBounds = YES;
    clip.backgroundColor = [UIColor clearColor];
    [panel addSubview:clip];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [panel addGestureRecognizer:pan];

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 4, kMenuW, panelH - 8)];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.showsVerticalScrollIndicator = YES;
    scroll.alwaysBounceVertical = NO;
    [clip addSubview:scroll];
    self.scrollView = scroll;

    [self populateScroll];
}

- (CGFloat)measureContentHeight {
    return kHeaderH + 4 * kItemH + 8 + kHeaderH + 3 * 46 + 8 + kHeaderH + 3 * kItemH + 16;
}

- (void)populateScroll {
    __block CGFloat y = 4;
    CGFloat w = kMenuW - 8;

    void (^addSep)(void) = ^{
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(4, y, w, 1)];
        sep.backgroundColor = kSepColor;
        [self.scrollView addSubview:sep];
        y += 5;
    };

    void (^addHeader)(NSString *) = ^(NSString *title) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(8, y, w, kHeaderH)];
        lbl.text = [title uppercaseString];
        lbl.font = [UIFont systemFontOfSize:10.5 weight:UIFontWeightSemibold];
        lbl.textColor = kSecColor;
        [self.scrollView addSubview:lbl];
        y += kHeaderH;
    };

    void (^addItem)(NSString *) = ^(NSString *title) {
        InspectorItemView *item = [[InspectorItemView alloc] initWithTitle:title];
        item.frame = CGRectMake(4, y, w, kItemH);
        [self.scrollView addSubview:item];
        y += kItemH;
    };

    addHeader(@"OVERLAY");
    for (NSString *t in @[@"Show Bounds", @"Show Labels", @"Show Hierarchy Lines", @"Show Dimensions"])
        addItem(t);

    y += 2; addSep();

    addHeader(@"LAYOUT");
    NSArray *sliders = @[@[@"Opacity", @0.0f, @1.0f, @0.8f],
                         @[@"Scale", @0.5f, @2.0f, @1.0f],
                         @[@"Line Width", @0.5f, @5.0f, @2.0f]];
    for (NSArray *s in sliders) {
        InspectorSliderRow *row = [[InspectorSliderRow alloc]
            initWithTitle:s[0] min:[s[1] floatValue] max:[s[2] floatValue] val:[s[3] floatValue]];
        row.frame = CGRectMake(4, y, w, 46);
        [self.scrollView addSubview:row];
        y += 46;
    }

    y += 2; addSep();

    addHeader(@"DEBUG");
    for (NSString *t in @[@"Wireframe Mode", @"Highlight Constraints", @"Log Touch Events"])
        addItem(t);

    y += 4;
    self.scrollView.contentSize = CGSizeMake(kMenuW, y);
}

- (void)handleDrag:(UIPanGestureRecognizer *)pan {
    CGPoint t = [pan translationInView:self];
    self.panel.center = CGPointMake(self.panel.center.x + t.x, self.panel.center.y + t.y);
    [pan setTranslation:CGPointZero inView:self];
}

- (void)showInView:(UIView *)parentView {
    [self removeFromSuperview];
    self.frame = parentView.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.hidden = NO;
    [parentView addSubview:self];
}

- (void)dismiss { self.hidden = YES; }

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self) ? nil : hit;
}

@end
