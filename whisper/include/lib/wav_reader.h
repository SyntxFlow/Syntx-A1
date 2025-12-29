#pragma once

#include <vector>

bool read_wav_file(const char* path, std::vector<float>& audio, int& sample_rate);