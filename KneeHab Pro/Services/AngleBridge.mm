#import "AngleBridge.h"

#include "AngleProcessor.hpp"

@implementation AngleReading

- (instancetype)initWithFlexionDegrees:(double)flexionDegrees
                      extensionDegrees:(double)extensionDegrees
                     rawFlexionDegrees:(double)rawFlexionDegrees
                   totalRotationDegrees:(double)totalRotationDegrees
                nonHingeRotationDegrees:(double)nonHingeRotationDegrees
                                isValid:(BOOL)isValid
                          isCalibrating:(BOOL)isCalibrating
                         motionRejected:(BOOL)motionRejected
            calibrationRemainingSeconds:(double)calibrationRemainingSeconds {
    self = [super init];
    if (self) {
        _flexionDegrees = flexionDegrees;
        _extensionDegrees = extensionDegrees;
        _rawFlexionDegrees = rawFlexionDegrees;
        _totalRotationDegrees = totalRotationDegrees;
        _nonHingeRotationDegrees = nonHingeRotationDegrees;
        _isValid = isValid;
        _isCalibrating = isCalibrating;
        _motionRejected = motionRejected;
        _calibrationRemainingSeconds = calibrationRemainingSeconds;
    }
    return self;
}

@end

@interface AngleBridge () {
    kneehab::AngleProcessor _processor;
}
@end

@implementation AngleBridge

- (void)resetCalibration {
    _processor.resetCalibration();
}

- (void)setHingeAxisX:(double)x y:(double)y z:(double)z {
    _processor.setHingeAxis({x, y, z});
}

- (AngleReading *)processThighX:(double)thighX
                              thighY:(double)thighY
                              thighZ:(double)thighZ
                              thighW:(double)thighW
                               shinX:(double)shinX
                               shinY:(double)shinY
                               shinZ:(double)shinZ
                               shinW:(double)shinW
                    timestampSeconds:(double)timestampSeconds {
    kneehab::SensorFrame frame;
    frame.hasQuaternion = true;
    frame.thighQuaternion = {thighX, thighY, thighZ, thighW};
    frame.shinQuaternion = {shinX, shinY, shinZ, shinW};

    const kneehab::AngleResult result = _processor.process(frame, timestampSeconds);
    return [[AngleReading alloc] initWithFlexionDegrees:result.flexionDegrees
                                            extensionDegrees:result.extensionDegrees
                                           rawFlexionDegrees:result.rawFlexionDegrees
                                         totalRotationDegrees:result.totalRotationDegrees
                                      nonHingeRotationDegrees:result.nonHingeRotationDegrees
                                                      isValid:result.isValid
                                                isCalibrating:result.isCalibrating
                                               motionRejected:result.motionRejected
                                  calibrationRemainingSeconds:result.calibrationRemainingSeconds];
}

@end
