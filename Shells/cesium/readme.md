## Cesium

Cesium is a shell for the TI-84 Plus CE / TI-83 Premium CE calculators.

![screenshot programs](https://usercontent.irccloud-cdn.com/file/6oQrOSVE/screenshot_2.png)
![screenshot apps](https://usercontent.irccloud-cdn.com/file/LY64w3ju/screenshot_1.png)

Cesium is installed by running the `CESIUM` program.
This creates an application that can accessed via the `apps` button.
<<<<<<< HEAD
The application cannot be transferred to other calculators, however the
installer can be used instead.
=======
The application cannot be transferred to other calculators, however the installer can be used instead.
>>>>>>> e7484dfd34fdc922c7c762418d4944a9c7c95ecd

A video showing off various features is available [here](https://youtu.be/hZDzV1CDN3k).

### Navigation

Cesium supports alpha search for programs.
<<<<<<< HEAD
Use any key with the green text above it to immediately switch to the programs
starting with the corresponding letter.
=======
Use any key with the green text above it to immediately switch to the programs starting with the corresponding letter.
>>>>>>> e7484dfd34fdc922c7c762418d4944a9c7c95ecd

| Combination     | Action                   |
|-----------------|--------------------------|
| `2nd` / `enter` | Run, select              |
| `alpha`         | Modify variable settings |
| `zoom`          | Edit BASIC program       |
| `y=`            | Create new BASIC program |
| `graph`         | Rename program / appvar  |
| `mode`          | Enter settings menu      |
| `arrow keys`    | Move places              |
| `green letters` | Alpha search for program |

### Shortcuts

Shortcuts are available from outside of the Cesium application.

| Combination    | Action                                                 |
|----------------|--------------------------------------------------------|
| `on` + `prgm`  | Launch Cesium Application                              |
| `on` + `stat`  | Power down with password on wake (No Default Password) |
| `on` + `graph` | Open label jumper in TI-Basic Editor                   |
| `on` + `8`     | Backup RAM from TI-OS                                  |
| `on` + `5`     | Remove latest RAM backup                               |
| `on` + `2`     | Restore RAM from latest backup                         |
<<<<<<< HEAD
| `on` + `sto->` | Activate dark mode (inverted colors)                   |

The power-on password is set via the settings menu by pressing the `sto->`
button. RAM backup is performed by copying RAM contents to flash memory, so if
you are concerned about flash wear, please moderate usage.

### USB Support

Cesium has work-in-progress support for launching and transfering files on FAT32
formatted drive.
Future additions may be added depending on reported usage and feature requets in the
issues board on GitHub.

To transfer a variable from the drive to the calculator, use the `prgm` button.
Running a program from the drive may not work as intended for many reasons, but
may primarly be one of the following:

* The program requires subprograms and/or AppVars in order to run.
  You must transfer all subprograms/AppVars to the calculator.
* The program uses an outdated compression mode for assembly and C applications.
  There is no way around this other than updating the application or transfering
  the program to the calculator.
* The program modifies itself at runtime. This only applies to rare assembly and
  C applications, and usually will never be encountered.
  Transfer the application to the calculator.


### Uninstalling

To uninstall Cesium in the event a new version is warranted, press
`2nd` + `+` + `2` + `1` and delete the Cesium application and appvar.
You can also delete the Cesium application from within Cesium.

### Building

Clone with the following:

    git clone --recurse-submodules https://github.com/mateoconlechuga/cesium.git

Download fasmg, available near the bottom of [this page](https://flatassembler.net/download.php).
Place fasmg in the project root or add it to the global path.

Build with the command:

    make -j

### Bug Reports and Feature Requests

Make a bug report [here](https://github.com/mateoconlechuga/cesium/issues).

Source code is available [here](https://github.com/mateoconlechuga/cesium).

If you encounter a bug, no matter how small, please report it.

#### Language Translations

If you would like to add support for another language, feel free to make a PR.

**French**: Created by Adrien "Adriweb" Bertrand

**Dutch**: Created by Privacy_Dragon

### Credits

© 2015 - 2021 Matt "MateoConLechuga" Waltz

Licensed under BSD 3 Clause.
=======

The power-on password is set via the settings menu by pressing the `sto->` button.
RAM backup is performed by copying RAM contents to flash memory, so if you are concerned about flash wear, please moderate usage.

### Uninstalling 

To uninstall Cesium in the event a new version is warranted, press `2nd` + `+` + `2` + `1` and delete the Cesium application and appvar.
You can also delete the Cesium application from within Cesium.

### Building

Clone with the following:

    git clone --recurse-submodules https://github.com/mateoconlechuga/cesium.git

Download fasmg, available near the bottom of [this page](https://flatassembler.net/download.php).
Place fasmg in the project root or add it to the global path.

Build with the command:

    make -j

### Bug Reports and Feature Requests

Make a bug report [here](https://github.com/mateoconlechuga/cesium/issues).

Source code is available [here](https://github.com/mateoconlechuga/cesium).

If you encounter a bug, no matter how small, please report it.

#### Language Translations

If you would like to add support for another language, feel free to make a PR.

**French**: Created by Adrien "Adriweb" Bertrand

### Credits

© 2015 - 2020 Matt "MateoConLechuga" Waltz

Licensed under BSD 3 Clause.


>>>>>>> e7484dfd34fdc922c7c762418d4944a9c7c95ecd
