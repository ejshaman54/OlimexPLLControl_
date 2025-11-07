unit PLLFunctions;

{$mode delphi}

interface
  uses
     Classes, SysUtils, Synaser;

  var
     PLLSerial         : TBlockSerial;

   procedure InitializePLLSerial;
   procedure FreePLLSerial;
   procedure StartPLLMode;
   procedure EndPLLMode;
   procedure StartAmplitudePid;
   procedure StopAmplitudePid;
   function SendPLLConvFactor(ConversionFactor: real): boolean;
   function SetPLLFrequency(DesiredFrequency: real): boolean;
   function ReadPLLAmplitude: real;
   function ReadPLLPhase: real;
   function ReadFrequency: real;
   procedure SetFreqPropCoeff;
   procedure SetFreqIntTime;
   procedure SetFreqDiffTime;
   procedure SetAmpPropCoeff;
   procedure SetAmpIntTime;
   procedure SetAmpDiffTime;
   procedure SetPhaseOffset;
   procedure SetAmplitudeSetPoint;
   procedure EnableQControl;
   procedure DisableQControl;
   procedure EnableSelfExcitation;
   procedure DisableSelfExcitation;



implementation
uses
    GlobalVariables, GlobalFunctions,
   SdpoSerial;

const
    MasterClockFrequency = 1E6; //1 MHz clock frequency
    PLLUSBDelay          = 40; //delay in msec for PLL USB communication
    FreqScale           = $FFFFFFFF/MasterClockFrequency; //2^32 bit resolution with 1 MHz clock
var

    FrequencyDWORD   : dword;  //32 bit form of word
    FrequencyHiWord  : Word;
    FrequencyLoWord  : Word;
    TempString       : string;

    function WordToStr(Number: Word): string;
    begin
      result:=Chr(Hi(Number))+ Chr(Lo(Number));
    end;

    function FreqFloatToDWord(Freq : real): dword;
    begin
      result:=round((Freq/MasterClockFrequency)*(2 shl 32));
    end;

procedure InitializePLLSerial;
var
  s : string;
begin
  //Set the Com Port
  PLLSerial:=TBlockSerial.Create;
  try
    PLLSerial.RaiseExcept := False;
    PLLSerial.LinuxLock := False;
    //PLLSerial.Connect('/dev/'+PLLUSBDeviceName);
    PLLSerial.Connect(PLLUSBDeviceName);
    PLLSerial.Config(38400, 8, 'N', 1, FALSE, FALSE);
    s := PLLSerial.LastErrorDesc;
  except
    FreeAndNil(PLLSerial);
  end;
end;
procedure FreePLLSerial;
begin
  if PLLSerial<>nil then
   begin
     PLLSerial.Purge;
     FreeAndNil(PLLSerial);
   end;
end;

procedure StartPLLMode;
begin
  PLLMode:=TRUE;
  PLLSerial.SendString('BP;');
  delay(PLLUSBDelay);
end;

procedure EndPLLMode;
begin
  PLLMode:=FALSE;
  PLLSerial.SendString('EP;');
  delay(PLLUSBDelay);
end;

procedure StartAmplitudePID;
begin
  PLLSerial.SendString('BA;');
  delay(PLLUSBDelay);
end;

procedure StopAmplitudePID;
begin
  PLLSerial.SendString('EA;');
  delay(PLLUSBDelay);
end;

function SendPLLConvFactor(ConversionFactor: real): boolean;
var
      OutputString: string;

begin
    SendPLLConvFactor:=FALSE;
    if ConversionFactor>65535 then FreqConversionFactor:=65535;
    if ConversionFactor<=0 then FreqConversionFactor:=0.001;
    OutputString:=IntToStr(round(FreqConversionFactor*1000)); //Need to convert to mHz/Volt

    //Now write to the serial port
    PLLSerial.SendString('CF;');
    delay(PLLUSBDelay);
    PLLSerial.SendString(OutputString+';');
    delay(PLLUSBDelay);
    SendPLLConvFactor:=TRUE;
end;

function SetPLLFrequency(DesiredFrequency: real): boolean;
var
    HiString, LowString: string;

begin
  SetPLLFrequency:=FALSE;
  FrequencyDWord:=round(DesiredFrequency*1000);
  //FrequencyDWord:=DWord(round(DesiredFrequency*FreqScale));
  FrequencyHiWord:=Hi(FrequencyDWord);
  FrequencyLoWord:=Lo(FrequencyDWord);

  HiString:=IntToStr(FrequencyHiWord);
  LowString:=IntToStr(FrequencyLoWord);

  //Now write to the serial port
  PLLSerial.SendString('FR;');
  //delay(PLLUSBDelay);
  PLLSerial.SendString(HiString+';');
  //delay(PLLUSBDelay);
  PLLSerial.SendString(LowString+';');
  //delay(PLLUSBDelay);
  SetPLLFrequency:=TRUE;
end;

function ReadPLLAmplitude: real;
var
    Value: real;
