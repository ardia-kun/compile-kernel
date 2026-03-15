#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/ardia-kun/kernel_xiaomi_surya_ten -b ten --single-branch --no-tags kernel
cd kernel
#git clone --depth=1 https://github.com/KudProject/aarch64-linux-android-4.9.git gcc64
#git clone --depth=1 https://github.com/KudProject/arm-linux-androideabi-4.9.git gcc32
git clone --depth=1 https://github.com/picasso09/clang-9.0.3-r353983c1 clang
rm -rf AnyKernel
git clone --depth=1 https://github.com/stormbreaker-project/AnyKernel3 -b surya AnyKernel
git clone --depth=1 https://android.googlesource.com/platform/system/libufdt libufdt
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
LOG=$(echo *.log)
START=$(date +"%s")
export CONFIG_PATH=$PWD/arch/arm64/configs/surya_defconfig
TC_DIR=${PWD}
GCC64_DIR="${PWD}/gcc64"
GCC32_DIR="${PWD}/gcc32"
CLANG_DIR="${PWD}/clang"
KBUILD_COMPILER_STRING=$("$CLANG_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
PATH="$CLANG_DIR/bin/:$PATH"
#PATH="$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH"
CHATID=-1001200423387
BOTTOKEN=1806647024:AAEv-Nx38_a5r7LDyaZwWqa_xxeidj-MKaQ
export ARCH=arm64
export PATH KBUILD_COMPILER_STRING
export KBUILD_BUILD_HOST="google.cloud"
export KBUILD_BUILD_USER="queen"

# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$BOTTOKEN/sendSticker" \
        -d sticker="CAADBQADVAADaEQ4KS3kDsr-OWAUFgQ" \
        -d chat_id=$CHATID
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$BOTTOKEN/sendMessage" \
        -d chat_id="$CHATID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• surya-Stormbreaker Kernel •</b>%0ABuild started on <code>Circle CI</code>%0AFor device <b>Poco X3</b> (picasso)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>$KBUILD_COMPILER_STRING</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b> #AOSP-Alpha"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$BOTTOKEN/sendDocument" \
        -F chat_id="$CHATID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Poco X3 (surya)</b> | <b>Eva GCC</b>"
}
# Fin Error
function finerr() {
    curl -F document=@$LOG "https://api.telegram.org/bot$BOTTOKEN/sendDocument" \
        -F chat_id="$CHATID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build logs"
}
# Compile plox
function compile() {
   make ARCH=arm64 clean O=out surya_defconfig
   make -j4 O=out \
   CROSS_COMPILE=aarch64-linux-gnu- \
   CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
#   CC=$CLANG_DIR/bin/clang \
#   AR=$CLANG_DIR/bin/llvm-ar \
#   OBJDUMP=$CLANG_DIR/bin/llvm-objdump \
#   STRIP==$CLANG_DIR/bin/llvm-strip \
#   NM==$CLANG_DIR/bin/llvm-nm \
#   OBJCOPY==$CLANG_DIR/bin/llvm-objcopy \
   LD=ld.lld 2>&1 | tee error.log

   cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
   python3 "libufdt/utils/src/mkdtboimg.py" \
   create "out/arch/arm64/boot/dtbo.img" --page_size=4096 out/arch/arm64/boot/dts/qcom/*.dtbo
   cp out/arch/arm64/boot/dtbo.img AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 surya-kidz-${TANGGAL}.zip *
    cd ..
}
sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
finerr
push
