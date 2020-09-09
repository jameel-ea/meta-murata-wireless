do_compile ()
{
    # Change build folder to 8997 folder
    cd ${S}/mwifiex_8997

    if [ ${TARGET_ARCH} = "aarch64" ]; then
       export ARCH=arm64
    else
       export ARCH=arm
    fi

    export CROSS_COMPILE="${TARGET_PREFIX}"

    oe_runmake build
}
