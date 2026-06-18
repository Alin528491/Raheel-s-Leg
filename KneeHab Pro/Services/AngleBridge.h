#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AngleReading : NSObject

@property(nonatomic, readonly) double flexionDegrees;
@property(nonatomic, readonly) double extensionDegrees;
@property(nonatomic, readonly) double rawFlexionDegrees;
@property(nonatomic, readonly) double totalRotationDegrees;
@property(nonatomic, readonly) double nonHingeRotationDegrees;
@property(nonatomic, readonly) BOOL isValid;
@property(nonatomic, readonly) BOOL isCalibrating;
@property(nonatomic, readonly) BOOL motionRejected;
@property(nonatomic, readonly) double calibrationRemainingSeconds;

- (instancetype)initWithFlexionDegrees:(double)flexionDegrees
                      extensionDegrees:(double)extensionDegrees
                     rawFlexionDegrees:(double)rawFlexionDegrees
                   totalRotationDegrees:(double)totalRotationDegrees
                nonHingeRotationDegrees:(double)nonHingeRotationDegrees
                                isValid:(BOOL)isValid
                          isCalibrating:(BOOL)isCalibrating
                         motionRejected:(BOOL)motionRejected
            calibrationRemainingSeconds:(double)calibrationRemainingSeconds;

@end

@interface AngleBridge : NSObject

- (void)resetCalibration;
- (void)setHingeAxisX:(double)x y:(double)y z:(double)z;

- (AngleReading *)processThighX:(double)thighX
                              thighY:(double)thighY
                              thighZ:(double)thighZ
                              thighW:(double)thighW
                               shinX:(double)shinX
                               shinY:(double)shinY
                               shinZ:(double)shinZ
                               shinW:(double)shinW
                    timestampSeconds:(double)timestampSeconds
    NS_SWIFT_NAME(process(thighX:thighY:thighZ:thighW:shinX:shinY:shinZ:shinW:timestampSeconds:));

@end

NS_ASSUME_NONNULL_END
