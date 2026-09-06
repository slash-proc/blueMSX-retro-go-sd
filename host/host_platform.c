/*
 * Thin SDL2 / SDL3 frontend for the host build.
 * Select with -DHOST_SDL=2 (default) or -DHOST_SDL=3.
 */

#include "host_platform.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef HOST_SDL
#define HOST_SDL 2
#endif

#if HOST_SDL == 3
#include <SDL3/SDL.h>
#else
#include <SDL.h>
#endif

#include "odroid_input.h"

static SDL_Window *window;
static SDL_Renderer *renderer;
static SDL_Texture *texture;
#if HOST_SDL == 3
static SDL_AudioStream *audio_stream;
static SDL_AudioDeviceID audio_dev;
#else
static SDL_AudioDeviceID audio_dev;
#endif
static int win_w, win_h;
static int fb_w, fb_h;
static int audio_half;
static int sample_rate;       /* app / emu rate (e.g. 18000) */
static int device_rate;       /* SDL device rate after open */
static int device_channels;
#if HOST_SDL == 2
static SDL_AudioStream *audio_cvt; /* emu rate → device rate */
static uint8_t audio_scratch[64 * 1024];
#endif

int host_platform_init(const char *title, int scale)
{
    if (scale < 1)
        scale = 2;
    fb_w = 320;
    fb_h = 240;
    win_w = fb_w * scale;
    win_h = fb_h * scale;

#if HOST_SDL == 3
    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS)) {
        fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
        return -1;
    }
    window = SDL_CreateWindow(title ? title : "Retro-Go Host", win_w, win_h, 0);
    if (!window) {
        fprintf(stderr, "SDL_CreateWindow: %s\n", SDL_GetError());
        return -1;
    }
    renderer = SDL_CreateRenderer(window, NULL);
    if (!renderer) {
        fprintf(stderr, "SDL_CreateRenderer: %s\n", SDL_GetError());
        return -1;
    }
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB565,
                                SDL_TEXTUREACCESS_STREAMING, fb_w, fb_h);
#else
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS) != 0) {
        fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
        return -1;
    }
    window = SDL_CreateWindow(title ? title : "Retro-Go Host",
                              SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                              win_w, win_h, 0);
    if (!window) {
        fprintf(stderr, "SDL_CreateWindow: %s\n", SDL_GetError());
        return -1;
    }
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        renderer = SDL_CreateRenderer(window, -1, 0);
    }
    if (!renderer) {
        fprintf(stderr, "SDL_CreateRenderer: %s\n", SDL_GetError());
        return -1;
    }
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB565,
                                SDL_TEXTUREACCESS_STREAMING, fb_w, fb_h);
#endif
    if (!texture) {
        fprintf(stderr, "SDL_CreateTexture: %s\n", SDL_GetError());
        return -1;
    }
#if HOST_SDL != 3
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");
#endif
    return 0;
}

void host_platform_shutdown(void)
{
    host_platform_audio_stop();
    if (texture)
        SDL_DestroyTexture(texture);
    if (renderer)
        SDL_DestroyRenderer(renderer);
    if (window)
        SDL_DestroyWindow(window);
    texture = NULL;
    renderer = NULL;
    window = NULL;
    SDL_Quit();
}

static void set_key(host_pad_t *pad, int key, int down)
{
    if (key >= 0 && key < (int)(sizeof(pad->values) / sizeof(pad->values[0])))
        pad->values[key] = down ? 1 : 0;
}

#if HOST_SDL == 3
static int map_scancode(SDL_Scancode sc)
#else
static int map_scancode(SDL_Scancode sc)
#endif
{
    switch (sc) {
    case SDL_SCANCODE_UP: return ODROID_INPUT_UP;
    case SDL_SCANCODE_DOWN: return ODROID_INPUT_DOWN;
    case SDL_SCANCODE_LEFT: return ODROID_INPUT_LEFT;
    case SDL_SCANCODE_RIGHT: return ODROID_INPUT_RIGHT;
    case SDL_SCANCODE_Z: return ODROID_INPUT_B;
    case SDL_SCANCODE_X: return ODROID_INPUT_A;
    case SDL_SCANCODE_RETURN: return ODROID_INPUT_START;
    case SDL_SCANCODE_RSHIFT:
    case SDL_SCANCODE_LSHIFT: return ODROID_INPUT_SELECT;
    case SDL_SCANCODE_A: return ODROID_INPUT_Y; /* SELECT on G&W cores */
    case SDL_SCANCODE_S: return ODROID_INPUT_X; /* START on G&W cores */
    default: return -1;
    }
}

