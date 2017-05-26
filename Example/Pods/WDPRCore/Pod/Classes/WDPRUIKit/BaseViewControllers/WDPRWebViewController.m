//
//  WDPRWebViewController.m
//  WDPR
//
//  Created by Vidos, Hugh on 8/7/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <WDPRCore/WDPRUIKit.h>

static NSString *resourceDirectory = @"html";

@interface WDPRWebViewController ()

@property(nonatomic, strong) NSURL *url;
@property (nonatomic) NSString* msg;

//Navigation Controls:
@property (nonatomic,strong) UIBarButtonItem *refreshButton;
@property (nonatomic,strong) UIBarButtonItem *goBackButton;
@property (nonatomic,strong) UIBarButtonItem *goForwardButton;

@end

@implementation WDPRWebViewController

- (id)initWithBundleResource:(NSString *)resourcePath 
                       title:(NSString *)title 
{
    self = [super init];
    if (self) 
    {
        [self commonInit];
        [self setTitle:title];
        _url = [NSURL URLWithString:resourcePath];
        
        if (!_url || ![_url scheme]) 
        {
            NSString *path =
            [[NSBundle mainBundle] 
             pathForResource:resourcePath
             ofType:@"html" inDirectory:resourceDirectory];
            
            _url = [NSURL fileURLWithPath:path isDirectory:NO];
        }
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
            title:(NSString *)title
{
     self = [super init];
    if (self) 
    {
        self->_url = url;
        UIBarButtonItem *launch = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                 target:self
                                 action:@selector(didPressLaunch)];
        self.navigationItem.rightBarButtonItem = launch;
        [self setTitle:title];
        [self commonInit];
    }
    return self;
}

- (id)initWithMessage:(NSString *)msg
                title:(NSString*)title
{
    self = [super init];
    if (self) 
    {
        self.title= title;
        [self commonInit];
        self.msg= msg;
    }
    return self;
}

-(void)commonInit
{
    _webControlsEnabled = NO;
    _navigationBarEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRuleUnderHeader];
    CGRect frame = self.view.frame;
    // TODO: Hugh, utilize base class's setting of contentInset.
    frame.origin.y = 0;
    frame.size.height = frame.size.height - frame.origin.y;
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    self.webView.scalesPageToFit = self.allowZoom;
    self.webView.contentMode = UIViewContentModeScaleAspectFill;
    self.webView.autoresizingMask =
        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.delegate = self;
    
    if (self.url)
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
    else if (self.msg)
    {
        // display a message (which will be embedded within html code)
        [self embedMessage:self.msg];
    }
    [self.view addSubview:self.webView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.webControlsEnabled)
    {
        [self showWebControls];
    }

    if (!_navigationBarEnabled)
    {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)embedMessage:(NSString *)message
{
    NSError* error;
    NSString *path =
        [[NSBundle mainBundle] pathForResource:@"info_placeholder_msg"
                                        ofType:@"html"
                                   inDirectory:resourceDirectory];
    NSString *contents =
        [NSString stringWithContentsOfFile:path
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
    NSString* html= [NSString stringWithFormat:contents, message];
    
    NSURL* baseURL=
        [NSURL fileURLWithPath:[NSBundle.mainBundle.resourcePath
                                stringByAppendingPathComponent:@"html"]];
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (void)didPressLaunch {
    [UIAlertView showNavigateToSafariAlertWithURL:self.url];
}

- (void)dealloc
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)inRequest
            navigationType:(UIWebViewNavigationType)type
{
    
    switch (type)
    {
        case UIWebViewNavigationTypeLinkClicked:
        {
            NSURL *link = inRequest.URL;
            
            if ([link.scheme isEqualToString:@"https"])
            {
                NSURL *url = [NSURL URLWithString:[[inRequest URL] absoluteString]];
                if (!self.webControlsEnabled)
                {
                    [UIAlertView showNavigateToSafariAlertWithURL:url];
                }
                else
                {
                    return YES;
                }
            }
            else if ([link.scheme isEqualToString:@"http"])
            {
                return YES;
            }
            return NO;
        }
            break;
            
        default:
            
            return YES;
            break;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self displayActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self dismissActivityIndicator];
    
    // width on html is device-width, thus causing the content size of the
    // webview's scrollview go beyond the bounds of the container view.  We
    // change the width of the page to the width of the container view by
    // injecting some javascript and changing the right properties for
    // modal webViews on iPad only
    if (IS_IPAD && [self isModal]) {
        NSString *format = @"var metas = document.getElementsByTagName('meta');"
        "for (var i=0; i<metas.length;i++) {if (metas[i].getAttribute('name') "
        "&& metas[i].getAttribute('name')=='viewport') {metas[i].setAttribute("
        "'content','width=%@, initial-scale=1, maximum-scale=1');}}";
        NSNumber *width = [NSNumber numberWithFloat:self.view.frame.size.width];
        NSString *js = [NSString stringWithFormat:format,[width stringValue]];
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    if (self.webControlsEnabled)
    {
        self.goBackButton.enabled = self.webView.canGoBack;
        self.goForwardButton.enabled = self.webView.canGoForward;
    }
    
}


#pragma mark Bottom Web Navigation Bar

-(UIBarButtonItem*)refreshButton
{
    if (!_refreshButton)
    {
        MAKE_WEAK(self);
        _refreshButton = [UIBarButtonItem refreshButtonItem:^(void){[weakself.webView reload];}];
    }
    return _refreshButton;
}

-(UIBarButtonItem*)goBackButton
{
    if (!_goBackButton)
    {
        MAKE_WEAK(self);
        _goBackButton = [UIBarButtonItem backButtonItem:^(void){[weakself.webView goBack];}];
    }
    return _goBackButton;
    
}

-(UIBarButtonItem*)goForwardButton
{
    if (!_goForwardButton)
    {
        MAKE_WEAK(self);
        _goForwardButton = [UIBarButtonItem forwardButtonItem:^(void){[weakself.webView goForward];}];
    }
    return _goForwardButton;
}

-(void)showWebControls
{
    [self setToolbarItems:@[
                            [self goBackButton],
                            [self goForwardButton],
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                            [self refreshButton]
                            ]];
    self.goBackButton.enabled = self.webView.canGoBack;
    self.goForwardButton.enabled = self.webView.canGoForward;
    [self.navigationController setToolbarHidden:NO];
    _webControlsEnabled = YES;
}

-(void)hideWebControls
{
    [self.navigationController setToolbarHidden:YES];
    _webControlsEnabled = NO;
}

@end
