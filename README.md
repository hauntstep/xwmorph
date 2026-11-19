# xwmorph

[Русская версия](README.ru.md)

A ready-to-use desktop setup based on **vxwm** (X11): an infinite floating canvas, dual-monitor support, wallpaper-derived colors (pywal), the picom compositor with animations, and a zoom mode powered by vcompmgr.

> Tested on Gentoo (systemd) with NVIDIA. Package names may differ on other distributions, but the overall steps are the same.

## Author

<!-- TODO: add your name -->
_Build author: hauntstep_

The setup is based on [vxwm](https://codeberg.org/wh1tepearl/vxwm) by wh1tepearl, a dwm fork. Its source code is included in `vxwm/`, along with the original `LICENSE` and `LICENSE.dwm` files. Zoom functionality is provided by [vcompmgr](https://codeberg.org/wh1tepearl/vcompmgr).

## What's included

```text
vxwm/                vxwm source code with my config.h and modules.h
.config/kitty/       terminal configuration
.config/picom/       compositor configuration (rounded corners, blur, animations)
.config/rofi/        application launcher and its theme
.config/fish/        fish shell configuration
.local/bin/
  theme              change the wallpaper and color palette with one command
  zoom-on, zoom-off  switch between picom and vcompmgr for zoom mode
  barstatus          clock displayed in the vxwm bar
  fcp-on, fcp-off    ForceFullCompositionPipeline (NVIDIA only)
```

Changes to vxwm compared to the original: the clock is displayed on all monitors, and the active window title has been removed from the bar.

## Quick installation

```sh
git clone https://github.com/hauntstep/xwmorph.git ~/xwmorph
cd ~/xwmorph
./install.sh
```

> Not available yet — the installer is still being worked on.

## Manual installation

### 1. Dependencies (Gentoo)

```sh
sudo emerge --ask x11-base/xorg-server x11-apps/xinit x11-apps/xrandr \
  x11-apps/xsetroot x11-apps/xset x11-apps/setxkbmap \
  x11-libs/libXft x11-libs/libXinerama \
  x11-misc/picom x11-misc/rofi x11-misc/feh x11-terms/kitty \
  xfce-base/thunar media-gfx/sxiv media-gfx/maim x11-misc/xclip \
  media-gfx/imagemagick media-fonts/jetbrains-mono dev-vcs/git
```

For NVIDIA, also install `x11-drivers/nvidia-drivers` and `x11-misc/nvidia-settings`. Input support requires `x11-drivers/xf86-input-libinput` (without it, the keyboard and mouse will not work in X). Your user must belong to the `video` and `input` groups.

### 2. Clone the repository and install the configs

```sh
git clone https://github.com/hauntstep/xwmorph.git ~/xwmorph
mkdir -p ~/.config ~/.local/bin
cp -r ~/xwmorph/.config/. ~/.config/
cp ~/xwmorph/.local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*
```

Make sure `~/.local/bin` is in your `PATH` (in fish, run `fish_add_path ~/.local/bin`).

### 3. Build vxwm

```sh
cp -r ~/xwmorph/vxwm ~/vxwm
cd ~/vxwm
make
sudo make clean install
```

The repository already includes a configured `config.h`; `make` will not overwrite it.

### 4. Zoom mode (vcompmgr)

```sh
git clone https://codeberg.org/wh1tepearl/vcompmgr.git ~/vcompmgr
cd ~/vcompmgr
make
sudo make install
```

The following libraries are required: `libXcomposite`, `libXdamage`, `libXfixes`, `libXrender`, `libXext`, and `libdrm`. This project is experimental. It works on the NVIDIA setup tested here, but there are no guarantees. Everything else will work without it; you just won't have zoom mode.

### 5. Wallpaper-based color palette (pywal)

```sh
python -m venv ~/.venvs/wal
~/.venvs/wal/bin/pip install pywal16 haishoku
ln -sf ~/.venvs/wal/bin/wal ~/.local/bin/wal
```

Put your wallpapers in `~/Wallpapers` and apply a theme:

```sh
theme ~/Wallpapers/your_image.jpg
```

Then press **Super+F5** to apply the new colors to the bar and window borders.

### 6. The `~/.xinitrc` file

Create this file yourself and **replace the monitor names** with yours (`xrandr` will show them when run inside X):

```sh
export PATH="$HOME/.local/bin:$PATH"
xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary --pos 0x0 \
       --output DP-2 --mode 2560x1440 --rate 144 --pos 2560x0
setxkbmap -layout us,ru -option grp:alt_shift_toggle
xset s off
xset s noblank
xset -dpms
wal -R -n
xrdb -merge ~/.cache/wal/colors.Xresources
feh --bg-fill ~/Wallpapers/your_image.jpg &
picom -b
barstatus &
exec vxwm
```

### 7. Starting the desktop

Run this from a regular local console (not over SSH):

```sh
startx
```

## Keyboard shortcuts

`Super` is the Windows key. The full list of shortcuts is available in `vxwm/config.h`.

| Shortcut | Action |
|---|---|
| Super+Shift+Enter | Open the terminal (kitty) |
| Super+P | Open the application launcher (rofi) |
| Super+E | Open the file manager (Thunar) |
| Super+V | Open the screenshot viewer (sxiv) |
| Super+Shift+S | Capture a selected area to the clipboard |
| Super+Ctrl+S | Capture a selected area to `~/screenshots` |
| Super+Shift+C | Close the focused window |
| Super+Shift+Q | Exit vxwm |
| Super+F5 | Reload colors (after running `theme`) |
| Super+R | Return to the canvas origin (0,0) |
| Super+Shift+Arrow keys | Move the canvas |
| Left-click an empty area, then drag | Move the canvas with the mouse |
| Super+X, Super+Shift+X | Enable and disable zoom mode |
| Super+Mouse wheel (in zoom mode) | Zoom in and out |

Create the screenshots directory:

```sh
mkdir -p ~/screenshots
```

## Zoom mode

**picom** is used by default (animations, rounded corners, and blur). To enable zoom mode, `Super+X` stops picom and starts vcompmgr. Press `Super+Shift+X` to switch back. The `zoom-on` and `zoom-off` scripts prevent duplicate execution (`flock`) and wait for the previous compositor to exit. This matters because running both compositors at the same time can cause GTK and Qt windows to stop redrawing.

At zoom levels other than 1:1, the image becomes blurry and the cursor no longer lines up with buttons. This is a limitation of this zoom implementation, so switch back to normal mode after navigating the canvas.

## Customization

- **Monitors:** Change monitor names and refresh rates in `~/.xinitrc`. The `fcp-on` and `fcp-off` scripts also contain monitor names, so update those as well.
- **Colors and font:** Edit `vxwm/config.h`, then run `sudo make clean install` and restart vxwm. The wallpaper palette is applied using `theme`.
- **vxwm features** (infinite canvas, zoom, bar spacing, and more): Configure `vxwm/modules.h`; options use `0` and `1`.
- **Keyboard layout:** Edit the `setxkbmap` line in `.xinitrc`. The default layout toggle is Alt+Shift.
- **Terminal and launcher:** Change the `termcmd` and `dmenucmd` variables in `config.h`.

## Troubleshooting

- **The Win key does not work.** Some keyboards send Alt instead of Super (macOS or iOS mode). Switch the keyboard to Windows mode.
- **The mouse works, but the keyboard does not work in X.** `xf86-input-libinput` may be missing, or your user may not belong to the `input` group.
- **Application windows freeze until resized.** Both compositors may be running at the same time. Check with `pgrep -a "picom|vcompmgr"`.
- **vcompmgr crashes with `-u 0`.** Use a non-zero value (for example, `-u 300`).
- **Flickering during zoom on NVIDIA.** `ForceFullCompositionPipeline` may help (use the `fcp-on` script). Run `fcp-off` before gaming.
- **The screen does not wake after being idle.** Disable DPMS: `xset s off; xset s noblank; xset -dpms` (these commands are already included in the example `.xinitrc`).

## Updating

```sh
cd ~/xwmorph && git pull
```

Then copy the updated files as described in step 2 and rebuild vxwm as described in step 3.

## License

Files in `vxwm/` are distributed under their original licenses (`vxwm/LICENSE`, `vxwm/LICENSE.dwm`).
