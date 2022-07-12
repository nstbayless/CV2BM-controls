set -e

FLIPS="./flips/flips-linux"

if ! command -v z80asm &> /dev/null
then
    echo "z80asm required. (On ubuntu: sudo apt install z80asm)"
    exit 1
fi

if ! [ -f base.gb ]
then
    echo "base.gb required (CVII Belmont's revenge ROM)"
    exit 1
fi

chmod a-w base.gb
chmod u+x "$FLIPS"

function build() {
    BUILDNAME=$1
    shift
    echo "$@" > cfg.asm
    z80asm -v -o $BUILDNAME.gb --label=$BUILDNAME.lbl -i cfg.asm patch.asm
    $FLIPS -c --ips base.gb $BUILDNAME.gb patch.ips
}

build vcancel "VCANCEL: equ 1"
build no-vcancel "VCANCEL: equ 0"