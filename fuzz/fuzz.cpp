//
// Created by bailey on 5/30/22.
//
#include <cstdint>
#include <cstdlib>

#include "CImg.h"

using namespace cimg_library;

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    try {
        const CImg<uint8_t> image = CImg<>(data, size).normalize(0, 255).blur(1.0).resize(-100, -100, 1, 3);
    } catch (...) {
        // ignore
    }
    return 0;
}
