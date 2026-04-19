#!/bin/bash
set -e

SRC="/usr/share/icons/Yaru"
DST="/home/pete/Work/cathode-phosphor-icon-theme/cathode-phosphor"
SHADE="#55b555"
GREEN="#33ff33"
TMPDIR="/tmp/robco-build"

mkdir -p "$TMPDIR"

# ============================================================
# PRE-GENERATE SCANLINE OVERLAYS
# ============================================================
generate_scanlines() {
    local size=$1
    local f="$TMPDIR/scanlines-${size}.png"
    [ -f "$f" ] && return
    magick -size ${size}x${size} xc:white \
      -fill 'gray(65%)' \
      -draw "$(for i in $(seq 1 2 $((size-1))); do printf "line 0,$i ${size},$i "; done)" \
      "$f"
}

for s in 8 16 22 24 32 48 64 128 256 512; do
    generate_scanlines $s
done

# ============================================================
# HELPER: make dark green folder base at given size
# ============================================================
make_folder_base() {
    local src_folder="$1"  # path to folder.png at this size
    local size="$2"
    local out="$3"
    
    generate_scanlines "$size"
    
    magick "$src_folder" -alpha extract "$TMPDIR/_base_a.png"
    magick "$src_folder" \
      -alpha off -colorspace Gray -brightness-contrast -10x0 -colorspace sRGB \
      \( -size ${size}x${size} xc:"${SHADE}" \) -compose Multiply -composite \
      "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \
      "$TMPDIR/_base_rgb.png"
    magick "$TMPDIR/_base_rgb.png" "$TMPDIR/_base_a.png" \
      -compose CopyOpacity -composite "$out"
}

# ============================================================
# HELPER: extract emblem via diff and composite on base
# ============================================================
make_folder_with_emblem() {
    local folder_plain="$1"
    local folder_variant="$2"
    local base="$3"
    local size="$4"
    local out="$5"
    
    generate_scanlines "$size"
    
    # Extract emblem
    magick "$folder_plain" "$folder_variant" \
      -compose Difference -composite \
      -colorspace Gray -threshold 8% \
      "$TMPDIR/_em.png"
    
    # Bright green emblem with scanlines
    magick -size ${size}x${size} xc:"${GREEN}" \
      "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \
      "$TMPDIR/_em.png" -compose CopyOpacity -composite \
      "$TMPDIR/_eg.png"
    
    # Composite on base
    magick "$base" "$TMPDIR/_eg.png" -compose Over -composite "$out"
}

# ============================================================
# HELPER: two-tone saturation approach for non-folder icons
# ============================================================
make_twotone() {
    local src="$1"
    local out="$2"
    local size
    size=$(magick identify -format "%w" "$src" 2>/dev/null) || return 1
    
    generate_scanlines "$size"
    
    magick "$src" -alpha extract "$TMPDIR/_tt_a.png"
    magick "$src" -alpha off \
      -fx "sat=saturation; lum=lightness; sat > 0.15 ? lum * 1.8 : lum * 0.35" \
      -colorspace Gray -colorspace sRGB \
      \( -size ${size}x${size} xc:"${GREEN}" \) -compose Multiply -composite \
      "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \
      "$TMPDIR/_tt_r.png"
    magick "$TMPDIR/_tt_r.png" "$TMPDIR/_tt_a.png" \
      -compose CopyOpacity -composite "$out"
}

# ============================================================
# HELPER: desktop monitor with prompt
# ============================================================
make_desktop() {
    local size="$1"
    local out="$2"
    
    generate_scanlines "$size"
    
    local mon_size=$((size * 3 / 4))
    
    # Render monitor
    magick /usr/share/icons/Yaru/scalable/devices/video-display-symbolic.svg \
      -resize ${mon_size}x${mon_size} -background none -gravity center -extent ${size}x${size} \
      "$TMPDIR/_mon_full.png"
    
    magick "$TMPDIR/_mon_full.png" -alpha extract "$TMPDIR/_mon_a.png"
    
    # Dark green body
    magick "$TMPDIR/_mon_full.png" \
      -alpha off -colorspace Gray -brightness-contrast -10x0 -colorspace sRGB \
      \( -size ${size}x${size} xc:"${SHADE}" \) -compose Multiply -composite \
      "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \
      "$TMPDIR/_mon_dark.png"
    magick "$TMPDIR/_mon_dark.png" "$TMPDIR/_mon_a.png" \
      -compose CopyOpacity -composite "$TMPDIR/_mon_body.png"
    
    # Black screen (erode to get inner area)
    magick "$TMPDIR/_mon_a.png" -morphology Erode Square:$((size/24 + 1)) "$TMPDIR/_screen_a.png"
    magick -size ${size}x${size} xc:'#050505' \
      "$TMPDIR/_screen_a.png" -compose CopyOpacity -composite \
      "$TMPDIR/_black_screen.png"
    
    # Green cursor prompt
    local cx=$((size * 29 / 100))
    local cy=$((size * 42 / 100))
    local ch=$((size * 14 / 100))
    local cw=$((size * 5 / 100))
    local cw2=$((size * 13 / 100))
    magick -size ${size}x${size} xc:none \
      -fill "${GREEN}" \
      -draw "rectangle $cx,$cy $((cx+cw)),$((cy+ch))" \
      -draw "rectangle $((cx+cw+2)),$cy $((cx+cw+2+cw2)),$((cy+ch))" \
      "$TMPDIR/_cursor.png"
    
    magick "$TMPDIR/_mon_body.png" "$TMPDIR/_black_screen.png" -compose Over -composite \
      "$TMPDIR/_cursor.png" -compose Over -composite "$out"
}

