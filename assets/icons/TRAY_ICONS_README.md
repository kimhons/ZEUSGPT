# System Tray Icons

## Required Files

Place the following tray icon files in this directory:

### macOS
- `tray_icon_macos.png` - 22x22px PNG (for Retina displays, use 44x44px)
- Should be a monochrome icon (black with transparency)
- Template image that adapts to light/dark menu bar

### Windows/Linux
- `tray_icon.png` - 16x16px or 32x32px PNG
- Can be colored or monochrome
- Standard system tray icon format

## Design Guidelines

**macOS:**
- Use simple, monochrome design
- 22x22px base size (44x44px @2x for Retina)
- Black icon with transparent background
- Icon will automatically invert in dark mode

**Windows:**
- 16x16px or 32x32px
- Can use color
- ICO format preferred but PNG works
- Clear visibility at small size

**Linux:**
- 16x16px or 24x24px
- PNG format
- Follow freedesktop.org icon guidelines
- Should work in both light and dark themes

## Temporary Workaround

Until custom icons are added, the app will use Flutter's default tray icon or may show an error.
The tray menu functionality will still work even without custom icons.

## Creating Icons

You can use tools like:
- **Figma/Sketch** - Design vector icons
- **ImageMagick** - Convert/resize icons
- **Icon generators** - Online tools for generating tray icons

Example ImageMagick command to resize:
```bash
# For macOS
convert app_icon.png -resize 22x22 tray_icon_macos.png
convert app_icon.png -resize 44x44 tray_icon_macos@2x.png

# For Windows/Linux  
convert app_icon.png -resize 16x16 tray_icon.png
```
