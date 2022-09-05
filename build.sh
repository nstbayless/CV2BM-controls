set -e

FLIPS="./flips/flips-linux"
DST="cv2gb-controls"

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
    BASEROM=$1
    BUILDNAME=$BASEROM-$2
    echo "Assembling patch $BUILDNAME"
    chmod a-w base-$BASEROM.gb
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
    z80asm -v -o $BUILDNAME.gb --label=$BUILDNAME.lbl -i cfg.asm patch.asm
    $FLIPS -c --ips base-$BASEROM.gb $BUILDNAME.gb $BUILDNAME.ips
    
    # TODO: error if any of these end exceed 7fff (or 3fff for bank0).
    echo "$DST/$BASEROM $BUILDNAME"
    
    set +e
    grep "end_bank[0-9A-Fa-f]\+:" $BUILDNAME.lbl
    grep "end_.*_region:" $BUILDNAME.lbl
    
    checkmax "$BUILDNAME.lbl" end_subweapon_region 4ad2
    checkmax "$BUILDNAME.lbl" end_bank0 3fff
    checkmax "$BUILDNAME.lbl" end_bank1 7fff
    checkmax "$BUILDNAME.lbl" end_bank3 7fcf
    checkmax "$BUILDNAME.lbl" end_bank4 7fff
    checkmax "$BUILDNAME.lbl" end_bank6 7fff
    checkmax "$BUILDNAME.lbl" end_bank7 7fff
    
    set -e

    mkdir -p "$DST/$BASEROM"
    cp "$BUILDNAME.ips" "$DST/$BASEROM"
}

build us subweapons "SUBWEAPONS: equ 1" "CONTROL: equ 0" "VCANCEL: equ 0" "INERTIA: equ 0"
build us vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build us no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build us inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build us inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"

build jp vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build jp no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build jp inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build jp inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"

build kgbc4eu vcancel "VCANCEL: equ 1" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build kgbc4eu no-vcancel "VCANCEL: equ 0" "INERTIA: equ 0" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build kgbc4eu inertia-vcancel "VCANCEL: equ 1" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"
build kgbc4eu inertia-no-vcancel "VCANCEL: equ 0" "INERTIA: equ 1" "SUBWEAPONS: equ 0" "CONTROL: equ 1"

cp README.txt "$DST"

if [ -f "$DST.zip" ]
then
    rm *.zip
fi
7z a "./$DST.zip" "./$DST"

exit 0