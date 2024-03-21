#include "videoDecoder.h"

enum AVPixelFormat getHardwareDecoderFormat(AVCodecContext* context, const enum AVPixelFormat* formats) {
    VideoDecoder* decoder = (VideoDecoder*)context->opaque;

    for (const enum AVPixelFormat* p = formats; *p != -1; p++) {
        if (*p == decoder->hardwarePixelFormat)
            return *p;
    }
 
    perror("Failed to get HW surface format\n");
    return AV_PIX_FMT_NONE;
}

VideoDecoder* video_decoder_new(const char* path, int enableHardwareDecoding) {
    VideoDecoder* decoder = (VideoDecoder*)calloc(1, sizeof(VideoDecoder));
    decoder->hardwarePixelFormat = AV_PIX_FMT_NONE;
    decoder->enableHardwareDecoding = enableHardwareDecoding;
    const AVCodec* codec;

    // Create AVFormatContext and get video stream index
    if (decoder->enableHardwareDecoding) {
        decoder->hardwareDecoderType = av_hwdevice_find_type_by_name("videotoolbox");

        if (decoder->hardwareDecoderType == AV_HWDEVICE_TYPE_NONE) {
            printf("Hardware decoding is not supported.\n");
            decoder->enableHardwareDecoding = 0;
        }
    }

    decoder->formatContext = avformat_alloc_context();

    if (!decoder->formatContext) {
        perror("Could not create format context\n");
        return 0;
    }

    if (avformat_open_input(&decoder->formatContext, path, NULL, NULL) != 0) {
        perror("Could not open file\n");
        video_decoder_free(decoder);
        return 0;
    }

    if (avformat_find_stream_info(decoder->formatContext, NULL) < 0) {
        perror("Could not find stream info\n");
        video_decoder_free(decoder);
        return 0;
    }

    decoder->videoStreamIndex = av_find_best_stream(decoder->formatContext, AVMEDIA_TYPE_VIDEO, -1, -1, &codec, 0);

    if (decoder->videoStreamIndex < 0) {
        perror("Could not find a video stream\n");
        video_decoder_free(decoder);
        return 0;
    }

    if (decoder->enableHardwareDecoding) {
        for (int i = 0;; i++) {
            const AVCodecHWConfig* config = avcodec_get_hw_config(codec, i);

            if (!config) {
                // std::cerr << "Decoder " << codec->name << " does not support device type " << av_hwdevice_get_type_name(hardwareDecoderType) << '\n';
                video_decoder_free(decoder);
                return 0;
            }

            if (config->methods & AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX && config->device_type == decoder->hardwareDecoderType) {
                decoder->hardwarePixelFormat = config->pix_fmt;
                break;
            }
        }
    }

    // Codec context

    decoder->codecContext = avcodec_alloc_context3(codec);

    if (!decoder->codecContext) {
        perror("Could not allocate context\n");
        video_decoder_free(decoder);
        return 0;
    }

    AVStream* video = decoder->formatContext->streams[decoder->videoStreamIndex];

    if (avcodec_parameters_to_context(decoder->codecContext, video->codecpar) < 0) {
        perror("Couldn't initialize AVCodecContext\n");
        video_decoder_free(decoder);
        return 0;
    }

    if (decoder->enableHardwareDecoding) {
        decoder->codecContext->get_format = getHardwareDecoderFormat;
        decoder->codecContext->opaque = decoder;

        // Init hardware decoder
        if (av_hwdevice_ctx_create(&decoder->hardwareDecoderContext, decoder->hardwareDecoderType, NULL, NULL, 0) < 0) {
            perror("Failed to create hardware decoder context\n");
            video_decoder_free(decoder);
            return 0;
        }

        decoder->codecContext->hw_device_ctx = av_buffer_ref(decoder->hardwareDecoderContext);
    }

    if (avcodec_open2(decoder->codecContext, codec, NULL) < 0) {
        perror("Could not open codec\n");
        video_decoder_free(decoder);
        return 0;
    }

    decoder->width = decoder->codecContext->width;
    decoder->height = decoder->codecContext->height;

    // Frame

    decoder->frame = av_frame_alloc();

    if (!decoder->frame) {
        perror("Could not allocate video frame\n");
        video_decoder_free(decoder);
        return 0;
    }

    // Packet

    decoder->packet = av_packet_alloc();

    if (!decoder->packet) {
        perror("Could not allocate packet\n");
        return 0;
    }

    return decoder;
}

AVFrame* video_decoder_decode_next_frame(VideoDecoder* decoder) {
    av_packet_unref(decoder->packet);

    if (av_read_frame(decoder->formatContext, decoder->packet) < 0) {
        av_seek_frame(decoder->formatContext, decoder->videoStreamIndex, 0, AVSEEK_FLAG_BACKWARD);
        av_packet_unref(decoder->packet);
        video_decoder_decode_next_frame(decoder);
        return NULL;
    }

    if (decoder->packet->stream_index != decoder->videoStreamIndex) {
        av_packet_unref(decoder->packet);
        video_decoder_decode_next_frame(decoder);
        return NULL;
    }

    if (!decoder->packet->size) {
        av_packet_unref(decoder->packet);
        return NULL;
    }

    int ret = avcodec_send_packet(decoder->codecContext, decoder->packet);

    if (ret < 0) {
        perror("Error sending a packet for decoding\n");
        return NULL;
    }

    ret = avcodec_receive_frame(decoder->codecContext, decoder->frame);

    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
        av_packet_unref(decoder->packet);
        return NULL;
    }
    else if (ret < 0) {
        perror("Error during decoding\n");
        return NULL;
    }

    return decoder->frame;
}

void video_decoder_free(VideoDecoder* decoder) {
    if (decoder->codecContext) {
        avcodec_free_context(&decoder->codecContext);
    }

    if (decoder->frame) {
        av_frame_free(&decoder->frame);
    }

    if (decoder->packet) {
        av_packet_free(&decoder->packet);
    }

    if (decoder->formatContext) {
        avformat_close_input(&decoder->formatContext);
    }

    free(decoder);
}
