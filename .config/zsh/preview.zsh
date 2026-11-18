#!/usr/bin/env zsh
# ==============================================================================
# Universal preview dispatcher for fzf (preview.zsh)
# Powered by Kitty, bat, eza, ffmpeg/ffprobe, and native archive inspection
# ==============================================================================

local target="${1:-}"

# Clear any lingering Kitty terminal graphics from previous preview
clear_graphics() {
    if [[ -n "$KITTY_WINDOW_ID" || "$TERM" == *kitty* ]]; then
        printf "\033_Ga=d,d=A\033\\"
    fi
}

if [[ -z "$target" || ! -e "$target" ]]; then
    clear_graphics
    echo "No file or directory selected"
    exit 0
fi

# 1. Directories (visual tree via eza)
if [[ -d "$target" ]]; then
    clear_graphics
    if command -v eza >/dev/null 2>&1; then
        eza --tree --level=2 --icons --color=always "$target" | head -n 100
    else
        ls -la "$target" | head -n 100
    fi
    exit 0
fi

# Lowercased filename and MIME type
local filename="${target:t:l}"
local mime
mime=$(file --mime-type -bL "$target" 2>/dev/null || echo "")

# Helper to render images using Kitty icat protocol with unicode placeholder
display_image() {
    local img="$1"
    local top_offset="${2:-0}"
    local raw_cols="${FZF_PREVIEW_COLUMNS:-80}"
    local cols=$(( raw_cols > 2 ? raw_cols - 1 : raw_cols ))
    local total_lines="${FZF_PREVIEW_LINES:-30}"
    local available_lines=$(( total_lines - top_offset ))
    if (( available_lines < 3 )); then
        available_lines=3
    fi

    if command -v kitty >/dev/null 2>&1; then
        local dim="${cols}x${available_lines}"
        kitty +kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align center --place="$dim@0x0" "$img" | sed '$d' | sed $'$s/$/\e[m/'
    else
        file -b "$img"
        if command -v sips >/dev/null 2>&1; then
            echo ""
            sips -g pixelWidth -g pixelHeight "$img" 2>/dev/null
        fi
    fi
}

# 2. Archives (in-memory streaming inspection - zero disk writes)
case "$filename" in
    *.zip)
        clear_graphics
        echo -e "\033[1;34m📦 ZIP Archive Contents (in-memory):\033[0m\n"
        if command -v zipinfo >/dev/null 2>&1; then
            zipinfo -l "$target" | head -n 100
        else
            unzip -l "$target" | head -n 100
        fi
        exit 0
        ;;
    *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz)
        clear_graphics
        echo -e "\033[1;34m📦 TAR Archive Contents (in-memory):\033[0m\n"
        tar -tvf "$target" | head -n 100
        exit 0
        ;;
    *.gz)
        clear_graphics
        echo -e "\033[1;34m📦 GZIP Compressed File (in-memory):\033[0m\n"
        gzip -l "$target" 2>/dev/null || file -b "$target"
        exit 0
        ;;
    *.7z)
        clear_graphics
        echo -e "\033[1;34m📦 7-Zip Archive (in-memory):\033[0m\n"
        if command -v 7z >/dev/null 2>&1; then
            7z l "$target" | head -n 100
        else
            file -b "$target"
        fi
        exit 0
        ;;
esac

# 3. PDF Documents
if [[ "$filename" == *.pdf || "$mime" == "application/pdf" ]]; then
    clear_graphics
    echo -e "\033[1;31m📄 PDF Document\033[0m\n"
    if command -v pdftotext >/dev/null 2>&1; then
        pdftotext -l 5 -nopgbrk -q "$target" - | head -n 80
    else
        file -b "$target"
        echo -e "\n\033[33mInstall 'poppler' (pdftotext) to preview PDF contents in terminal:\033[0m"
        echo "  - macOS: brew install poppler"
        echo "  - Linux: sudo apt install poppler-utils / sudo pacman -S poppler"
    fi
    exit 0
fi

