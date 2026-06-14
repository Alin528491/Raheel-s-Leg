#pragma once

namespace kneehab {

struct IMUFrame {
    double thighPitchDegrees;
    double shinPitchDegrees;
};

struct KneeAngleResult {
    double flexionDegrees;
    double extensionDegrees;
    bool isValid;
};

class KneeAngleProcessor {
public:
    KneeAngleResult process(const IMUFrame& frame) const;
};

} // namespace kneehab
