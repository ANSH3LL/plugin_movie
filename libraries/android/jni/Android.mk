LOCAL_PATH := $(call my-dir)

OGG_HEADERS := $(LOCAL_PATH)/../../libogg/include
VORBIS_HEADERS := $(LOCAL_PATH)/../../libvorbis/include
THEORA_HEADERS := $(LOCAL_PATH)/../../libtheora/include

OGG_SOURCES := $(wildcard $(LOCAL_PATH)/../../libogg/src/*.c)
VORBIS_SOURCES := $(wildcard $(LOCAL_PATH)/../../libvorbis/lib/*.c)
THEORA_SOURCES := $(wildcard $(LOCAL_PATH)/../../libtheora/lib/*.c)

THEORA_ARM_OPTIM := $(wildcard $(LOCAL_PATH)/../../libtheora/lib/arm/*.c)
THEORA_ARM_OPTIM += $(wildcard $(LOCAL_PATH)/../../libtheora/lib/arm/*.s)
THEORA_X86_OPTIM := $(wildcard $(LOCAL_PATH)/../../libtheora/lib/x86/*.c)

######################################################################
# OGG
include $(CLEAR_VARS)

LOCAL_MODULE := libogg

LOCAL_C_INCLUDES := $(OGG_HEADERS)

LOCAL_SRC_FILES := $(OGG_SOURCES:$(LOCAL_PATH)/%=%)

LOCAL_ARM_MODE := arm

LOCAL_CFLAGS := \
    -DANDROID_NDK \
    -DNDEBUG \
    -D_REENTRANT \
    -ffast-math \
    -Ofast \
    -fPIC \
    -DPIC

include $(BUILD_STATIC_LIBRARY)

######################################################################
# VORBIS
include $(CLEAR_VARS)

LOCAL_MODULE := libvorbis

LOCAL_C_INCLUDES := $(OGG_HEADERS) $(VORBIS_HEADERS)

LOCAL_SRC_FILES := $(VORBIS_SOURCES:$(LOCAL_PATH)/%=%)

LOCAL_ARM_MODE := arm

LOCAL_CFLAGS := \
    -DANDROID_NDK \
    -DNDEBUG \
    -D_REENTRANT \
    -ffast-math \
    -Ofast \
    -fPIC \
    -DPIC

include $(BUILD_STATIC_LIBRARY)

######################################################################
# THEORA
include $(CLEAR_VARS)

LOCAL_MODULE := libtheora

LOCAL_C_INCLUDES := $(OGG_HEADERS) $(VORBIS_HEADERS) $(THEORA_HEADERS)

LOCAL_SRC_FILES := $(THEORA_SOURCES:$(LOCAL_PATH)/%=%)

LOCAL_ARM_MODE := arm

LOCAL_CFLAGS := \
    -DANDROID_NDK \
    -DNDEBUG \
    -D_REENTRANT \
    -ffast-math \
    -Ofast \
    -fPIC \
    -DPIC

ifeq ($(TARGET_ARCH), arm)
    LOCAL_SRC_FILES+= $(THEORA_ARM_OPTIM:$(LOCAL_PATH)/%=%)
    LOCAL_CFLAGS+= -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH), x86)
    LOCAL_SRC_FILES+= $(THEORA_X86_OPTIM:$(LOCAL_PATH)/%=%)
    LOCAL_CFLAGS+= -DOC_X86_ASM
else ifeq ($(TARGET_ARCH), x86_64)
    LOCAL_SRC_FILES+= $(THEORA_X86_OPTIM:$(LOCAL_PATH)/%=%)
    LOCAL_CFLAGS+= -DOC_X86_ASM -DOC_X86_64_ASM
endif

include $(BUILD_STATIC_LIBRARY)
