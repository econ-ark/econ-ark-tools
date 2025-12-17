#!/bin/bash
# Generate PoweredByEconARK badge in multiple formats (PNG, JPG, PDF, SVG, XBB)
# This script creates all badge formats directly without external conversion tools

# Change to script's directory so files are created in the correct location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

python3 << 'PYTHON'
from PIL import Image, ImageDraw, ImageFont
import os

# Badge dimensions - 20px height for consistency with standard badges
WIDTH, HEIGHT = 105, 20
LEFT_WIDTH = 52  # Approximate split point

# Colors - corrected dark grey background
# Left section: dark grey background, light grey text
LEFT_BG = (77, 77, 77)  # Dark grey #4D4D4D
LEFT_TEXT = (204, 204, 204)  # Light grey #CCCCCC

# Right section: teal-blue background, bright light blue text  
RIGHT_BG = (50, 150, 190)  # Teal-blue #3296BE
RIGHT_TEXT = (200, 240, 255)  # Bright light blue #C8F0FF

# Create image
img = Image.new('RGB', (WIDTH, HEIGHT))
draw = ImageDraw.Draw(img)

# Draw left section background (dark grey)
draw.rectangle([(0, 0), (LEFT_WIDTH, HEIGHT)], fill=LEFT_BG)

# Draw right section background (teal-blue)
draw.rectangle([(LEFT_WIDTH, 0), (WIDTH, HEIGHT)], fill=RIGHT_BG)

# Try to use a system font
try:
    font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 12)
except:
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 12)
    except:
        font = ImageFont.load_default()

# Draw text "Powered by" (left, light grey on dark grey)
text_left = "Powered by"
bbox_left = draw.textbbox((0, 0), text_left, font=font)
text_width_left = bbox_left[2] - bbox_left[0]
text_height_left = bbox_left[3] - bbox_left[1]
x_left = (LEFT_WIDTH - text_width_left) // 2
y_left = (HEIGHT - text_height_left) // 2 - 1  # Slight adjustment for centering
draw.text((x_left, y_left), text_left, fill=LEFT_TEXT, font=font)

# Draw text "Econ-ARK" (right, bright light blue on teal-blue)
text_right = "Econ-ARK"
bbox_right = draw.textbbox((0, 0), text_right, font=font)
text_width_right = bbox_right[2] - bbox_right[0]
x_right = LEFT_WIDTH + (WIDTH - LEFT_WIDTH - text_width_right) // 2
y_right = (HEIGHT - text_height_left) // 2 - 1  # Same vertical alignment
draw.text((x_right, y_right), text_right, fill=RIGHT_TEXT, font=font)

# Save as PNG
img.save('PoweredByEconARK.png', 'PNG')
print("✅ PNG created (105x20px)")

# Save as JPG
img.save('PoweredByEconARK.jpg', 'JPEG', quality=95)
print("✅ JPG created (105x20px)")

# Save as PDF (PIL can save directly to PDF)
img.save('PoweredByEconARK.pdf', 'PDF')
print("✅ PDF created (105x20px)")

# Generate XBB file with dimensions
with open('PoweredByEconARK.xbb', 'w') as f:
    f.write(f"""%%Title: PoweredByEconARK.png
%%Creator: extractbb (manual generation)
%%BoundingBox: 0 0 {WIDTH} {HEIGHT}
%%HiResBoundingBox: 0.000000 0.000000 {WIDTH}.000000 {HEIGHT}.000000
""")
print("✅ XBB created (105x20px)")

# Generate SVG version (vector format for best quality)
def rgb_to_hex(rgb):
    return f"#{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}"

svg_content = f"""<svg width="{WIDTH}" height="{HEIGHT}" xmlns="http://www.w3.org/2000/svg">
  <!-- Left section background -->
  <rect width="{LEFT_WIDTH}" height="{HEIGHT}" fill="{rgb_to_hex(LEFT_BG)}"/>
  
  <!-- Right section background -->
  <rect x="{LEFT_WIDTH}" width="{WIDTH - LEFT_WIDTH}" height="{HEIGHT}" fill="{rgb_to_hex(RIGHT_BG)}"/>
  
  <!-- Left text: "Powered by" -->
  <text x="{x_left}" y="{y_left + text_height_left - 2}" 
        font-family="Arial, Helvetica, sans-serif" 
        font-size="12" 
        fill="{rgb_to_hex(LEFT_TEXT)}"
        text-anchor="start">{text_left}</text>
  
  <!-- Right text: "Econ-ARK" -->
  <text x="{x_right}" y="{y_right + text_height_left - 2}" 
        font-family="Arial, Helvetica, sans-serif" 
        font-size="12" 
        fill="{rgb_to_hex(RIGHT_TEXT)}"
        text-anchor="start">{text_right}</text>
</svg>"""

with open('PoweredByEconARK.svg', 'w') as f:
    f.write(svg_content)
print("✅ SVG created (vector, scalable)")

print(f"\nAll files created with size: {WIDTH}x{HEIGHT}")
print(f"Colors: Left BG={LEFT_BG}, Left Text={LEFT_TEXT}, Right BG={RIGHT_BG}, Right Text={RIGHT_TEXT}")
PYTHON