int host_platform_poll(host_pad_t *pad)
{
    SDL_Event ev;

    if (pad) {
        pad->want_save = 0;
        pad->want_load = 0;
    }

    while (SDL_PollEvent(&ev)) {
#if HOST_SDL == 3
        if (ev.type == SDL_EVENT_QUIT)
            return 0;
        if (ev.type == SDL_EVENT_KEY_DOWN || ev.type == SDL_EVENT_KEY_UP) {
            int down = (ev.type == SDL_EVENT_KEY_DOWN);
            SDL_Scancode sc = ev.key.scancode;
            if (sc == SDL_SCANCODE_ESCAPE)
                return 0;
            if (down && pad) {
                if (sc == SDL_SCANCODE_F1)
                    pad->want_save = 1;
                else if (sc == SDL_SCANCODE_F2)
                    pad->want_load = 1;
            }
            int mapped = map_scancode(sc);
            if (mapped >= 0 && pad)
                set_key(pad, mapped, down);
        }
#else
        if (ev.type == SDL_QUIT)
            return 0;
        if (ev.type == SDL_KEYDOWN || ev.type == SDL_KEYUP) {
            int down = (ev.type == SDL_KEYDOWN);
            SDL_Scancode sc = ev.key.keysym.scancode;
            if (sc == SDL_SCANCODE_ESCAPE)
                return 0;
            if (down && pad) {
                if (sc == SDL_SCANCODE_F1)
                    pad->want_save = 1;
                else if (sc == SDL_SCANCODE_F2)
                    pad->want_load = 1;
            }
            int mapped = map_scancode(sc);
            if (mapped >= 0 && pad)
                set_key(pad, mapped, down);
        }
#endif
    }
    return 1;
}

