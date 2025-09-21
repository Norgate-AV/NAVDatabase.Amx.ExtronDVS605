PROGRAM_NAME='LibExtronDVS605'

(***********************************************************)
#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ArrayUtils.axi'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


#IF_NOT_DEFINED __LIB_EXTRONDVS605__
#DEFINE __LIB_EXTRONDVS605__ 'LibExtronDVS605'


DEFINE_CONSTANT

constant integer IP_PORT = NAV_TELNET_PORT

constant integer MAX_LEVELS = 3

constant char LEVEL_COMMANDS[][NAV_MAX_CHARS]   =   {
                                                        '!',
                                                        '&',
                                                        '$'
                                                    }

constant integer MAX_VOLUME = 100
constant integer MIN_VOLUME = 0

constant char OUTPUT_RATES[][NAV_MAX_CHARS]	=   {
                                                    '640x480/50',
                                                    '640x480/60',
                                                    '640x480/75',
                                                    '800x600/50',
                                                    '800x600/60',
                                                    '800x600/75',
                                                    '852x480/50',
                                                    '852x480/60',
                                                    '852x480/75',
                                                    '1024x768/50',
                                                    '1024x768/60',
                                                    '1024x768/75',
                                                    '1024x852/50',
                                                    '1024x852/60',
                                                    '1024x852/75',
                                                    '1024x1024/50',
                                                    '1024x1024/60',
                                                    '1024x1024/75',
                                                    '1280x768/50',
                                                    '1280x768/60',
                                                    '1280x768/75',
                                                    '1280x800/50',
                                                    '1280x800/60',
                                                    '1280x800/75',
                                                    '1280x1024/50',
                                                    '1280x1024/60',
                                                    '1280x1024/75',
                                                    '1360x765/50',
                                                    '1360x765/60',
                                                    '1360x765/75',
                                                    '1360x768/50',
                                                    '1360x768/60',
                                                    '1360x768/75',
                                                    '1365x768/50',
                                                    '1365x768/60',
                                                    '1365x768/75',
                                                    '1366x768/50',
                                                    '1366x768/60',
                                                    '1366x768/75',
                                                    '1365x1024/50',
                                                    '1365x1024/60',
                                                    '1365x1024/75',
                                                    '1440x900/50',
                                                    '1440x900/60',
                                                    '1440x900/75',
                                                    '1400x1050/50',
                                                    '1400x1050/60',
                                                    '1600x900/50',
                                                    '1600x900/60',
                                                    '1680x1050/50',
                                                    '1680x1050/60',
                                                    '1600x1200/50',
                                                    '1600x1200/60',
                                                    '1920x1200/50',
                                                    '1920x1200/60',
                                                    '480p/59.94',
                                                    '480p/60',
                                                    '576p/50',
                                                    '720p/25',
                                                    '720p/29.97',
                                                    '720p/30',
                                                    '720p/50',
                                                    '720p/59.94',
                                                    '720p/60',
                                                    '1080i/50',
                                                    '1080i/59.94',
                                                    '1080i/60',
                                                    '1080p/23.98',
                                                    '1080p/24',
                                                    '1080p/25',
                                                    '1080p/29.97',
                                                    '1080p/30',
                                                    '1080p/50',
                                                    '1080p/59.94',
                                                    '1080p/60',
                                                    '2048x1080/23.98',
                                                    '2048x1080/24',
                                                    '2048x1080/25',
                                                    '2048x1080/29.97',
                                                    '2048x1080/30',
                                                    '2048x1080/50',
                                                    '2048x1080/59.94',
                                                    '2048x1080/60'
                                                }

constant integer OUTPUT_RATE_MAP[]  =   {
                                            10,
                                            11,
                                            12,
                                            13,
                                            14,
                                            15,
                                            16,
                                            17,
                                            18,
                                            19,
                                            20,
                                            21,
                                            22,
                                            23,
                                            24,
                                            25,
                                            26,
                                            27,
                                            28,
                                            29,
                                            30,
                                            31,
                                            32,
                                            33,
                                            34,
                                            35,
                                            36,
                                            37,
                                            38,
                                            39,
                                            40,
                                            41,
                                            42,
                                            43,
                                            44,
                                            45,
                                            46,
                                            47,
                                            48,
                                            49,
                                            50,
                                            51,
                                            52,
                                            53,
                                            54,
                                            55,
                                            56,
                                            57,
                                            58,
                                            59,
                                            60,
                                            61,
                                            62,
                                            63,
                                            64,
                                            65,
                                            66,
                                            67,
                                            68,
                                            69,
                                            70,
                                            71,
                                            72,
                                            73,
                                            74,
                                            75,
                                            76,
                                            77,
                                            78,
                                            79,
                                            80,
                                            81,
                                            82,
                                            83,
                                            84,
                                            85,
                                            86,
                                            87,
                                            88,
                                            89,
                                            90,
                                            91,
                                            92
                                        }


define_function char[NAV_MAX_BUFFER] BuildSwitch(integer input, integer level) {
    return "itoa(input), LEVEL_COMMANDS[level]"
}


define_function char[NAV_MAX_BUFFER] BuildVolume(integer volume) {
    return "itoa(volume), 'V'"
}


define_function char[NAV_MAX_BUFFER] BuildMute(integer state) {
    return "itoa(state), 'Z'"
}


define_function char[NAV_MAX_BUFFER] BuildPreset(integer preset) {
    return "'3*', itoa(preset), '.'"
}


define_function char[NAV_MAX_BUFFER] BuildPipSwitch(integer input) {
    return "NAV_ESC, itoa(input), 'PIP', NAV_CR"
}


define_function char[NAV_MAX_BUFFER] BuildOutputRate(char rate[]) {
    stack_var integer rateIndex

    rateIndex = NAVFindInArrayString(OUTPUT_RATES, rate)

    return "NAV_ESC, itoa(OUTPUT_RATE_MAP[rateIndex]), 'RATE', NAV_CR"
}


#END_IF // __LIB_EXTRONDVS605__
