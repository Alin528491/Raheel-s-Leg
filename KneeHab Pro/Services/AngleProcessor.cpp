#include "AngleProcessor.hpp"

#include <algorithm>
#include <chrono>
#include <cmath>

namespace kneehab {
namespace {

constexpr double kEpsilon = 1e-9;

double clampFinite(double value, double low, double high) {
    if (!std::isfinite(value)) {
        return low;
    }
    return std::clamp(value, low, high);
}

double norm(const Vector3& v) {
    return std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vector3 normalized(Vector3 v) {
    const double n = norm(v);
    if (n <= kEpsilon) {
        return {0.0, 0.0, 1.0};
    }
    return {v.x / n, v.y / n, v.z / n};
}

double quatNorm(const Quaternion& q) {
    return std::sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
}

bool isValidQuaternion(const Quaternion& q) {
    const double n = quatNorm(q);
    return std::isfinite(q.x) && std::isfinite(q.y) && std::isfinite(q.z) && std::isfinite(q.w)
        && n > kEpsilon;
}

Quaternion normalized(Quaternion q) {
    const double n = quatNorm(q);
    if (n <= kEpsilon) {
        return {};
    }
    return {q.x / n, q.y / n, q.z / n, q.w / n};
}

Quaternion conjugate(const Quaternion& q) {
    return {-q.x, -q.y, -q.z, q.w};
}

Quaternion inverse(const Quaternion& q) {
    return conjugate(normalized(q));
}

Quaternion multiply(const Quaternion& a, const Quaternion& b) {
    return {
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
        a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
    };
}

double dot(const Quaternion& a, const Quaternion& b) {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}

Quaternion shortestPathRelative(const Quaternion& thigh, const Quaternion& shin) {
    Quaternion adjustedShin = shin;
    if (dot(thigh, adjustedShin) < 0.0) {
        adjustedShin = {-adjustedShin.x, -adjustedShin.y, -adjustedShin.z, -adjustedShin.w};
    }
    return multiply(inverse(thigh), adjustedShin);
}

double quatAngleDegrees(const Quaternion& q) {
    const Quaternion unit = normalized(q);
    const double w = clampFinite(std::abs(unit.w), 0.0, 1.0);
    return 2.0 * std::acos(w) * 180.0 / M_PI;
}

double signedTwistAngleDegrees(const Quaternion& q, Vector3 axis) {
    const Quaternion unit = normalized(q);
    const Vector3 a = normalized(axis);
    const double projection = unit.x * a.x + unit.y * a.y + unit.z * a.z;
    const Quaternion twist = normalized({
        a.x * projection,
        a.y * projection,
        a.z * projection,
        unit.w
    });

    const double signedSin = twist.x * a.x + twist.y * a.y + twist.z * a.z;
    double angle = 2.0 * std::atan2(signedSin, twist.w) * 180.0 / M_PI;
    while (angle > 180.0) {
        angle -= 360.0;
    }
    while (angle < -180.0) {
        angle += 360.0;
    }
    return angle;
}

AngleResult makePitchFallbackResult(const SensorFrame& frame) {
    const double rawFlexion = std::abs(frame.shinPitchDegrees - frame.thighPitchDegrees);
    const double flexion = clampFinite(rawFlexion, 0.0, 140.0);
    return {
        .flexionDegrees = flexion,
        .extensionDegrees = std::max(0.0, 180.0 - flexion),
        .rawFlexionDegrees = flexion,
        .totalRotationDegrees = flexion,
        .nonHingeRotationDegrees = 0.0,
        .isValid = true,
        .isCalibrating = false,
        .motionRejected = false,
        .calibrationRemainingSeconds = 0.0
    };
}

double monotonicSeconds() {
    using Clock = std::chrono::steady_clock;
    const auto now = Clock::now().time_since_epoch();
    return std::chrono::duration<double>(now).count();
}

} // namespace

AngleProcessor::AngleProcessor() = default;

void AngleProcessor::resetCalibration() {
    hasClockStart_ = false;
    clockStartSeconds_ = 0.0;
    calibrationStarted_ = false;
    calibrationStartSeconds_ = 0.0;
    baselineReady_ = false;
    baselineRelative_ = {};
    calibrationSum_ = {};
    calibrationSamples_ = 0;
    filteredFlexion_ = 0.0;
}

void AngleProcessor::setHingeAxis(Vector3 axis) {
    hingeAxis_ = normalized(axis);
    resetCalibration();
}

AngleResult AngleProcessor::process(const SensorFrame& frame) {
    const double now = monotonicSeconds();
    if (!hasClockStart_) {
        hasClockStart_ = true;
        clockStartSeconds_ = now;
    }
    return process(frame, now - clockStartSeconds_);
}

AngleResult AngleProcessor::process(const SensorFrame& frame, double timestampSeconds) {
    if (!frame.hasQuaternion
        || !isValidQuaternion(frame.thighQuaternion)
        || !isValidQuaternion(frame.shinQuaternion)) {
        return makePitchFallbackResult(frame);
    }

    const Quaternion thigh = normalized(frame.thighQuaternion);
    const Quaternion shin = normalized(frame.shinQuaternion);
    const Quaternion relative = normalized(shortestPathRelative(thigh, shin));

    if (!calibrationStarted_) {
        calibrationStarted_ = true;
        calibrationStartSeconds_ = timestampSeconds;
        baselineReady_ = false;
        calibrationSum_ = {};
        calibrationSamples_ = 0;
        filteredFlexion_ = 0.0;
    }

    if (!baselineReady_) {
        Quaternion sample = relative;
        if (calibrationSamples_ > 0 && dot(calibrationSum_, sample) < 0.0) {
            sample = {-sample.x, -sample.y, -sample.z, -sample.w};
        }
        calibrationSum_.x += sample.x;
        calibrationSum_.y += sample.y;
        calibrationSum_.z += sample.z;
        calibrationSum_.w += sample.w;
        calibrationSamples_ += 1;

        const double elapsed = std::max(0.0, timestampSeconds - calibrationStartSeconds_);
        const double remaining = std::max(0.0, autoZeroSeconds_ - elapsed);
        if (elapsed < autoZeroSeconds_) {
            return {
                .flexionDegrees = 0.0,
                .extensionDegrees = 180.0,
                .rawFlexionDegrees = 0.0,
                .totalRotationDegrees = 0.0,
                .nonHingeRotationDegrees = 0.0,
                .isValid = false,
                .isCalibrating = true,
                .motionRejected = false,
                .calibrationRemainingSeconds = remaining
            };
        }

        baselineRelative_ = normalized(calibrationSum_);
        baselineReady_ = true;
        filteredFlexion_ = 0.0;
    }

    const Quaternion delta = normalized(multiply(inverse(baselineRelative_), relative));
    const double rawHinge = std::abs(signedTwistAngleDegrees(delta, hingeAxis_));
    const double total = quatAngleDegrees(delta);
    const double nonHinge = std::sqrt(std::max(0.0, total * total - rawHinge * rawHinge));
    const double hingeRatio = rawHinge / (total + 1e-6);

    const bool motionRejected = nonHinge >= nonHingeRejectDegrees_
        && hingeRatio < hingeDominanceMin_
        && filteredFlexion_ <= 12.0;

    double target = motionRejected ? filteredFlexion_ * 0.85 : rawHinge;
    if (target < deadbandDegrees_) {
        target = 0.0;
    }

    filteredFlexion_ += filterAlpha_ * (target - filteredFlexion_);
    if (filteredFlexion_ < deadbandDegrees_) {
        filteredFlexion_ = 0.0;
    }

    const double flexion = clampFinite(filteredFlexion_, 0.0, 140.0);
    return {
        .flexionDegrees = flexion,
        .extensionDegrees = std::max(0.0, 180.0 - flexion),
        .rawFlexionDegrees = rawHinge,
        .totalRotationDegrees = total,
        .nonHingeRotationDegrees = nonHinge,
        .isValid = true,
        .isCalibrating = false,
        .motionRejected = motionRejected,
        .calibrationRemainingSeconds = 0.0
    };
}

} // namespace kneehab
