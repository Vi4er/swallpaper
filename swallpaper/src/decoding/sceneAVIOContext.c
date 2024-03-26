#include <decoding/sceneAVIOContext.h>

static const int bufferSize = 4096;

static int scene_aviocontext_read(void* opaque, unsigned char* buf, int buf_size) {
    SceneAVIOContext* ctx = (SceneAVIOContext*)opaque;
    buf_size = (int)FFMIN(buf_size, ctx->videoEnd - ftell(ctx->file));

    if (!buf_size) {
        return AVERROR_EOF;
    }
    
    fread((char*)buf, buf_size, 1, ctx->file);

    return buf_size;
}

static int64_t scene_aviocontext_seek(void* opaque, int64_t offset, int whence) {
    SceneAVIOContext* ctx = (SceneAVIOContext*)opaque;

    switch(whence)
    {
        case AVSEEK_SIZE: {
            return ctx->videoSize;
        }
        case SEEK_SET:
            if (offset < ctx->videoSize) {
                offset += ctx->videoStart;
                break;
            }
            else {
                return EOF;
            }
        case SEEK_CUR: {
            if (offset >= ctx->videoEnd - ftell(ctx->file))
            {
                return EOF;
            }
            break;
        }
        case SEEK_END: {
            if (offset < ctx->videoSize) {
                offset += (ctx->fileSize - ctx->videoEnd);
                break;
            }
            else {
                return EOF;
            }
        }
        default:
            break;
    }

    fseek(ctx->file, offset, whence);
    return ftell(ctx->file) - ctx->videoStart;
}


SceneAVIOContext* scene_aviocontext_new(const char* path, int videoLocation, int videoLength) {
    SceneAVIOContext* context = malloc(sizeof(SceneAVIOContext));
    context->buffer = av_malloc(bufferSize);
    context->context = avio_alloc_context(context->buffer, bufferSize, 0, context, &scene_aviocontext_read, NULL, &scene_aviocontext_seek);
    context->file = fopen(path, "rb");
    context->videoStart = videoLocation;
    context->videoEnd = videoLocation + videoLength;
    context->videoSize = videoLength;
    
    fseek(context->file, 0, SEEK_END);
    context->fileSize = ftell(context->file);
    fseek(context->file, videoLocation, SEEK_SET);
    
    return context;
}

void scene_aviocontext_free(SceneAVIOContext* context) {
    av_free(context->buffer);
    avio_context_free(&context->context);
    fclose(context->file);
}
