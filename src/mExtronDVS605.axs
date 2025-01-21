MODULE_NAME='mExtronDVS605'	(
                                dev vdvObject,
                                dev dvPort
                            )

(***********************************************************)
#DEFINE USING_NAV_MODULE_BASE_CALLBACKS
#DEFINE USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
#DEFINE USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
#DEFINE USING_NAV_STRING_GATHER_CALLBACK
#include 'NAVFoundation.ModuleBase.axi'
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.StringUtils.axi'

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

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

constant char DELIMITER[] = "{ {NAV_CR}, {NAV_LF} }"

constant integer IP_PORT = NAV_TELNET_PORT

constant long TL_DRIVE	= 1
constant long TL_IP_CHECK = 2
constant long TL_HEARTBEAT = 3

constant integer MAX_LEVELS = 3

constant char LEVEL_COMMANDS[][NAV_MAX_CHARS]   =   {
                                                        '!',
                                                        '&',
                                                        '$'
                                                    }

constant integer MAX_VOLUME = 100
constant integer MIN_VOLUME = 0

constant integer MAX_OUTPUTS = 1
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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile long driveTick[] = { 200 }
volatile long ipCheck[] = { 3000 }
volatile long heartbeat[] = { 20000 }

volatile integer output[MAX_LEVELS][MAX_OUTPUTS]
volatile integer outputPending[MAX_LEVELS][MAX_OUTPUTS]

volatile integer outputActual[MAX_LEVELS][MAX_OUTPUTS]

volatile char lastCommand[NAV_MAX_BUFFER]

volatile _NAVStateInteger currentVolume
volatile _NAVStateInteger currentMute

volatile char password[NAV_MAX_CHARS]

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function SendString(char payload[]) {
    lastCommand = payload

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO, dvPort, payload))

    send_string dvPort, "payload"
    wait 1 module.CommandBusy = false
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

    rateIndex = NAVFindInArraySTRING(OUTPUT_RATES, rate)

    return "NAV_ESC, itoa(OUTPUT_RATE_MAP[rateIndex]), 'RATE', NAV_CR"
}


define_function Drive() {
    stack_var integer x
    stack_var integer z

    if (module.CommandBusy) {
        return
    }

    for (x = 1; x <= MAX_OUTPUTS; x++) {
        for(z = 1; z <= MAX_LEVELS; z++) {
            if (!outputPending[z][x] || module.CommandBusy) {
                continue
            }

            outputPending[z][x] = false
            module.CommandBusy = true

            SendString(BuildSwitch(output[z][x], z))
        }
    }
}


define_function MaintainIpConnection() {
    if (module.Device.SocketConnection.IsConnected) {
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'mExtronDVS605 => Attempting to open socket'")
    NAVClientSocketOpen(dvPort.PORT,
                        module.Device.SocketConnection.Address,
                        module.Device.SocketConnection.Port,
                        IP_TCP)
}


#IF_DEFINED USING_NAV_STRING_GATHER_CALLBACK
define_function NAVStringGatherCallback(_NAVStringGatherResult args) {
    stack_var char data[NAV_MAX_BUFFER]
    stack_var char delimiter[NAV_MAX_CHARS]

    data = args.Data
    delimiter = args.Delimiter

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM, dvPort, data))

    data = NAVStripRight(data, length_array(delimiter))

    select {
        active (NAVStartsWith(data, 'In')): {
            stack_var integer input
            stack_var integer level

            remove_string(data, 'In', 1)

            input = atoi(NAVStripRight(remove_string(data, ' ', 1), 1))

            switch (data) {
                case 'All': {
                    level = NAV_SWITCH_LEVEL_ALL
                }
                case 'Aud': {
                    level = NAV_SWITCH_LEVEL_AUD
                }
                case 'RGB':
                case 'Vid': {
                    level = NAV_SWITCH_LEVEL_VID
                }
            }

            if (input == outputActual[level][1]) {
                return
            }

            outputActual[level][1] = input
            NAVCommand(vdvObject, "'SWITCH-', itoa(input), ',', NAV_SWITCH_LEVELS[level]")
        }
        active (NAVStartsWith(data, 'Vol')): {
            stack_var integer volume
            stack_var sinteger scaledVolume

            remove_string(data, 'Vol', 1)

            volume = atoi(data)

            if (volume == currentVolume.Actual) {
                return
            }

            currentVolume.Actual = volume
            NAVCommand(vdvObject, "'VOLUME-ABS,', itoa(volume)")

            scaledVolume = NAVScaleValue(type_cast(volume), (MAX_VOLUME - MIN_VOLUME), 255, 0)

            NAVCommand(vdvObject, "'VOLUME-', itoa(scaledVolume)")
            send_level vdvObject, VOL_LVL, scaledVolume
        }
        active (NAVStartsWith(data, 'Amt')): {
            stack_var integer state

            remove_string(data, 'Amt', 1)

            state = atoi(data)

            if (state == currentMute.Actual) {
                return
            }

            currentMute.Actual = state
            NAVCommand(vdvObject, "'MUTE-', itoa(state)")
        }
        active (NAVStartsWith(data, 'Vrb')): {
            if (module.Device.IsInitialized) {
                return
            }

            Init()
        }
    }
}
#END_IF