# ============================================================
# HELPER: remote folder with drawn globe
# ============================================================
make_remote() {
    local base="$1"
    local size="$2"
    local out="$3"
    
    generate_scanlines "$size"
    
    # Draw globe scaled to size
    local r=$((size * 25 / 100))
    local cx=$((size / 2))
    local cy=$((size / 2))
    local er=$((r * 50 / 100))
    
    magick -size ${size}x${size} xc:none \
      -fill none -stroke "${GREEN}" -strokewidth $((size / 24 + 1)) \
      -draw "circle $cx,$cy $cx,$((cy-r))" \
      -draw "line $((cx-r)),$cy $((cx+r)),$cy" \
      -draw "line $cx,$((cy-r)) $cx,$((cy+r))" \
      -draw "ellipse $cx,$cy $er,$r 0,360" \
      "$TMPDIR/_globe.png"
    
    magick "$TMPDIR/_globe.png" \
      \( +clone -alpha extract \) \
      \( -clone 0 -alpha off \
         "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \) \
      -delete 0 +swap -compose CopyOpacity -composite \
      "$TMPDIR/_globe_scan.png"
    
    magick "$base" "$TMPDIR/_globe_scan.png" -compose Over -composite "$out"
}

# ============================================================
# HELPER: recent/clock icon
# ============================================================
make_recent() {
    local src="$1"
    local size="$2"
    local out="$3"
    
    generate_scanlines "$size"
    
    magick "$src" -alpha extract "$TMPDIR/_rc_a.png"
    magick "$src" \
      -alpha off -colorspace Gray -negate -brightness-contrast 20x60 -colorspace sRGB \
      \( -size ${size}x${size} xc:"${GREEN}" \) -compose Multiply -composite \
      "$TMPDIR/scanlines-${size}.png" -compose Multiply -composite \
      "$TMPDIR/_rc_r.png"
    magick "$TMPDIR/_rc_r.png" "$TMPDIR/_rc_a.png" \
      -compose CopyOpacity -composite "$out"
}

# ============================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================
echo "Creating directory structure..."
find "$SRC" -type d | while read dir; do
    reldir="${dir#$SRC}"
    mkdir -p "${DST}${reldir}" 2>/dev/null
done

# ============================================================
# PROCESS PLACE ICONS (FOLDERS) - ALL SIZES
# ============================================================
echo "Processing place icons..."

FOLDER_VARIANTS="folder-download folder-music folder-pictures folder-documents folder-videos folder-publicshare folder-templates folder-dropbox"
DIFF_SPECIALS="user-home"

for sizedir in 16x16 16x16@2x 24x24 24x24@2x 32x32 32x32@2x 48x48 48x48@2x 256x256 256x256@2x; do
    placedir="${SRC}/${sizedir}/places"
    [ -d "$placedir" ] || continue
    
    outdir="${DST}/${sizedir}/places"
    mkdir -p "$outdir"
    
    # Determine pixel size
    base_size="${sizedir%%x*}"
    if [[ "$sizedir" == *"@2x"* ]]; then
        px_size=$((base_size * 2))
    else
        px_size=$base_size
    fi
    
    plain_folder="${placedir}/folder.png"
    [ -f "$plain_folder" ] || continue
    
    # Make the folder base
    make_folder_base "$plain_folder" "$px_size" "$TMPDIR/base-${sizedir}.png"
    
    # Plain folder
    cp "$TMPDIR/base-${sizedir}.png" "${outdir}/folder.png"
    # inode-directory is same as folder
    cp "$TMPDIR/base-${sizedir}.png" "${outdir}/inode-directory.png" 2>/dev/null || true
    
    # Folder variants via diff
    for variant in $FOLDER_VARIANTS; do
        src_variant="${placedir}/${variant}.png"
        [ -f "$src_variant" ] || continue
        make_folder_with_emblem "$plain_folder" "$src_variant" "$TMPDIR/base-${sizedir}.png" "$px_size" "${outdir}/${variant}.png"
    done
    
    # user-home via diff
    for special in $DIFF_SPECIALS; do
        src_special="${placedir}/${special}.png"
        [ -f "$src_special" ] || continue
        make_folder_with_emblem "$plain_folder" "$src_special" "$TMPDIR/base-${sizedir}.png" "$px_size" "${outdir}/${special}.png"
    done
    
    # user-desktop: standalone monitor with prompt
    if [ -f "${placedir}/user-desktop.png" ]; then
        make_desktop "$px_size" "${outdir}/user-desktop.png"
    fi
    
    # folder-remote: globe on folder
    if [ -f "${placedir}/folder-remote.png" ]; then
        make_remote "$TMPDIR/base-${sizedir}.png" "$px_size" "${outdir}/folder-remote.png"
    fi
    
    # folder-recent: inverted clock
    if [ -f "${placedir}/folder-recent.png" ]; then
        make_recent "${placedir}/folder-recent.png" "$px_size" "${outdir}/folder-recent.png"
    fi
    
    # user-trash: two-tone approach
    if [ -f "${placedir}/user-trash.png" ]; then
        make_twotone "${placedir}/user-trash.png" "${outdir}/user-trash.png"
    fi
    
    # Remaining place icons: two-tone
    for f in "${placedir}"/*.png; do
        name=$(basename "$f")
        [ -f "${outdir}/${name}" ] && continue  # skip already processed
        make_twotone "$f" "${outdir}/${name}" 2>/dev/null || cp "$f" "${outdir}/${name}"
    done
    
    echo "  Places ${sizedir} done"
done

echo "Place icons complete!"
