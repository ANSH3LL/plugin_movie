LOCAL_PATH := $(call my-dir)

OGG_HEADERS := $(LOCAL_PATH)/../../libogg/include
VORBIS_HEADERS := $(LOCAL_PATH)/../../libvorbis/include
THEORA_HEADERS := $(LOCAL_PATH)/../../libtheora/include

OGG_SOURCES := $(wildcard $(LOCAL_PATH)/../../libogg/src/*.c)
VORBIS_SOURCES := $(wildcard $(LOCAL_PATH)/../../libvorbis/lib/*.c)
THEORA_SOURCES := $(wildcard $(LOCAL_PATH)/../../libtheora/lib/*.c)

THEORA_ARM_OPTIM := $(wildcard $(LOCAL_PATH)/../../libtheora/lib/arm/*.c)
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
    -fsigned-char \
    -Ofast \
    -fPIC \
    -DPIC

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), x86)
    LOCAL_CFLAGS+= -DOC_X86_ASM
else ifeq ($(TARGET_ARCH_ABI), x86_64)
    LOCAL_CFLAGS+= -DOC_X86_ASM -DOC_X86_64_ASM
else
    $(error Not a supported TARGET_ARCH_ABI: $(TARGET_ARCH_ABI))
endif

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
    -fsigned-char \
    -Ofast \
    -fPIC \
    -DPIC

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), x86)
    LOCAL_CFLAGS+= -DOC_X86_ASM
else ifeq ($(TARGET_ARCH_ABI), x86_64)
    LOCAL_CFLAGS+= -DOC_X86_ASM -DOC_X86_64_ASM
else
    $(error Not a supported TARGET_ARCH_ABI: $(TARGET_ARCH_ABI))
endif

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
    -fsigned-char \
    -Ofast \
    -fPIC \
    -DPIC

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    LOCAL_SRC_FILES+= $(THEORA_ARM_OPTIM:$(LOCAL_PATH)/%=%)
else ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    LOCAL_SRC_FILES+= $(THEORA_ARM_OPTIM:$(LOCAL_PATH)/%=%)
else ifeq ($(TARGET_ARCH_ABI), x86)
    LOCAL_SRC_FILES+= $(THEORA_X86_OPTIM:$(LOCAL_PATH)/%=%)
else ifeq ($(TARGET_ARCH_ABI), x86_64)
    LOCAL_SRC_FILES+= $(THEORA_X86_OPTIM:$(LOCAL_PATH)/%=%)
else
    $(error Not a supported TARGET_ARCH_ABI: $(TARGET_ARCH_ABI))
endif

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), arm64-v8a)
    LOCAL_CFLAGS+= -D_ARM_ASSEM_ -D_M_ARM -DOC_ARM_ASM
else ifeq ($(TARGET_ARCH_ABI), x86)
    LOCAL_CFLAGS+= -DOC_X86_ASM
else ifeq ($(TARGET_ARCH_ABI), x86_64)
    LOCAL_CFLAGS+= -DOC_X86_ASM -DOC_X86_64_ASM
else
    $(error Not a supported TARGET_ARCH_ABI: $(TARGET_ARCH_ABI))
endif

include $(BUILD_STATIC_LIBRARY)
