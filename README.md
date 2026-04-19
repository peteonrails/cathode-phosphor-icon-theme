# Cathode Phosphor Icon Theme

A green phosphor CRT-style icon theme for GNOME, inspired by retro terminal aesthetics. Built as a derivative of Ubuntu's [Yaru](https://github.com/ubuntu/yaru) icon set.

![Preview](https://raw.githubusercontent.com/peteonrails/cathode-phosphor-icon-theme/main/preview/preview.png)

## Features

- Green phosphor monochrome treatment across all icon categories
- Scanline overlay effect for CRT authenticity
- Custom-drawn folder emblems, terminal-style desktop icon, and globe network icon
- Full coverage: places, mimetypes, actions, apps, devices, and status icons
- HiDPI (@2x) support at all sizes

## Install

Copy the theme to your local icons directory:

```bash
cp -r cathode-phosphor ~/.local/share/icons/
```

Then select "cathode-phosphor" in GNOME Tweaks or your desktop's appearance settings.

The theme inherits from `Yaru-dark` and `hicolor`, so install Yaru if you want fallback coverage for any icons not included in this set.

## Build from source

The build script transforms Yaru source icons using ImageMagick. Requires:

- [ImageMagick](https://imagemagick.org/) (v7+)
- Yaru icons installed at `/usr/share/icons/Yaru`

```bash
./build.sh
```

## Gallery

| Places | Mimetypes | Actions |
|--------|-----------|---------|
| ![Places](preview/sheet1-places.png) | ![Mimetypes](preview/sheet2-mimetypes1.png) | ![Actions](preview/sheet4-actions.png) |

## Credits

- [Yaru Icons](https://github.com/ubuntu/yaru) by Sam Hewitt, Matthieu James, and the Canonical Design Team
- [Signal Directive](https://github.com/SignalDirective) for the RobCo omarchy theme that inspired this icon set
- Bethesda Softworks, whose Fallout series inspired the CRT phosphor aesthetic

## License

Creative Commons Attribution-Share Alike 4.0 International. See [LICENSE](LICENSE).
