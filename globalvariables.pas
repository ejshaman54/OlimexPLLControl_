unit GlobalVariables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  SwitchState = (On, Off);

var
  //Variables associated with the home-made PLL
    UsePLL    : boolean = TRUE;
    PLLUSBPortNumber    : integer = 0; //USB port number for home made PLL, of the form /dev/ttyUSB0, etc
    //PLLUSBDeviceName    : string  = 'DDSPLL'; //This is the persistent device identifier for the DDSPLL, i.e., /dev/DDSPLL
    PLLUSBDeviceName    : string  = '/dev/ttyS5';
    //PLLUSBDeviceName    : string  = '/tmp/serial';
    PLLCenterFrequency  : real = 32768; //Center frequency of PLL
    PLLMode             : boolean = FALSE; //PLL Mode vs Fixed Frequency Mode
    FreqConversionFactor  : real = 1; //for the PLL...Hz/ Volt of output
    AmpPID              : boolean = FALSE; // whether the amplitude PID is on or not.

    OutputFrequency,
    StartFrequency,
    StopFrequency,
    FrequencyStep,
    FrequencyMod,          //frequency modulation amplitude
    ModPeriod              // frequency modulation period
                           : real;

    FrequencyAverages,
    NumbSteps              : integer;
    FrequencySweep,
    FrequencyModOn,
    ModDirectionUp         : boolean;


    FreqPropCoeff,
    FreqIntTime,
    FreqDiffTime,
    PhaseOffset,
    MeasuredPhase,

    RealAmplitude,
    AmpPropCoeff,
    AmpIntTime,
    AmpDiffTime,
    AmpSetPoint             : real;

    QControl,
    SelfExcitation          : SwitchState;


implementation

end.

