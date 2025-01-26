// Copyright @ MyScript. All rights reserved.

#import <Foundation/Foundation.h>
#import <iink/IINKIContentSelection.h>


@class IINKContentSelection;


/**
 * Represents a selection.
 *
 * @since 2.0
 */
@interface IINKContentSelection : NSObject <IINKIContentSelection>
{

}

/**
 * The box that represents the position of this selection (document coordinates in mm).
 */
@property (nonatomic, readonly) CGRect box __attribute__((deprecated ("Since 3.2, use {@link IINKEditor#getBox} instead")));

/**
 * The current conversion state of this selection as a bitwise or combination
 * IINKConversionState values.
 */
@property (nonatomic, readonly) IINKConversionState conversionState __attribute__((deprecated ("Since 3.2, use {@link IINKEditor#getConversionState} instead")));

@end
