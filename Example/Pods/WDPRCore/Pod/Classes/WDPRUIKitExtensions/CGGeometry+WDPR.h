//
//  CGGeometry+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 11/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

/// Utilities for manipulating CGRects, CGPoints, etc
#import <CoreGraphics/CoreGraphics.h>

CG_EXTERN CGRect CGRectWithSize(CGSize size);
CG_EXTERN CGRect CGRectWithOriginAndSize(CGPoint origin, CGSize size);
CG_EXTERN CGRect CGRectWithCenterAndSize(CGPoint center, CGSize size);

/// move any single edge of a rect by a 
/// relative amount, leaving other edges the same
CG_EXTERN CGRect CGRectGrow(CGRect rect, CGFloat delta, CGRectEdge edge);

/// set any single edge of a rect to an 
/// absolute value, leaving other edges the same
CG_EXTERN CGRect CGRectSetEdge(CGRect rect, CGFloat value, CGRectEdge edge);

CG_EXTERN CGRect CGRectCenteredInRect(CGRect rect, CGRect containingRect);
CG_EXTERN CGRect CGRectOffsetAndShrink(CGRect rect, CGFloat dx, CGFloat dy);
