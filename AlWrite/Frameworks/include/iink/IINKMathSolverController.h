// Copyright @ MyScript. All rights reserved.

#import <Foundation/Foundation.h>
#import <iink/IINKParameterSet.h>
#import <iink/IINKMimeType.h>

/**
 * The MathSolverController allows to configure and run math operations on an editor.
 *
 * @since 4.0
 */
@interface IINKMathSolverController : NSObject
{

}

//==============================================================================
#pragma mark - Methods
//==============================================================================

/**
 * Returns the available actions for the specified block.
 *
 * @note following limitation applies: the part managed by the associated
 *   editor must be a "Raw Content" and the specified block must be a
 *   "Math" block.
 *
 * @param blockId the identifier of the block.
 * @param overrideConfiguration the extra configuration used.
 * @param error the recipient for the error description object
 *   * IINKErrorInvalidArgument when `blockId` is invalid.
 *   * IINKErrorRuntime when associated part type is not "Raw Content" or block type is not "Math".
 *
 * @return an array of the available actions.
 */
- (nullable NSArray<NSString *> *)getAvailableActions:(nonnull NSString *)blockId
                                overrideConfiguration:(nullable IINKParameterSet *)overrideConfiguration
                                                error:(NSError * _Nullable * _Nullable)error
                                  NS_SWIFT_NAME(availableActions(forBlock:overrideConfiguration:));

/**
 * Executes the specified action on the specified block.
 *
 * @note following limitation applies: the part managed by the associated
 *  editor must be a "Raw Content" and the specified block must be a
 * "Math" block. The action must be available for the specified block.
 *
 * @param blockId the identifier of the block.
 * @param action the action to execute.
 * @param mimeType the MIME type that specifies the output format, either `JIIX` or `LATEX`.
 * @param overrideConfiguration the extra configuration used.
 * @param error the recipient for the error description object
 * * IINKErrorInvalidArgument when `blockId` is invalid.
 * * IINKErrorInvalidArgument when `action` is invalid.
 * * IINKErrorInvalidArgument when the specified MIME type is not supported.
 * * IINKErrorRuntime when associated part type is not "Raw Content" or block type is not "Math".
 * * IINKErrorRuntime when the action is not available for the specified block.
 * @return a string representing the output formatted with the given MIME type.
 */
- (nullable NSString *)getActionOutput:(nonnull NSString *)blockId
                                action:(nonnull NSString *)action
                              mimeType:(IINKMimeType)mimeType
                 overrideConfiguration:(nullable IINKParameterSet *)overrideConfiguration
                                 error:(NSError * _Nullable * _Nullable)error
                       NS_SWIFT_NAME(actionOutput(forBlock:action:mimeType:overrideConfiguration:));

/**
 * Applies the solved action of the specified block to the rendering.
 *
 * @note following limitation applies: incompatible with Offscreen interactivity service.
 *
 * @param blockId the identifier of the block.
 * @param action the action used by the math solver.
 * @param overrideConfiguration the extra configuration used.
 * @param error the recipient for the error description object
 *  * IINKErrorInvalidArgument when `blockId` is invalid.
 *  * IINKErrorInvalidArgument when `action` is invalid.
 *  * IINKErrorRuntime when associated part type is not "Raw Content" or block type is not "Math".
 *  * IINKErrorRuntime when the action is not available for the specified block.
 *  * IINKErrorRuntime when associated with an offscreen editor.
 */
- (BOOL)applyAction:(nonnull NSString *)blockId
             action:(nonnull NSString *)action
overrideConfiguration:(nullable IINKParameterSet *)overrideConfiguration
              error:(NSError * _Nullable * _Nullable)error
        NS_SWIFT_NAME(apply(forBlock:action:overrideConfiguration:));

@end
