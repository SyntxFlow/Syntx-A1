#include <fstream>
#include <vector>
#include <cstdint>
#include <cstring>
#include <iostream>

struct WavHeader {
    char riff[4];
    uint32_t file_size;
    char wave[4];
    char fmt[4];
    uint32_t fmt_size;
    uint16_t audio_format;
    uint16_t channels;
    uint32_t sample_rate;
    uint32_t byte_rate;
    uint16_t block_align;
    uint16_t bits_per_sample;
};

struct DataChunk {
    char data[4];
    uint32_t data_size;
};


bool read_wav_file(const char* path, std::vector<float>& audio, int& sample_rate) {
    std::ifstream file(path, std::ios::binary);
    if (!file) {
        std::cerr << "Error: Tidak bisa buka file: " << path << std::endl;
        return false;
    }

    WavHeader header;
    file.read((char*)&header, sizeof(WavHeader));

    if (std::memcmp(header.riff, "RIFF", 4) != 0 || 
        std::memcmp(header.wave, "WAVE", 4) != 0) {
        std::cerr << "Error: Bukan file WAV yang valid" << std::endl;
        return false;
    }

    if (header.audio_format != 1) {
        std::cerr << "Error: Hanya support PCM format" << std::endl;
        return false;
    }

    sample_rate = header.sample_rate;
    int channels = header.channels;

    std::cout << "WAV Info: " << sample_rate << "Hz, " 
              << channels << " channel(s), " 
              << header.bits_per_sample << " bit" << std::endl;

    DataChunk data_chunk;
    while (file.read((char*)&data_chunk, sizeof(DataChunk))) {
        if (std::memcmp(data_chunk.data, "data", 4) == 0) {
            break;
        }
        file.seekg(data_chunk.data_size, std::ios::cur);
    }

    size_t num_samples = data_chunk.data_size / sizeof(int16_t);
    std::vector<int16_t> pcm_data(num_samples);
    file.read((char*)pcm_data.data(), data_chunk.data_size);

    if (channels == 1) {
        audio.resize(num_samples);
        for (size_t i = 0; i < num_samples; i++) {
            audio[i] = pcm_data[i] / 32768.0f;
        }
    } else if (channels == 2) {
        audio.resize(num_samples / 2);
        for (size_t i = 0; i < num_samples / 2; i++) {
            audio[i] = (pcm_data[i * 2] + pcm_data[i * 2 + 1]) / 65536.0f;
        }
    }

    std::cout << "Loaded " << audio.size() << " samples" << std::endl;
    return true;
}