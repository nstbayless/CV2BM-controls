set -e

FLIPS="./flips/flips-linux"
DST="build"
TESTROM0="test0.gb"
TESTROM1="test1.gb"
TESTROM2="test2.gb"

if ! command -v z80asm &> /dev/null
then
    echo "z80asm required. (On ubuntu: sudo apt install z80asm)"
    exit 1
fi

if ! [ -f base-us.gb ] && ! [ -f base-jp.gb ]
then
    echo "at least one of the following ROMS is required: base-us.gb, base-jp.gb"
    exit 1
fi

chmod u+x "$FLIPS"

if [ -d "$DST" ]
then
    rm -r "$DST"
fi

mkdir "$DST"
echo "# checksums for the patch files themselves." > patchsums.txt

function getLabel() {
    A=$(sed 's/[\t ]\+/ /g' "$1" | grep -oP "(?<=$2"': equ \$).*')
    if [ -z "$A" ]; then
        return 1
    else
        echo "0x$A"
        return 0
    fi
}

function checkmax() {
    if label=$(getLabel "$1" "$2"); then
        if [[ $label -gt "0x$3" ]]; then
            echo "EXCEEDED: $2: $label > $3"
            exit
        fi
    fi
}

function build() {
    BASEPATCH=$1
    BASEROM=$2
    EXPORT=$3
    BUILDNAME=$BASEROM-$4
    echo "Assembling patch $EXPORT/$BUILDNAME"
    chmod a-w base-$BASEROM.gb
    shift
    shift
    shift
    shift
    
    echo "incbin 'base-$BASEROM.gb'" > cfg.asm
    echo "rom_us: equ 10" >> cfg.asm
    echo "rom_jp: equ 11" >> cfg.asm
    echo "rom_kgbc4eu: equ 22" >> cfg.asm
    echo "rom_type: equ rom_$BASEROM" >> cfg.asm
    
    while [ $# -gt 0 ]
    do
        echo "$1" >> cfg.asm
        shift
    done
    
    md5sum base-$BASEROM.gb
    sha256sum base-$BASEROM.gb
    crc32 base-$BASEROM.gb
    
    PATCH="$BASEPATCH.asm"
    
    z80asm -v -o $BUILDNAME.gb --label=$BUILDNAME.lbl -i cfg.asm $PATCH
    $FLIPS -c --ips base-$BASEROM.gb $BUILDNAME.gb $BUILDNAME.ips
    
    # TODO: error if any of these end exceed 7fff (or 3fff for bank0).
    echo "$DST/$EXPORT/$BASEROM $BUILDNAME"
    
    set +e
    grep "end_bank[0-9A-Fa-f]\+:" $BUILDNAME.lbl
    set -e
    
    checkmax "$BUILDNAME.lbl" end_subweapon_region 4ad2
    checkmax "$BUILDNAME.lbl" end_bank0 3fff
    checkmax "$BUILDNAME.lbl" end_bank1 7fff
    checkmax "$BUILDNAME.lbl" end_bank1B 7fff
    checkmax "$BUILDNAME.lbl" end_bank3A 6a00
    checkmax "$BUILDNAME.lbl" end_bank3 7fcf
    checkmax "$BUILDNAME.lbl" end_bank4 7fff
    checkmax "$BUILDNAME.lbl" end_bank6 7fff
    checkmax "$BUILDNAME.lbl" end_bank7 7fff

    mkdir -p "$DST/$EXPORT/$BASEROM"
    md5sum "$BUILDNAME.ips" >> patchsums.txt
    cp "$BUILDNAME.ips" "$DST/$EXPORT/$BASEROM"
}

function simplemd5() {
    md5sum "$1" | cut -d ' ' -f 1
}

function comptest() {
    BASEROM=$1
    EXPORT0=$2
    BUILDNAME0="$BASEROM-$3"
    EXPORT1=$4
    BUILDNAME1="$BASEROM-$5"
    EXPORT2=$6
    BUILDNAME2="$BASEROM-$7"
    echo "Test: comparing $EXPORT0/$BUILDNAME0 == $EXPORT1/$BUILDNAME1 x $EXPORT2/$BUILDNAME2"
    PATHIPS0="$DST/$EXPORT0/$BASEROM/$BUILDNAME0.ips"
    PATHIPS1="$DST/$EXPORT1/$BASEROM/$BUILDNAME1.ips"
    PATHIPS2="$DST/$EXPORT2/$BASEROM/$BUILDNAME2.ips"
    $FLIPS -a "$PATHIPS0" "base-$BASEROM.gb" "$TESTROM0" > /dev/null
    $FLIPS -a "$PATHIPS1" "base-$BASEROM.gb" "$TESTROM1" > /dev/null
    $FLIPS -a "$PATHIPS2" "$TESTROM1"        "$TESTROM2" > /dev/null
    
    if [ $(simplemd5 "$TESTROM0") != $(simplemd5 "$TESTROM2") ]
    then
        echo "ERROR: test failed!"
        exit 5
    fi
}

build patch-us us cv2gb-subweapons subweapons "SUBWEAPONS: equ 1" "CONTROL: equ 0" "VCANCEL: equ 0" "INERTIA: equ 0"
build patch-us us cv2gb-controls no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch-us us cv2gb-controls vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch-us us cv2gb-controls inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch-us us cv2gb-controls inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch-us us test subweapons-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 1" "CONTROL: equ 1"
build patch-us us test subweapons-vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 1" "CONTROL: equ 1"
build patch-us us test subweapons-inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 1" "CONTROL: equ 1"
build patch-us us test subweapons-inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 1" "CONTROL: equ 1"

build patch jp cv2gb-controls vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch jp cv2gb-controls no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch jp cv2gb-controls inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch jp cv2gb-controls inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"

build patch kgbc4eu cv2gb-controls vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch kgbc4eu cv2gb-controls no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch kgbc4eu cv2gb-controls inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build patch kgbc4eu cv2gb-controls inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"

cp README-controls.txt "$DST/cv2gb-controls/README.txt"
cp README-subweapons.txt "$DST/cv2gb-subweapons/README.txt"

comptest us test subweapons-no-vcancel cv2gb-subweapons subweapons cv2gb-controls no-vcancel
comptest us test subweapons-vcancel cv2gb-subweapons subweapons cv2gb-controls vcancel
comptest us test subweapons-inertia-no-vcancel cv2gb-subweapons subweapons cv2gb-controls inertia-no-vcancel
comptest us test subweapons-inertia-vcancel cv2gb-subweapons subweapons cv2gb-controls inertia-vcancel

comptest us test subweapons-no-vcancel cv2gb-controls no-vcancel cv2gb-subweapons subweapons
comptest us test subweapons-vcancel cv2gb-controls vcancel cv2gb-subweapons subweapons
comptest us test subweapons-inertia-no-vcancel cv2gb-controls inertia-no-vcancel cv2gb-subweapons subweapons
comptest us test subweapons-inertia-vcancel cv2gb-controls inertia-vcancel cv2gb-subweapons subweapons

if [ -f "cv2gb-controls.zip" ]
then
    rm *.zip
fi
7z a "./cv2gb-controls.zip" "./$DST/cv2gb-controls"
7z a "./cv2gb-subweapons.zip" "./$DST/cv2gb-subweapons"

exit 0
