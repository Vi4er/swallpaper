#pragma once
#import <elements/SWElement.h>

@interface SWTextLayer : CATextLayer

- (CGSize)getTextSize;

@end

@interface SWTextElement : SWElement

@property SWTextLayer* layer;
- (void)sizeToFit;

@end
