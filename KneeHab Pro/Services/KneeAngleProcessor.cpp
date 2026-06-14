#include "KneeAngleProcessor.hpp"

#include <algorithm>
#include <cmath>

namespace kneehab {

KneeAngleResult KneeAngleProcessor::process(const IMUFrame& frame) const {
    // Placeholder only. Replace with calibrated thigh/shin IMU fusion later.
    const double rawFlexion = std::abs(frame.shinPitchDegrees - frame.thighPitchDegrees);
    const double flexion = std::clamp(rawFlexion, 0.0, 140.0);
    const double extension = std::max(0.0, 180.0 - flexion);

    return KneeAngleResult {
        .flexionDegrees = flexion,
        .extensionDegrees = extension,
        .isValid = true
    };
}

} // namespace kneehab
