#pragma once
#include <stdio.h>
#include <libavformat/avformat.h>

typedef struct SceneAVIOContext {
    AVIOContext* context;
    unsigned char* buffer;
    FILE* file;
    int videoStart, videoEnd;
    long videoSize, fileSize;
} SceneAVIOContext;

SceneAVIOContext* scene_aviocontext_new(const char* path, int videoLocation, int videoLength);
void scene_aviocontext_free(SceneAVIOContext* context);