# 4. Images (Kitty icat)
case "$mime" in
    image/*)
        display_image "$target" 0
        exit 0
        ;;
esac

case "$filename" in
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.svg|*.bmp|*.ico)
        display_image "$target" 0
        exit 0
        ;;
esac

# 5. Videos (fast, reliable metadata details via ffprobe)
local is_video=false
case "$mime" in
    video/*) is_video=true ;;
esac
case "$filename" in
    *.mp4|*.mkv|*.mov|*.avi|*.webm|*.flv|*.m4v|*.av1|*.ivf|*.ts|*.m2ts|*.ogv|*.wmv) is_video=true ;;
esac

if [[ "$is_video" == true ]]; then
    clear_graphics

    if command -v ffprobe >/dev/null 2>&1; then
        local width="" height="" codec_name="" r_frame_rate="" duration="" size="" bit_rate=""
        local vbitrate="" acodec="" achannels="" abitrate=""

        # Extract video stream info (including BPS tag for MKV fallback)
        local probe_v
        probe_v=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,codec_name,r_frame_rate,bit_rate:stream_tags=BPS -of default=noprint_wrappers=1 "$target" 2>/dev/null)
        eval "$(echo "$probe_v" | grep -v ":")"
        vbitrate="$bit_rate"
        [[ -z "$vbitrate" || "$vbitrate" == "N/A" ]] && vbitrate=$(echo "$probe_v" | grep "^TAG:BPS=" | cut -d= -f2)

        # Extract audio stream info (including BPS tag for MKV fallback)
        local probe_a
        probe_a=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,channels,bit_rate:stream_tags=BPS -of default=noprint_wrappers=1 "$target" 2>/dev/null)
        acodec=$(echo "$probe_a" | grep "^codec_name=" | cut -d= -f2)
        achannels=$(echo "$probe_a" | grep "^channels=" | cut -d= -f2)
        abitrate=$(echo "$probe_a" | grep "^bit_rate=" | cut -d= -f2)
        [[ -z "$abitrate" || "$abitrate" == "N/A" ]] && abitrate=$(echo "$probe_a" | grep "^TAG:BPS=" | cut -d= -f2)

        # Extract container format info
        local probe_f
        probe_f=$(ffprobe -v error -show_entries format=duration,size,bit_rate -of default=noprint_wrappers=1 "$target" 2>/dev/null)
        eval "$probe_f"

        # Fallback for duration if format duration was empty
        if [[ -z "$duration" || "$duration" == "N/A" ]]; then
            duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$target" 2>/dev/null)
        fi

        # Format duration
        local formatted_duration=""
        if [[ -n "$duration" && "$duration" != "N/A" ]]; then
            local total_secs=${duration%.*}
            local hrs=$(( total_secs / 3600 ))
            local mins=$(( (total_secs % 3600) / 60 ))
            local secs=$(( total_secs % 60 ))
            if (( hrs > 0 )); then
                formatted_duration=$(printf "%02d:%02d:%02d" "$hrs" "$mins" "$secs")
            else
                formatted_duration=$(printf "%02d:%02d" "$mins" "$secs")
            fi
        fi

        # Format file size
        local formatted_size=""
        if [[ -n "$size" && "$size" != "N/A" ]]; then
            if (( size > 1073741824 )); then
                formatted_size=$(printf "%.2f GB" "$(( size / 1073741824.0 ))")
            elif (( size > 1048576 )); then
                formatted_size=$(printf "%.1f MB" "$(( size / 1048576.0 ))")
            elif (( size > 1024 )); then
                formatted_size=$(printf "%.1f KB" "$(( size / 1024.0 ))")
            fi
        fi

        # Format frame rate
        local fps=""
        if [[ "$r_frame_rate" == *"/"* ]]; then
            local num=${r_frame_rate%/*} den=${r_frame_rate#*/}
            if (( den > 0 )); then
                fps=$(printf "%.0f" "$(( num * 1.0 / den ))")
            fi
        elif [[ -n "$r_frame_rate" && "$r_frame_rate" != "0/0" ]]; then
            fps="$r_frame_rate"
        fi

        # Format video bitrate
        local formatted_vbitrate=""
        if [[ -n "$vbitrate" && "$vbitrate" != "N/A" && "$vbitrate" != "0" ]]; then
            formatted_vbitrate=$(printf "%.0f kbps" "$(( vbitrate / 1000.0 ))")
        fi

        # Format audio bitrate
        local formatted_abitrate=""
        if [[ -n "$abitrate" && "$abitrate" != "N/A" && "$abitrate" != "0" ]]; then
            formatted_abitrate=$(printf "%.0f kbps" "$(( abitrate / 1000.0 ))")
        fi

        echo -e "\033[1;35m🎬 Video Media Details\033[0m"
        echo -e "\033[90m────────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[1;37mFile:\033[0m          ${target:t}"
        [[ -n "$formatted_size" ]] && echo -e "\033[1;37mSize:\033[0m          ${formatted_size}"
        [[ -n "$formatted_duration" ]] && echo -e "\033[1;37mDuration:\033[0m      ${formatted_duration}"
        [[ -n "$width" && -n "$height" ]] && echo -e "\033[1;37mResolution:\033[0m    ${width}x${height}$([[ -n "$fps" ]] && echo " @ ${fps} fps")"
        [[ -n "$codec_name" ]] && echo -e "\033[1;37mVideo Codec:\033[0m   ${codec_name}"
        [[ -n "$formatted_vbitrate" ]] && echo -e "\033[1;37mVideo Bitrate:\033[0m ${formatted_vbitrate}"
        [[ -n "$acodec" ]] && echo -e "\033[1;37mAudio Codec:\033[0m   ${acodec}$([[ -n "$achannels" ]] && echo " (${achannels} ch)")"
        [[ -n "$formatted_abitrate" ]] && echo -e "\033[1;37mAudio Bitrate:\033[0m ${formatted_abitrate}"
        echo -e "\033[90m────────────────────────────────────────────────────────────\033[0m"
    else
        echo -e "\033[1;35m🎬 Video Media\033[0m\n"
        file -b "$target"
    fi
    exit 0
fi

# 6. Plain text, code, configs (bat)
if [[ "$mime" =~ "^text/" || "$mime" == "application/json" || "$mime" == "application/xml" || "$mime" == "application/javascript" || -z "$mime" ]]; then
    clear_graphics
    if command -v bat >/dev/null 2>&1; then
        bat --color=always --style=plain,numbers --line-range=:500 "$target"
    else
        head -n 100 "$target"
    fi
    exit 0
fi

# 7. Unknown Binary (hexdump)
clear_graphics
echo -e "\033[1;33m⚙️  Binary File\033[0m\n"
file -b "$target"
echo -e "\n\033[1;34m--- Hexdump Preview ---\033[0m"
hexdump -C "$target" 2>/dev/null | head -n 40
