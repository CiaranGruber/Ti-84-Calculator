You will need python 3.6 or higher to run the converters.
Run one of them, and follow the prompts.
Example (plaintext):
"Title? Hello World!"
"Author? BATI"

Example (markup'd):
"file to convert? test.txt"



"plaintext_converter.py" will convert any plain ".txt" file into BCEDF format ".8xp" files.

"markup_text_converter.py" will convert a specifically formatted ".txt" file into BCEDF format ".8xp" files.

NOTE: these converted programs will split into multiple programs if necessary. The ".8xp" files can be transfered directly to the calculator.


How to write "markup"'d files for BCEDF:
Backslash is the escape code.
example: \br

The markup converter WILL NOT include line breaks from the text in the output, use "\br".

First line of the file is the output prgm/file name.

Header formatting codes:
\title:Title             file title
\author:Author           file author
\char:0000000000000000   embed custom character
\sprite:010100           embed sprite character
\image:00,APPVARNM       embed image, stored externally in appvar, (argument 2) from offset. (argument 1)
\endheader               end file header, begin text body

Main document formatting codes:
\colors:0,0         set background and foreground page colors
\textcolor:0        set current text color
\textscale:1,1      set text color. Minimum 1, maximum 16.
\highlight:0        set text highlight (background) color
\horizontal         put a horizontal line (will also line break, and clear formatting)
\br                 put a line break (clear formatting)
\clear              clear formatting
\underline          toggle underline
\tab:0              tab to x position. maximum 255.
\char:0             insert custom character from header
\sprite:0           insert sprite character from header
\imageleft:0        insert left aligned image
\imageright:0       insert right aligned image
\imagecenter:0      insert center aligned image



Example is in "test.txt"

