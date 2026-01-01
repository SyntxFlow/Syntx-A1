#include "whisper/whisper.h"
#include "lib/wav_reader.h"
#include "libsamplerate/samplerate.h"

#include <fstream>
#include <vector>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <thread>

class WhisperTranscriber {
private:
    whisper_context* ctx;
    whisper_full_params params;
    whisper_context_params ctx_params;
    
public:
    WhisperTranscriber() : ctx(nullptr) {}
    
    ~WhisperTranscriber() {
        if (ctx) {
            whisper_free(ctx);
            whisper_free_context_params(&ctx_params);
        }
    }
    
    bool load_model(const char* model_path) {
        std::cout << "Loading model:  " << model_path << std::endl;
        ctx_params = whisper_context_default_params();
        ctx = whisper_init_from_file_with_params(model_path, ctx_params);
        
        if (!ctx) {
            std::cerr << "Error: Gagal load model!" << std::endl;
            return false;
        }
        
        std::cout << "Model loaded successfully!" << std::endl;
        return true;
    }
    
    void setup_params(bool translate_to_english = false, int num_threads = 4) {
        params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
        
        params.n_threads = num_threads;
        params.translate = false;
        params.language = "id";
        params.print_progress = true;
        params.print_timestamps = true;
        
        params.no_context = true;
        
        std::cout << "Parameters configured" << std::endl;
    }
    
    std::string transcribe(const std::vector<float>& audio) {
        if (!ctx) {
            std::cerr << "Error: Model belum di-load!" << std::endl;
            return "";
        }
        
        std::cout << "\n=== Starting transcription ===" << std::endl;
        
        if (whisper_full(ctx, params, audio.data(), audio.size()) != 0) {
            std::cerr << "Error: Gagal transcribe!" << std::endl;
            return "";
        }
        
        std::string result;
        const int n_segments = whisper_full_n_segments(ctx);
        
        std::cout << "\n=== Transcription Result ===" << std::endl;
        
        for (int i = 0; i < n_segments; i++) {
            const char* text = whisper_full_get_segment_text(ctx, i);
            
            const int64_t t0 = whisper_full_get_segment_t0(ctx, i);
            const int64_t t1 = whisper_full_get_segment_t1(ctx, i);
            
            printf("[%d:%d.%d --> %d:%d.%d] %s\n",
                   (int)(t0 / 100) / 60,
                   (int)(t0 / 100) % 60,
                   (int)(t0 % 100) * 10,
                   (int)(t1 / 100) / 60,
                   (int)(t1 / 100) % 60,
                   (int)(t1 % 100) * 10,
                   text);
            
            result += text;
            result += " ";
        }
        
        return result;
    }
    
    void transcribe_streaming(const std::vector<float>& audio, const int sample_rate) {
        if (sample_rate != WHISPER_SAMPLE_RATE) {
            std::cout << "Warning: Whisper butuh 16kHz, tapi file " 
                      << sample_rate << "Hz. Hasil mungkin kurang akurat." << std::endl;
        }
        
        const size_t chunk_size = WHISPER_SAMPLE_RATE * 10;
        
        for (size_t offset = 0; offset < audio.size(); offset += chunk_size) {
            size_t size = std::min(chunk_size, audio.size() - offset);
            std::vector<float> chunk(audio.begin() + offset, 
                                    audio.begin() + offset + size);
            
            std::cout << "\n--- Processing chunk " << (offset / chunk_size + 1) 
                      << " (" << size / WHISPER_SAMPLE_RATE << " seconds) ---" << std::endl;
            
            transcribe(chunk);
        }
    }
};

std::vector<float> resampleTo16k(
    const std::vector<double>& input,
    int inputRate
) {
    double ratio = 16000.0 / inputRate;

    std::vector<float> inputFloat(input.size());
    for (size_t i = 0; i < input.size(); i++) {
        inputFloat[i] = static_cast<float>(input[i]);
    }

    int outputFrames = static_cast<int>(input.size() * ratio);
    std::vector<float> output(outputFrames);

    SRC_DATA data;
    data.data_in = inputFloat.data();
    data.input_frames = inputFloat.size();
    data.data_out = output.data();
    data.output_frames = outputFrames;
    data.src_ratio = ratio;
    data.end_of_input = 0;

    int err = src_simple(&data, SRC_SINC_FASTEST, 1);
    if (err) {
        throw std::runtime_error(src_strerror(err));
    }

    output.resize(data.output_frames_gen);
    return output;
}

extern "C" {
    __attribute__((visibility("default"))) __attribute__((used))
    int tambah(int a, int b) {
        return a + b;
    }

    __attribute__((visibility("default"))) __attribute__((used))
    const char* get_version() {
        return "Syntx A1 v1.0";
    }
}

// int main(int argc, char** argv) {
//     if (argc < 3) {
//         std::cout << "Usage: " << argv[0] << " <model_path> <audio_file.wav>" << std::endl;
//         return 1;
//     }
    
//     const char* model_path = argv[1];
//     const char* audio_path = argv[2];
    
//     WhisperTranscriber transcriber;
    
//     if (!transcriber.load_model(model_path)) {
//         return 1;
//     }
    
//     int num_threads = std::thread::hardware_concurrency();
//     transcriber.setup_params(false, num_threads);
    
//     std::vector<float> audio;
//     int sample_rate;
    
//     if (!read_wav_file(audio_path, audio, sample_rate)) {
//         return 1;
//     }
    
//     std::string result = transcriber.transcribe(audio);
    
//     std::ofstream out("transcription.txt");
//     out << result;
//     out.close();
    
//     std::cout << "\n=== DONE ===" << std::endl;
//     std::cout << "Full transcription saved to: transcription.txt" << std::endl;
    
//     return 0;
// }

/*

syntx.exe models/ggml-base.bin audio.wav

ffmpeg -i input.mp3 -ar 16000 -ac 1 output.wav
ffmpeg -i input.m4a -ar 16000 -ac 1 output.wav

*/