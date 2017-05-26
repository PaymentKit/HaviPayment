//
//  WDPRCardCell.h
//  Pods
//
//  Created by Cesar Rodriguez on 4/08/16.
//
//

#import "WDPRUIKit.h"
#import "WDPRTableViewCell.h"


#define WDPRCardInfoTitle @"title"
#define WDPRCardInfoDetail @"detail"
#define WDPRCardFooter @"hasFooter"

typedef enum {
    
    WDPRCardTypeWithHeaderFP,
    WDPRCardTypeWithHeaderNextFP,
    WDPRCardTypeWithHeaderDine,
    WDPRCardTypeWithHeaderNextDine,
    WDPRCardTypeWithHeaderNBE,
    WDPRCardTypeWithHeaderNextNBE,
    WDPRCardTypeWithHeaderNextResort,
    WDPRCardTypeWithHeaderResort,
    WDPRCardTypeWithHeaderNote,
    WDPRCardTypeDefault
} WDPRCardType;

@protocol WDPRPullbarProtocol;

@interface WDPRCardCell : WDPRTableViewCell {
    UIView *_headerView; // declaring explicitely so WDPRDASCardCell can override the getter.
    UIView *_footerView; // Can be overwritten. Default footer is the Disclaimer View
}

// bottomInfo is an Array of dictionaries to diplay aditional info beneath the card
// Each dictionary should have the keys WDPRCardInfoTitle and WDPRCardInfoDetail
// And each object could be a NSSString or NSAttributedString
// E.g. @[ @{WDPRCardInfoTitle  : "Starts at:"
//           WDPRCardInfoDetail : "10 AM"} ]
@property (nonatomic, strong) NSArray* bottomInfo;
@property (nonatomic, assign) WDPRCardType cardType;
@property (nonatomic, strong, readonly) UIImageView* iconTypeView;
@property (nonatomic, strong, readonly) UILabel* typeLabel;
@property (nonatomic, strong) NSLayoutConstraint *topPullConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomPullConstraint;

// NO by default for all card types but WDPRCardTypeWithHeaderNBE.
@property (nonatomic) BOOL showFooter;

// This property will make the card respond to the 'pull' interaction
@property (nonatomic, getter=isPullbarEnabled) BOOL pullbarEnabled;
@property (nonatomic, weak) id<WDPRPullbarProtocol> pullbarDelegate;
@property (nonatomic, getter=isPullbarHidden) BOOL pullbarHidden;

//Making this public so that can be overridden for custom views.
@property (nonatomic, strong, readonly) UIView* footerView;
@property (nonatomic, strong) NSArray* footerViewConstraints;

- (void)showLoader;
- (void)hideLoader;

+ (CGFloat)minimumRowHeight;
+ (NSString *)reuseIdentifier;

- (void) resetPullbarConstraintsConstants;
- (void) prepareForPopAnimation;
- (void) animateIfNeeded;

// Set a custom text for the footer disclaimer.
// Set to "This is not a reservation." by default.
- (void)setFooterDisclaimerText:(NSString*)text;

- (UIImage*)imageWithSpaceFromIconID:(WDPRIconID)iconID;

@end


@protocol WDPRPullbarProtocol

@required

- (void)didBeginPullGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
                               inCard:(WDPRCardCell *)card;

- (void)didTapPullbarInCard:(WDPRCardCell*)card;

@end
