#pragma once

namespace kneehab {

struct Vector3 {
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;
};

struct Quaternion {
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;
    double w = 1.0;
};

struct SensorFrame {
    double thighPitchDegrees = 0.0;
    double shinPitchDegrees = 0.0;
    Quaternion thighQuaternion {};
    Quaternion shinQuaternion {};
    bool hasQuaternion = false;
};

struct AngleResult {
    double flexionDegrees = 0.0;
    double extensionDegrees = 180.0;
    double rawFlexionDegrees = 0.0;
    double totalRotationDegrees = 0.0;
    double nonHingeRotationDegrees = 0.0;
    bool isValid = false;
    bool isCalibrating = false;
    bool motionRejected = false;
    double calibrationRemainingSeconds = 0.0;
};

class AngleProcessor {
public:
    AngleProcessor();

    void resetCalibration();
    void setHingeAxis(Vector3 axis);

    AngleResult process(const SensorFrame& frame);
    AngleResult process(const SensorFrame& frame, double timestampSeconds);

private:
    Vector3 hingeAxis_ {0.0, 0.0, 1.0};
    double autoZeroSeconds_ = 3.0;
    double filterAlpha_ = 0.22;
    double deadbandDegrees_ = 2.0;
    double nonHingeRejectDegrees_ = 6.0;
    double hingeDominanceMin_ = 0.45;

    bool hasClockStart_ = false;
    double clockStartSeconds_ = 0.0;
    bool calibrationStarted_ = false;
    double calibrationStartSeconds_ = 0.0;
    bool baselineReady_ = false;
    Quaternion baselineRelative_ {};
    Quaternion calibrationSum_ {};
    int calibrationSamples_ = 0;
    double filteredFlexion_ = 0.0;
};

} // namespace kneehab
