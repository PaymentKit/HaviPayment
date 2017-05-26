//
//  WDPRWebViewController.h
//  WDPR
//
//  Created by Vidos, Hugh on 8/7/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

/**
 WDPRWebViewController is a base class for displaying web content in WDPR
 applications.  It supports both bundled views as well as remote sites.
 */
@interface WDPRWebViewController : WDPR_BASE_VIEW_CONTROLLER
            <UIWebViewDelegate, UIAlertViewDelegate>

/// @name Property

/// The UIWebView for this page.
@property(nonatomic, strong) UIWebView *webView;

/// Allow pinch & zoom on this page.  Disabling will display page with 100%
/// zoom also.
@property(nonatomic, assign) BOOL allowZoom;

/// Enable web navigation controls, allowing the user to go back, forward and
/// refresh the web view.
@property (nonatomic) BOOL webControlsEnabled;

/// Hide/show navigation bar
@property (nonatomic) BOOL navigationBarEnabled;

/// @name Initializers

/** Initializer with HTML file name.
 The intended use is to load a file that is shipped with the application.

 The file will be loaded from the HTML directory in the bundle.  Do not add
 ".html" to the resource path.  The page specified will be loaded, it will load
 additional resources out of the bundle if you use relative paths.

 @param resourcePath The path to a file in the HTML directory of the bundle to
 be loaded.
 @param title The title to be displayed for this page.
 @return A valid WDPRWebViewController or nil if initialization failed.
 @see initWithURL:
 */
- (id)initWithBundleResource:(NSString *)resourcePath title:(NSString *)title;

/** Initilizer with a full url.
 The intended use is to load a web page from the internet and not a local file.
 
 @param url The full path to the web page to load.
 @param title The title to be displayed for this page.
 @return A valid WDPRWebViewController or nil if initialization failed.
 @see initWithBundleResource:
 @exception NSException foo
 */
- (id)initWithURL:(NSURL *)url title:(NSString *)title;

/** Initilizer with a string.
 The intended use is to load a web page and display a simple message.
 
 @param msg A string to be displayed in a web view
 @param title The title of the controller
 @return A valid WDPRWebViewController or nil if initialization failed.
 @see initWithBundleResource:
 @exception NSException foo
 */
- (id)initWithMessage:(NSString *)msg title:(NSString*)title;

- (void)embedMessage:(NSString *)message;

@end