begin
  try
    PLLSerial.SendString('A?;');
    //while not PLLSerial.CanRead(30) do;
    TempString:= PLLSerial.RecvString(10);
    if TempString = '' then  Value:=0
     else  Value:=StrToFloat(TempString);
    //for some reason, the Olimex program is giving twice the amplitude, so we
    //correct for it here.
    ReadPLLAmplitude:=Value;
  finally
  end;
end;

function ReadPLLPhase: real;
var
    Value: real;
begin
  PLLSerial.SendString('P?;');
  //while not PLLSerial.CanRead(30) do;
  TempString:= PLLSerial.RecvString(10);
  if TempString = '' then Value:=0
   else Value:=StrToFloat(TempString);
  ReadPLLPhase:=Value;
end;

function ReadFrequency: real;
var
    Value : real;
begin
  PLLSerial.SendString('F?;');
  //while not PLLSerial.CanRead(30) do;
  TempString:= PLLSerial.RecvString(10);
  if TempString = '' then Value:=0
   else Value:=StrToDWord(TempString)/FreqScale;
  ReadFrequency:=Value;
end;

procedure SetFreqPropCoeff;
var
  Value : word;
  OutputString: string;
begin
  //Need to translate to a word format.  Multiply by 1000 to give enough
  //precision, then typecast to word
  Value := word(round(FreqPropCoeff*1000));
  OutputString:=IntToStr(Value);
  PLLSerial.SendString('FP;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(OutputString + ';');
  delay(PLLUSBDelay);
end;

procedure SetFreqIntTime;
var
  Value: dword;
  HiString, LowString: string;
begin
  Value:=dword(round(FreqIntTime*1000)); //convert to dword in microseconds
  HiString:=IntToStr(Hi(Value));
  LowString:=IntToStr(Lo(Value));
  PLLSerial.SendString('FI;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(HiString + ';');
  delay(PLLUSBDelay);
  PLLSerial.SendString(LowString + ';');
  delay(PLLUSBDelay);
end;

procedure SetFreqDiffTime;
var
  Value: dword;
  HiString, LowString: string;
begin
  Value:=dword(round(FreqDiffTime*1000)); //convert to dword in microseconds
  HiString:=IntToStr(Hi(Value));
  LowString:=IntToStr(Lo(Value));
  PLLSerial.SendString('FD;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(HiString + ';');
  delay(PLLUSBDelay);
  PLLSerial.SendString(LowString + ';');
  delay(PLLUSBDelay);
end;
procedure SetAmpPropCoeff;
var
  Value : word;
  OutputString: string;
begin
  //Need to translate to a word format.  Multiply by 1000 to give enough
  //precision, then typecast to word
  Value := word(round(AmpPropCoeff*1000));
  OutputString:=IntToStr(Value);
  PLLSerial.SendString('AP;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(OutputString + ';');
  delay(PLLUSBDelay);
end;
procedure SetAmpIntTime;
var
  Value: dword;
  HiString, LowString: string;
begin
  Value:=dword(round(AmpIntTime*1000)); //convert to dword in microseconds
  HiString:=IntToStr(Hi(Value));
  LowString:=IntToStr(Lo(Value));
  PLLSerial.SendString('AI;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(HiString + ';');
  delay(PLLUSBDelay);
  PLLSerial.SendString(LowString + ';');
  delay(PLLUSBDelay);
end;
procedure SetAmpDiffTime;
var
  Value: dword;
  HiString, LowString: string;
begin
  Value:=dword(round(AmpDiffTime*1000)); //convert to dword in microseconds
  HiString:=IntToStr(Hi(Value));
  LowString:=IntToStr(Lo(Value));
  PLLSerial.SendString('AD;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(HiString + ';');
  delay(PLLUSBDelay);
  PLLSerial.SendString(LowString + ';');
  delay(PLLUSBDelay);
end;

procedure SetPhaseOffset;
var
  Value: word;
  OutputString: string;
begin
  //Need to translate to a word format.  Multiply by 100 to give enough
  //precision in tens of millidegrees, then typecast to word
  Value := word(round(PhaseOffset*100));
  OutputString:=IntToStr(Value);
  PLLSerial.SendString('PO;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(OutputString + ';');
  delay(PLLUSBDelay);
end;

procedure SetAmplitudeSetPoint;
var
  Value: word;
  OutputString: string;
begin
  Value := word(round(AmpSetPoint*1000));
  OutputString:=IntToStr(Value);
  PLLSerial.SendString('AM;');
  delay(PLLUSBDelay);
  PLLSerial.SendString(OutputString + ';');
  delay(PLLUSBDelay);
end;

procedure EnableQControl;
begin
  PLLSerial.SendString('BQ;');
  delay(PLLUSBDelay);
end;

procedure DisableQControl;
begin
  PLLSerial.SendString('EQ;');
  delay(PLLUSBDelay);
end;

procedure EnableSelfExcitation;
begin
  PLLSerial.SendString('BS;');
  delay(PLLUSBDelay);
end;

procedure DisableSelfExcitation;
begin
  PLLSerial.SendString('ES;');
  delay(PLLUSBDelay);
end;
end.

