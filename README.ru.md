# xwmorph

[English version](README.md)

готовая сборка рабочего стола на **vxwm** (X11): бесконечный плавающий холст, два монитора, палитра из обоев (pywal), композитор picom с анимациями и режим зума через vcompmgr.

> тестировалось на Gentoo (systemd) с NVIDIA. на других дистрибутивах названия пакетов отличаются, но шаги те же.

## автор

<!-- TODO: впишите себя -->
_Автор сборки: (hauntstep)_

основа: [vxwm](https://codeberg.org/wh1tepearl/vxwm) от wh1tepearl, форк dwm. исходники лежат в `vxwm/` вместе с оригинальными файлами `LICENSE` и `LICENSE.dwm`. зум работает на [vcompmgr](https://codeberg.org/wh1tepearl/vcompmgr).

## что внутри

```
vxwm/                исходники vxwm с моим config.h и modules.h
.config/kitty/       терминал
.config/picom/       композитор (скругления, блюр, анимации)
.config/rofi/        лаунчер и его тема
.config/fish/        конфиг оболочки fish
.local/bin/
  theme              смена обоев и палитры одной командой
  zoom-on, zoom-off  переключение picom и vcompmgr для зума
  barstatus          часы в баре vxwm
  fcp-on, fcp-off    ForceFullCompositionPipeline (только NVIDIA)
```

что изменено в vxwm относительно оригинала: время в баре показывается на всех мониторах сразу, название активного окна из бара убрано.

## быстрая установка

```
git clone https://github.com/hauntstep/xwmorph.git ~/xwmorph
cd ~/xwmorph
./install.sh
``` (скоро будет, еще не доработано.)

## ручная установка

### 1.зависимости (Gentoo)

```
sudo emerge --ask x11-base/xorg-server x11-apps/xinit x11-apps/xrandr \
  x11-apps/xsetroot x11-apps/xset x11-apps/setxkbmap \
  x11-libs/libXft x11-libs/libXinerama \
  x11-misc/picom x11-misc/rofi x11-misc/feh x11-terms/kitty \
  xfce-base/thunar media-gfx/sxiv media-gfx/maim x11-misc/xclip \
  media-gfx/imagemagick media-fonts/jetbrains-mono dev-vcs/git
```

для NVIDIA дополнительно: `x11-drivers/nvidia-drivers` и `x11-misc/nvidia-settings`. для ввода нужен `x11-drivers/xf86-input-libinput` (без него клавиатура и мышь в X не работают). пользователь должен быть в группах `video` и `input`.

### 2. клонирование и конфиги

```
git clone https://github.com/hauntstep/xwmorph.git ~/xwmorph
mkdir -p ~/.config ~/.local/bin
cp -r ~/xwmorph/.config/. ~/.config/
cp ~/xwmorph/.local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*
```

папка `~/.local/bin` должна быть в `PATH` (в fish: `fish_add_path ~/.local/bin`).

### 3. сборка vxwm

```
cp -r ~/xwmorph/vxwm ~/vxwm
cd ~/vxwm
make
sudo make clean install
```

в репозитории лежит готовый `config.h`, `make` его не перезапишет.

### 4. зум (vcompmgr)

```
git clone https://codeberg.org/wh1tepearl/vcompmgr.git ~/vcompmgr
cd ~/vcompmgr
make
sudo make install
```

нужны `libXcomposite`, `libXdamage`, `libXfixes`, `libXrender`, `libXext` и `libdrm`. проект экспериментальный: на NVIDIA здесь работает, но без гарантий. Без него всё остальное работает, просто зума не будет.

### 5. палитра из обоев (pywal)

```
python -m venv ~/.venvs/wal
~/.venvs/wal/bin/pip install pywal16 haishoku
ln -sf ~/.venvs/wal/bin/wal ~/.local/bin/wal
```

положите обои в `~/Wallpapers` и примените тему:

```
theme ~/Wallpapers/ваша_картинка.jpg
```

после этого нажмите **Super+F5**, чтобы бар и рамки подхватили новые цвета.

### 6. файл ~/.xinitrc

создайте его сами и **замените имена мониторов** на свои (`xrandr` покажет их внутри X):

```
export PATH="$HOME/.local/bin:$PATH"
xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary --pos 0x0 \
       --output DP-2 --mode 2560x1440 --rate 144 --pos 2560x0
setxkbmap -layout us,ru -option grp:alt_shift_toggle
xset s off
xset s noblank
xset -dpms
wal -R -n
xrdb -merge ~/.cache/wal/colors.Xresources
feh --bg-fill ~/Wallpapers/ваша_картинка.jpg &
picom -b
barstatus &
exec vxwm
```

### 7. запуск

из обычной консоли (не из SSH):

```
startx
```

## горячие клавиши

`Super` это клавиша Win. полный список лежит в `vxwm/config.h`.

| сочетание | действие |
|---|---|
| Super+Shift+Enter | терминал (kitty) |
| Super+P | лаунчер (rofi) |
| Super+E | файловый менеджер (Thunar) |
| Super+V | просмотр скриншотов (sxiv) |
| Super+Shift+S | скриншот области в буфер обмена |
| Super+Ctrl+S | скриншот области в файл `~/screenshots` |
| Super+Shift+C | закрыть окно |
| Super+Shift+Q | выйти из vxwm |
| Super+F5 | перечитать цвета (после `theme`) |
| Super+R | вернуться в точку 0,0 на холсте |
| Super+Shift+стрелки | двигать холст |
| ЛКМ по пустому месту, затем перетаскивание | двигать холст мышью |
| Super+X, Super+Shift+X | режим зума включить, выключить |
| Super+колесо (в режиме зума) | приблизить, отдалить |

создайте папку для скриншотов: `mkdir -p ~/screenshots`.

## зум

по умолчанию работает **picom** (анимации, скругления, блюр). для зума `Super+X` останавливает picom и запускает vcompmgr, а `Super+Shift+X` возвращает всё обратно. скрипты `zoom-on` и `zoom-off` защищены от повторного запуска (`flock`) и дожидаются выхода старого композитора. это важно: если запускать оба композитора вперемешку, окна GTK и Qt перестают перерисовываться.

при масштабе не равном 1 картинка размыта, а курсор не совпадает с кнопками. это особенность такого зума: после обзора холста возвращайтесь в обычный режим.

## настройка под себя

- **мониторы:** имена и частоту правьте в `~/.xinitrc`. Скрипты `fcp-on` и `fcp-off` тоже содержат имена мониторов, замените и их.
- **цвета и шрифт:** `vxwm/config.h` (после правки `sudo make clean install` и перезапуск). палитра из обоев применяется через `theme`.
- **возможности vxwm** (бесконечный холст, зум, отступы бара и другое): `vxwm/modules.h`, значения `0` и `1`.
- **раскладка:** строка `setxkbmap` в `.xinitrc`, по умолчанию переключение по Alt+Shift.
- **терминал и лаунчер:** переменные `termcmd` и `dmenucmd` в `config.h`.

## частые проблемы

- **клавиша Win не срабатывает.** некоторые клавиатуры шлют Alt вместо Super (режим macOS или iOS). переключите клавиатуру в режим Windows.
- **мышь работает, клавиатура в X нет.** не установлен `xf86-input-libinput` или пользователь не в группе `input`.
- **окна приложений зависают, пока не изменить размер.** работают сразу два композитора. проверьте `pgrep -a "picom|vcompmgr"`.
- **vcompmgr падает с `-u 0`.** используйте ненулевое значение (например, `-u 300`).
- **мерцание при зуме на NVIDIA.** помогает `ForceFullCompositionPipeline` (скрипт `fcp-on`). перед играми включайте `fcp-off`.
- **экран не просыпается после простоя.** отключите DPMS: `xset s off; xset s noblank; xset -dpms` (уже есть в примере `.xinitrc`).

## обновление

```
cd ~/xwmorph && git pull
```

затем скопируйте обновлённые файлы так же, как в шаге 2, и пересоберите vxwm (шаг 3).

## лицензия

файлы в `vxwm/` распространяются на условиях оригинальных лицензий (`vxwm/LICENSE`, `vxwm/LICENSE.dwm`).