void host_platform_present_rgb565(const uint16_t *fb, int width, int height)
{
    void *pixels;
    int pitch;

    if (!texture || !renderer || !fb)
        return;

#if HOST_SDL == 3
    if (SDL_LockTexture(texture, NULL, &pixels, &pitch) == 0) {
#else
    if (SDL_LockTexture(texture, NULL, &pixels, &pitch) == 0) {
#endif
        int y;
        uint8_t *dst = (uint8_t *)pixels;
        for (y = 0; y < height; y++) {
            memcpy(dst + y * pitch, fb + y * width, (size_t)width * 2);
        }
        SDL_UnlockTexture(texture);
    }

#if HOST_SDL == 3
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderTexture(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
#else
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
#endif
}

void host_platform_delay_ms(uint32_t ms)
{
#if HOST_SDL == 3
    SDL_Delay(ms);
#else
    SDL_Delay(ms);
#endif
}

uint32_t host_platform_ticks_ms(void)
{
#if HOST_SDL == 3
    return (uint32_t)SDL_GetTicks();
#else
    return (uint32_t)SDL_GetTicks();
#endif
}

int host_platform_audio_start(int rate, int half_len)
{
    const int device_samples = 4096;
    int16_t *silence;
    int prefill;

    sample_rate = rate > 0 ? rate : 16000;
    audio_half = half_len > 0 ? half_len : (sample_rate / 60);
    device_rate = sample_rate;
    device_channels = 1;

    if (audio_dev
#if HOST_SDL == 3
        || audio_stream
#endif
#if HOST_SDL == 2
        || audio_cvt
#endif
        )
        host_platform_audio_stop();

#if HOST_SDL == 3
    /* SDL3 stream accepts our emu format and resamples to the device. */
    SDL_AudioSpec spec;
    SDL_zero(spec);
    spec.freq = sample_rate;
    spec.format = SDL_AUDIO_S16;
    spec.channels = 1;
    audio_stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,
                                             &spec, NULL, NULL);
    if (!audio_stream) {
        fprintf(stderr, "SDL audio: %s\n", SDL_GetError());
        return -1;
    }
    audio_dev = SDL_GetAudioStreamDevice(audio_stream);
#else
    SDL_AudioSpec want, have;
    SDL_zero(want);
    /* Prefer a native device rate; convert 18 kHz → device via AudioStream. */
    want.freq = 48000;
    want.format = AUDIO_S16SYS;
    want.channels = 1;
    want.samples = (Uint16)device_samples;
    want.callback = NULL;
    audio_dev = SDL_OpenAudioDevice(NULL, 0, &want, &have,
                                    SDL_AUDIO_ALLOW_FREQUENCY_CHANGE |
                                    SDL_AUDIO_ALLOW_SAMPLES_CHANGE);
    if (!audio_dev) {
        fprintf(stderr, "SDL_OpenAudioDevice: %s\n", SDL_GetError());
        return -1;
    }
    device_rate = have.freq > 0 ? have.freq : 48000;
    device_channels = have.channels > 0 ? have.channels : 1;
    audio_cvt = SDL_NewAudioStream(AUDIO_S16SYS, 1, sample_rate,
                                   have.format, have.channels, device_rate);
    if (!audio_cvt) {
        fprintf(stderr, "SDL_NewAudioStream: %s\n", SDL_GetError());
        SDL_CloseAudioDevice(audio_dev);
        audio_dev = 0;
        return -1;
    }
#endif

    /* ~150 ms of silence so the first slow frames never underrun. */
    prefill = audio_half * 8;
    if (prefill < (sample_rate / 10))
        prefill = sample_rate / 10;
    silence = (int16_t *)calloc((size_t)prefill, sizeof(int16_t));
    if (silence) {
        host_platform_audio_queue(silence, prefill);
        free(silence);
    }

#if HOST_SDL == 3
    SDL_ResumeAudioDevice(audio_dev);
#else
    SDL_PauseAudioDevice(audio_dev, 0);
#endif
    return 0;
}

void host_platform_audio_queue(const int16_t *mono, int samples)
{
    if (!mono || samples <= 0)
        return;
#if HOST_SDL == 3
    if (audio_stream)
        SDL_PutAudioStreamData(audio_stream, mono, samples * (int)sizeof(int16_t));
#else
    if (!audio_dev || !audio_cvt)
        return;
    if (SDL_AudioStreamPut(audio_cvt, mono, samples * (int)sizeof(int16_t)) != 0)
        return;
    for (;;) {
        int avail = SDL_AudioStreamAvailable(audio_cvt);
        int got;
        if (avail <= 0)
            break;
        if (avail > (int)sizeof(audio_scratch))
            avail = (int)sizeof(audio_scratch);
        got = SDL_AudioStreamGet(audio_cvt, audio_scratch, avail);
        if (got <= 0)
            break;
        SDL_QueueAudio(audio_dev, audio_scratch, (Uint32)got);
    }
#endif
}

void host_platform_audio_stop(void)
{
#if HOST_SDL == 3
    if (audio_stream) {
        SDL_DestroyAudioStream(audio_stream);
        audio_stream = NULL;
        audio_dev = 0;
    }
#else
    if (audio_cvt) {
        SDL_FreeAudioStream(audio_cvt);
        audio_cvt = NULL;
    }
    if (audio_dev) {
        SDL_CloseAudioDevice(audio_dev);
        audio_dev = 0;
    }
#endif
    device_rate = 0;
    device_channels = 1;
}

int host_platform_audio_queued_samples(void)
{
    /* Return queued audio expressed in *emu* (source) mono samples. */
#if HOST_SDL == 3
    int bytes;
    if (!audio_stream)
        return 0;
    bytes = SDL_GetAudioStreamQueued(audio_stream);
    if (bytes <= 0)
        return 0;
    return bytes / (int)sizeof(int16_t);
#else
    int bytes;
    int frames;
    if (!audio_dev || device_rate <= 0)
        return 0;
    bytes = (int)SDL_GetQueuedAudioSize(audio_dev);
    if (bytes <= 0)
        return 0;
    frames = bytes / ((int)sizeof(int16_t) * (device_channels > 0 ? device_channels : 1));
    return (int)(((int64_t)frames * sample_rate) / device_rate);
#endif
}
