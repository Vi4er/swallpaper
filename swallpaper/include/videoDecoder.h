#pragma once

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libswscale/swscale.h>

typedef struct VideoDecoder {
    int width, height;
    int videoStreamIndex;
    AVFormatContext* formatContext;
    AVCodecContext* codecContext;
    AVFrame* frame;
    AVPacket* packet;

    // Hardware decoding

    int enableHardwareDecoding;
    enum AVPixelFormat hardwarePixelFormat;
    enum AVHWDeviceType hardwareDecoderType;
    AVBufferRef* hardwareDecoderContext;
} VideoDecoder;

VideoDecoder* video_decoder_new(const char* path, int hardwareDecoding);
AVFrame* video_decoder_decode_next_frame(VideoDecoder* decoder);
void video_decoder_free(VideoDecoder* decoder);