define_function CommunicationTimeOut(integer timeout) {
    cancel_wait 'TimeOut'

    module.Device.IsCommunicating = true

    wait (timeout * 10) 'TimeOut' {
        module.Device.IsCommunicating = false
    }
}


define_function Reset() {
    module.Device.SocketConnection.IsConnected = false
    module.Device.IsCommunicating = false
    module.Device.IsInitialized = false

    NAVTimelineStop(TL_HEARTBEAT)
    NAVTimelineStop(TL_DRIVE)
}


define_function Init() {
    SendString('V')
    SendString('Z')
    SendString('!')
    SendString('&')
    SendString('$')

    module.Device.IsInitialized = true
}


#IF_DEFINED USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
define_function NAVModulePropertyEventCallback(_NAVModulePropertyEvent event) {
    switch (event.Name) {
        case NAV_MODULE_PROPERTY_EVENT_IP_ADDRESS: {
            NAVErrorLog(NAV_LOG_LEVEL_INFO, "'mExtronDVS605 => IP Address: ', event.Args[1]")
            module.Device.SocketConnection.Address = event.Args[1]
            module.Device.SocketConnection.Port = IP_PORT
            NAVTimelineStart(TL_IP_CHECK, ipCheck, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
        }
        case NAV_MODULE_PROPERTY_EVENT_PASSWORD: {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'mExtronDVS605 => Password: ', event.Args[1]")
            password = event.Args[1]
        }
    }
}
#END_IF


#IF_DEFINED USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
define_function NAVModulePassthruEventCallback(_NAVModulePassthruEvent event) {
    if (event.Device != vdvObject) {
        return
    }

    SendString(event.Payload)
}
#END_IF


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    create_buffer dvPort, module.RxBuffer.Data
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvPort] {
    online: {
        if (data.device.number != 0) {
            NAVCommand(data.device, "'SET BAUD 9600,N,8,1 485 DISABLE'")
            NAVCommand(data.device, "'B9MOFF'")
            NAVCommand(data.device, "'CHARD-0'")
            NAVCommand(data.device, "'CHARDM-0'")
            NAVCommand(data.device, "'HSOFF'")
        }

        if (data.device.number == 0) {
            module.Device.SocketConnection.IsConnected = true
        }

        SendString("NAV_ESC, '3CV', NAV_CR")

        NAVTimelineStart(TL_DRIVE, driveTick, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
        NAVTimelineStart(TL_HEARTBEAT, heartbeat, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
    }
    offline: {
        if (data.device.number == 0) {
            NAVClientSocketClose(data.device.port)
            Reset()
        }
    }
    onerror: {
        if (data.device.number == 0) {
            Reset()
        }
    }
    string: {
        CommunicationTimeOut(30)

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM, data.device, data.text))

        select {
            active (NAVContains(module.RxBuffer.Data, "'Password:'")): {
                module.RxBuffer.Data = '';
                SendString("password, NAV_CR, NAV_LF");
            }
            active (true): {
                NAVStringGather(module.RxBuffer, "NAV_CR, NAV_LF")
            }
        }
    }
}


data_event[vdvObject] {
    command: {
        stack_var _NAVSnapiMessage message

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM, data.device, data.text))

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            case NAV_MODULE_EVENT_SWITCH: {
                stack_var integer level

                level = NAVFindInArrayString(NAV_SWITCH_LEVELS, message.Parameter[3])
                if (!level) { level = NAV_SWITCH_LEVEL_ALL }

                output[level][1] = atoi(message.Parameter[1])
                outputPending[level][1] = true
            }
            case NAV_MODULE_EVENT_VOLUME: {
                switch (message.Parameter[1]) {
                    case 'ABS': {
                        SendString(BuildVolume(atoi(message.Parameter[1])))
                    }
                    default: {
                        stack_var sinteger value

                        value = NAVScaleValue(atoi(message.Parameter[1]), 255, (MAX_VOLUME - MIN_VOLUME), 0)
                        SendString(BuildVolume(type_cast(value)))
                    }
                }
            }
            case NAV_MODULE_EVENT_MUTE: {
                SendString(BuildMute(NAVStringToBoolean(message.Parameter[1])))
            }
            case 'PRESET': {
                SendString(BuildPreset(atoi(message.Parameter[1])))
            }
            case 'PIP': {
                SendString(BuildPipSwitch(atoi(message.Parameter[1])))
            }
            case 'OUTPUT_RATE': {
                SendString(BuildOutputRate(message.Parameter[1]))
            }
        }
    }
}


channel_event[vdvObject, 0] {
    on: {
        switch (channel.channel) {
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10: {
                SendString(BuildPreset(channel.channel))
            }
        }
    }
}


timeline_event[TL_DRIVE] { Drive() }


timeline_event[TL_IP_CHECK] { MaintainIPConnection() }


timeline_event[TL_HEARTBEAT] {
    SendString("NAV_ESC, '3CV', NAV_CR")
}


timeline_event[TL_NAV_FEEDBACK] {
    [vdvObject, NAV_IP_CONNECTED]	= (module.Device.SocketConnection.IsConnected)
    [vdvObject, DEVICE_COMMUNICATING] = (module.Device.IsCommunicating)
    [vdvObject, DATA_INITIALIZED] = (module.Device.IsInitialized)
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
