// Copyright @ MyScript. All rights reserved.

#import <Foundation/Foundation.h>

@class IINKOffscreenEditor;

/**
 * Action to perform upon offscreen gesture notification.
 *
 * @since 2.1
 */
typedef NS_ENUM(NSUInteger, IINKOffscreenGestureAction)
{
  /** Discard the gesture stroke. */
  IINKOffscreenGestureActionIgnore,
  /** Add the gesture stroke as a regular stroke. */
  IINKOffscreenGestureActionAdd,
};


/**
 * The delegate interface for handling offscreen gesture events.
 *
 * @since 2.1
 */
@protocol IINKOffscreenGestureDelegate <NSObject>

@required

//==============================================================================
#pragma mark - Required Methods
//==============================================================================

/**
 * Invoked when a portion of text has been underlined.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param itemIds the underlined portion of text.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onUnderline:(nonnull IINKOffscreenEditor*)editor
                          gestureStrokeId:(nonnull NSString*)gestureStrokeId
                                  itemIds:(nonnull NSArray<NSString*>*)itemIds;

/**
 * Invoked when a portion of text has been surrounded.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param itemIds the surrounded portion of text.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onSurround:(nonnull IINKOffscreenEditor*)editor
                         gestureStrokeId:(nonnull NSString*)gestureStrokeId
                                 itemIds:(nonnull NSArray<NSString*>*)itemIds;

/**
 * Invoked when a join gesture has been drawn between two portions of a text line,
 * or at the beginning or end of a line.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param before the portion of the text line before the join gesture.
 * @param after the portion of the text line after the join gesture.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onJoin:(nonnull IINKOffscreenEditor*)editor
                     gestureStrokeId:(nonnull NSString*)gestureStrokeId
                              before:(nonnull NSArray<NSString*>*)before
                               after:(nonnull NSArray<NSString*>*)after;

/**
 * Invoked when an insert  gesture has been drawn between two portions of a text line,
 * or at the beginning or end of a line.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param before the portion of the text line before the insert gesture.
 * @param after the portion of the text line after the insert gesture.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onInsert:(nonnull IINKOffscreenEditor*)editor
                       gestureStrokeId:(nonnull NSString*)gestureStrokeId
                                before:(nonnull NSArray<NSString*>*)before
                                 after:(nonnull NSArray<NSString*>*)after;

/**
 * Invoked when a portion of text has been striked through.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param itemIds the striked through portion of text.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onStrikethrough:(nonnull IINKOffscreenEditor*)editor
                              gestureStrokeId:(nonnull NSString*)gestureStrokeId
                                      itemIds:(nonnull NSArray<NSString*>*)itemIds;

/**
 * Invoked when a portion of text has been scratched.
 *
 * @param editor the offscreen editor.
 * @param gestureStrokeId the id of the gesture stroke.
 * @param itemIds the scratched portion of text.
 * @return the IINKOffscreenGestureAction to perform.
 */
- (IINKOffscreenGestureAction)onScratch:(nonnull IINKOffscreenEditor*)editor
                        gestureStrokeId:(nonnull NSString*)gestureStrokeId
                                itemIds:(nonnull NSArray<NSString*>*)itemIds;

@end
