//
//  CGGeometry+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 11/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "CGGeometry+WDPR.h"

CGRect CGRectWithSize(CGSize size)
{
    return CGRectMake(0, 0, size.width, size.height);
}

CGRect CGRectWithOriginAndSize(CGPoint origin, CGSize size)
{
    return CGRectMake(origin.x, origin.y, 
                      size.width, size.height);
}

CGRect CGRectWithCenterAndSize(CGPoint center, CGSize size)
{
    CGPoint origin = CGPointMake(center.x - size.width / 2, 
                                 center.y - size.height / 2);
    
    return CGRectWithOriginAndSize(origin, size);
}

#pragma mark -

CGRect CGRectGrow(CGRect rect, CGFloat delta, CGRectEdge edge)
{
    switch (edge)
    {
        case CGRectMinXEdge:    
        {   rect.origin.x -= delta;
            rect.size.width += delta;
        }   break;
            
        case CGRectMinYEdge: 
        {   rect.origin.y -= delta;
            rect.size.height += delta;
        }   break;
            
        case CGRectMaxXEdge: rect.size.width += delta; break;
        case CGRectMaxYEdge: rect.size.height += delta; break;
    }
    
    return rect;
}

CGRect CGRectSetEdge(CGRect rect, CGFloat value, CGRectEdge edge)
{ 
    // only adjust the specified edge, leaving the opposite edge in same place
    switch (edge)
    {
        case CGRectMinXEdge:
        {   return CGRectOffsetAndShrink(rect, value - CGRectGetMinX(rect), 0);
        }   break;
            
        case CGRectMinYEdge:
        {   return CGRectOffsetAndShrink(rect, 0, value - CGRectGetMinY(rect));
        }   break;
            
        case CGRectMaxXEdge:
        {   return CGRectGrow(rect, value - CGRectGetWidth(rect), edge);
        }   break;
            
        case CGRectMaxYEdge:
        {   return CGRectGrow(rect, value - CGRectGetHeight(rect), edge);
        }   break;
    }
    
    return rect;
}

CGRect CGRectCenteredInRect(CGRect rect, CGRect containingRect)
{
    return CGRectMake(CGRectGetMidX(containingRect) - CGRectGetWidth(rect)/2, 
                      CGRectGetMidY(containingRect) - CGRectGetHeight(rect)/2, 
                      CGRectGetWidth(rect), 
                      CGRectGetHeight(rect));
}

CGRect CGRectOffsetAndShrink(CGRect rect, CGFloat dx, CGFloat dy)
{
    rect.size.width -= dx;
    rect.size.height -= dy;
    
    return CGRectOffset(rect, dx, dy);
}