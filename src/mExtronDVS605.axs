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
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.TimelineUtils.axi'
#include 'LibExtronDVS605.axi'

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

constant char DELIMITER[] = { $0D, $0A }

constant long TL_DRIVE	= 1
constant long TL_IP_CHECK = 2
constant long TL_HEARTBEAT = 3

constant long TL_DRIVE_INTERVAL[] = { 200 }
constant long TL_IP_CHECK_INTERVAL[] = { 3000 }
constant long TL_HEARTBEAT_INTERVAL[] = { 20000 }


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer output[MAX_LEVELS]
volatile char outputPending[MAX_LEVELS]

volatile integer outputActual[MAX_LEVELS]

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

    if (dvPort.NUMBER == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_TO,
                                                dvPort,
                                                payload))
    }

    send_string dvPort, "payload"
    wait 1 module.CommandBusy = false
}


define_function Drive() {
    stack_var integer pending

    if (module.CommandBusy) {
        return
    }

    pending = SwitchPending()

    if (!pending) {
        NAVTimelineStop(TL_DRIVE)
        return
    }

    outputPending[pending] = false
    module.CommandBusy = true
    SendString(BuildSwitch(output[pending], pending))

    if (SwitchPending() > 0) {
        return
    }

    NAVTimelineStop(TL_DRIVE)
}


define_function integer SwitchPending() {
    stack_var integer x

    for (x = 1; x <= MAX_LEVELS; x++) {
        if (outputPending[x]) {
            return x
        }
    }

    return 0
}


define_function MaintainIpConnection() {
    if (module.Device.SocketConnection.IsConnected) {
        return
    }

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

    if (dvPort.NUMBER == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_PARSING_STRING_FROM,
                                                dvPort,
                                                data))
    }

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

            if (input == outputActual[level]) {
                return
            }

            outputActual[level] = input
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
    UpdateFeedback()

    wait (timeout * 10) 'TimeOut' {
        module.Device.IsCommunicating = false
        UpdateFeedback()
    }
}


define_function Reset() {
    module.Device.SocketConnection.IsConnected = false
    module.Device.IsCommunicating = false
    module.Device.IsInitialized = false
    UpdateFeedback()

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
    UpdateFeedback()
}


#IF_DEFINED USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
define_function NAVModulePropertyEventCallback(_NAVModulePropertyEvent event) {
    switch (event.Name) {
        case NAV_MODULE_PROPERTY_EVENT_IP_ADDRESS: {
            module.Device.SocketConnection.Address = NAVTrimString(event.Args[1])
            module.Device.SocketConnection.Port = IP_PORT
            NAVTimelineStart(TL_IP_CHECK, TL_IP_CHECK_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
        }
        case NAV_MODULE_PROPERTY_EVENT_PASSWORD: {
            password = NAVTrimString(event.Args[1])
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


define_function UpdateFeedback() {
    [vdvObject, NAV_IP_CONNECTED]	= (module.Device.SocketConnection.IsConnected)
    [vdvObject, DEVICE_COMMUNICATING] = (module.Device.IsCommunicating)
    [vdvObject, DATA_INITIALIZED] = (module.Device.IsInitialized)
}


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
            UpdateFeedback()
        }

        SendString("NAV_ESC, '3CV', NAV_CR")
        NAVTimelineStart(TL_HEARTBEAT,
                        TL_HEARTBEAT_INTERVAL,
                        TIMELINE_ABSOLUTE,
                        TIMELINE_REPEAT)
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

        if (data.device.number == 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_STRING_FROM,
                                                    data.device,
                                                    data.text))
        }

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

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            case NAV_MODULE_EVENT_SWITCH: {
                stack_var integer level

                level = NAVFindInArrayString(NAV_SWITCH_LEVELS, message.Parameter[3])
                if (!level) { level = NAV_SWITCH_LEVEL_ALL }

                output[level] = atoi(message.Parameter[1])
                outputPending[level] = true

                NAVTimelineStart(TL_DRIVE,
                                TL_DRIVE_INTERVAL,
                                TIMELINE_ABSOLUTE,
                                TIMELINE_REPEAT)
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


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
