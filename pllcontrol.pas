unit PLLControl;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TATransformations, TATools,
  LResources, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Spin,
  Menus, Types;

type

  { TPLLForm }

  TPLLForm = class(TForm)
    AmplitudeCheckBox: TCheckBox;
    AmpDiffEdit: TLabeledEdit;
    AmpIntEdit: TLabeledEdit;
    AmpPIDCheckBox: TCheckBox;
    PhaseOffsetEdit: TLabeledEdit;
    SelfExcitationCheckBox: TCheckBox;
    QControlCheckBox: TCheckBox;
    FreqModControlButton: TButton;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointCrosshairTool1: TDataPointCrosshairTool;
    ChartToolset1PanDragTool1: TPanDragTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    CoordLabel: TLabel;
    AmpPropEdit: TLabeledEdit;
    FrequencyModulationGroupBox: TGroupBox;
    FrequencyModEdit: TLabeledEdit;
    FreqPIDGroupBox: TGroupBox;
    FreqPropEdit: TLabeledEdit;
    FreqIntEdit: TLabeledEdit;
    FreqDiffEdit: TLabeledEdit;
    AmpPIDGroupBox: TGroupBox;
    AmplitudeSetPointEdit: TLabeledEdit;
    AmplitudeLabel: TLabel;
    FrequencyLabel: TLabel;
    PhaseLabel: TLabel;
    ModPeriodEdit: TLabeledEdit;
    LeftAxisTransformation: TChartAxisTransformations;
    LeftAxisTransformationAutoScaleAxisTransform1: TAutoScaleAxisTransform;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    Panel1: TPanel;
    SaveCurves: TMenuItem;
    RightAxisTransformation: TChartAxisTransformations;
    FrequencySweepButton: TButton;
    FrequencyAveragesSpinEdit: TSpinEdit;
    Label1: TLabel;
    CurrentFrequencyLabel: TLabel;
    ConvFactorEdit: TLabeledEdit;
    RightAxisTransformationAutoScaleAxisTransform1: TAutoScaleAxisTransform;
    SaveDialog: TSaveDialog;
    StartFrequencyEdit: TLabeledEdit;
    CenterFrequencyEdit: TLabeledEdit;
    StopFrequencyEdit: TLabeledEdit;
    PhaseCheckBox: TCheckBox;
    PLLChart: TChart;
    FrequencyScanGroupBox: TGroupBox;
    PLLAmpLineSeries: TLineSeries;
    PLLPhaseLineSeries: TLineSeries;
    PLLModeRadioGroup: TRadioGroup;
    FrequencyStepEdit: TLabeledEdit;
    FreqModTimer: TTimer;
    DataTimer: TTimer;
    procedure AmpDiffEditKeyPress(Sender: TObject; var Key: char);
    procedure AmpIntEditKeyPress(Sender: TObject; var Key: char);
    procedure AmplitudeCheckBoxClick(Sender: TObject);
    procedure AmplitudeSetPointEditKeyPress(Sender: TObject; var Key: char);
    procedure AmpPIDCheckBoxClick(Sender: TObject);
    procedure AmpPropEditKeyPress(Sender: TObject; var Key: char);
    procedure CenterFrequencyEditKeyPress(Sender: TObject; var Key: char);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1DataPointCrosshairTool1AfterMouseDown(
      ATool: TChartTool; APoint: TPoint);
    procedure ChartToolset1DataPointCrosshairTool1AfterMouseWheelDown(
      ATool: TChartTool; APoint: TPoint);
    procedure ConvFactorEditKeyPress(Sender: TObject; var Key: char);
    procedure DataTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FreqDiffEditKeyPress(Sender: TObject; var Key: char);
    procedure FreqIntEditKeyPress(Sender: TObject; var Key: char);
    procedure FreqModControlButtonClick(Sender: TObject);
    procedure FreqModTimerStartTimer(Sender: TObject);
    procedure FreqModTimerStopTimer(Sender: TObject);
    procedure FreqModTimerTimer(Sender: TObject);
    procedure FreqPropEditKeyPress(Sender: TObject; var Key: char);
    procedure FrequencyAveragesSpinEditChange(Sender: TObject);
    procedure FrequencyModEditKeyPress(Sender: TObject; var Key: char);
    procedure FrequencyStepEditKeyPress(Sender: TObject; var Key: char);
    procedure FrequencySweepButtonClick(Sender: TObject);
    procedure ModPeriodEditKeyPress(Sender: TObject; var Key: char);
    procedure PhaseCheckBoxClick(Sender: TObject);
    procedure PhaseOffsetEditKeyPress(Sender: TObject; var Key: char);
    procedure PLLModeRadioGroupClick(Sender: TObject);
    procedure QControlCheckBoxClick(Sender: TObject);
    procedure SaveCurvesClick(Sender: TObject);
    procedure SelfExcitationCheckBoxClick(Sender: TObject);
    procedure StartFrequencyEditKeyPress(Sender: TObject; var Key: char);
    procedure StopFrequencyEditKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  PLLForm: TPLLForm;

implementation

{ TPLLForm }
uses
    GlobalVariables,
    PLLFunctions;

type
  AmpPhaseDataPoint  = array[0..2] of real;

var
  AmpPhaseData           : array of AmpPhaseDataPoint;
  OldPointIndex          : integer = 0;


 procedure TPLLForm.AmplitudeCheckBoxClick(Sender: TObject);
 begin
   if AmplitudeCheckBox.State=cbUnchecked then
    begin
      PLLChart.LeftAxis.Range.UseMax:=TRUE;
      PLLChart.LeftAxis.Range.UseMin:=TRUE;
    end
   else
     begin
       PLLChart.LeftAxis.Range.UseMax:=FALSE;
       PLLChart.LeftAxis.Range.UseMin:=FALSE;
     end;
 end;

procedure TPLLForm.AmplitudeSetPointEditKeyPress(Sender: TObject; var Key: char
  );
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(AmplitudeSetPointEdit.Text);
      if ((Value>0) and (Value<65)) then
          AmpSetPoint:=Value;
      AmplitudeSetPointEdit.Text:=FloatToStrF(AmpSetPoint, ffFixed, 9, 3);
      SetAmplitudeSetPoint;
    end;
end;

procedure TPLLForm.AmpPIDCheckBoxClick(Sender: TObject);
begin
  if AmpPIDCheckBox.Checked = TRUE then
    begin
      AmpPID := TRUE;
      StartAmplitudePID;
    end
   else
    begin
      AmpPID := FALSE;
      StopAmplitudePID;
    end;
end;

procedure TPLLForm.AmpIntEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(AmpIntEdit.Text);
      if ((Value>0) and (Value<65000)) then
          AmpIntTime:=Value;
      AmpIntEdit.Text:=FloatToStrF(AmpIntTime, ffFixed, 9, 3);
      SetAmpIntTime;
    end;
end;

procedure TPLLForm.AmpDiffEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(AmpDiffEdit.Text);
      if ((Value>0) and (Value<65000)) then
          AmpDiffTime:=Value;
      AmpDiffEdit.Text:=FloatToStrF(AmpDiffTime, ffFixed, 9, 3);
      SetAmpDiffTime;
    end;
end;

procedure TPLLForm.AmpPropEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(AmpPropEdit.Text);
      if ((Value>0) and (Value<65)) then
          AmpPropCoeff:=Value;
      AmpPropEdit.Text:=FloatToStrF(AmpPropCoeff, ffFixed, 9, 3);
      SetAmpPropCoeff;
    end;
end;



procedure TPLLForm.CenterFrequencyEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
   //if not PLLMode then      ## removed this to enable changing center frequency while PID is on
    begin
      Value:=StrToFloat(CenterFrequencyEdit.Text);
      if ((Value>0) and (Value<99999)) then PLLCenterFrequency:=Value;
      CenterFrequencyEdit.Text:=FloatToStrF(PLLCenterFrequency, ffFixed, 9, 3);
      SetPLLFrequency(PLLCenterFrequency);
    end;
end;

procedure TPLLForm.ChartToolset1DataPointClickTool1PointClick(
  ATool: TChartTool; APoint: TPoint);
var
  x, y: Double;
begin
  with ATool as TDatapointClickTool do
    begin
      if ((OldPointIndex>0) and
          (OldPointIndex<PllAmpLineSeries.ListSource.YCount)) then
        begin
          PLLAmpLineSeries.ListSource.SetText(OldPointIndex,'');
          PLLPhaseLineSeries.ListSource.SetText(OldPointIndex, '');
        end;
      if (Series <> nil) then
        with (Series as TLineSeries) do begin
          x := GetXValue(PointIndex);
          y := GetYValue(PointIndex);
          //ListSource.Item[PointIndex]^.Text := Format('x = %f'#13#10'y = %f', [x,y]);
          //ParentChart.Repaint;
          // in newer Lazarus versions you can use (which already contains the Repaint):
           ListSource.SetText(PointIndex, Format('x = %f'#13#10'y = %f', [x,y]));
           OldPointIndex:=PointIndex;
        end;
      end;
end;

procedure TPLLForm.ChartToolset1DataPointCrosshairTool1AfterMouseDown(
  ATool: TChartTool; APoint: TPoint);
var
  x, y: Double;
begin
  with ATool as TDatapointCrosshairTool do
    begin
      if (Series <> nil) then
        with (Series as TLineSeries) do begin
          x := GetXValue(PointIndex);
          y := GetYValue(PointIndex);
          //ListSource.Item[PointIndex]^.Text := Format('x = %f'#13#10'y = %f', [x,y]);
          //ParentChart.Repaint;
          // in newer Lazarus versions you can use (which already contains the Repaint):
           CoordLabel.Caption:= Format('x = %f : y = %f', [x,y]);
           CoordLabel.Visible:=TRUE;
        end;
      end;
end;

procedure TPLLForm.ChartToolset1DataPointCrosshairTool1AfterMouseWheelDown(
  ATool: TChartTool; APoint: TPoint);
var
  x, y: Double;
begin
  with ATool as TDatapointCrosshairTool do
      if (Series <> nil) then
           CoordLabel.Caption:= Format('x = %f : y = %f', [x,y]);
           CoordLabel.Visible:=FALSE;
end;


procedure TPLLForm.ConvFactorEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(ConvFactorEdit.Text);
      if (Value>0) then FreqConversionFactor:=Value;
      ConvFactorEdit.Text:=FloatToStrF(FreqConversionFactor, ffFixed, 3, 9);
      SendPLLConvFactor(FreqConversionFactor);
    end;
end;

procedure TPLLForm.DataTimerTimer(Sender: TObject);
begin
   //First find out the frequency that the Olimex thinks it's putting out
   OutputFrequency:=ReadFrequency;
   FrequencyLabel.Caption:= 'Frequency (Hz): '+ FloatToStrF(OutputFrequency, ffFixed, 9, 3);
   //Next amplitude
   RealAmplitude:=ReadPLLAmplitude;
   AmplitudeLabel.Caption:= 'Amplitude (V): ' + FloatToStrF(RealAmplitude, ffFixed, 9, 3);
   //Finally phase
   MeasuredPhase := ReadPLLPhase;
   PhaseLabel.Caption := 'Phase (degrees): ' +  FloatToStrF(MeasuredPhase, ffFixed, 9, 3);
end;

procedure TPLLForm.FormShow(Sender: TObject);
begin
  InitializePLLSerial;
  if PLLMode then PLLModeRadioGroup.ItemIndex:=1 else PLLModeRadioGroup.ItemIndex:=0;
  StartFrequency:=PLLCenterFrequency-100;
  StopFrequency:=PLLCenterFrequency+100;
  FrequencyStep:=0.1; //in Hertz
  FrequencyAverages:=10;
  CenterFrequencyEdit.Text:=FloatToStrF(PLLCenterFrequency, ffFixed, 9, 3);
  StartFrequencyEdit.Text:=FloatToStrF(StartFrequency, ffFixed, 9, 3);
  StopFrequencyEdit.Text:=FloatToStrF(StopFrequency, ffFixed, 9, 3);
  FrequencyStepEdit.Text:=FloatToStrF(FrequencyStep, ffFixed, 9, 3);
  FrequencyAveragesSpinEdit.Value:=FrequencyAverages;
  ConvFactorEdit.Text:=FloatToStrF(FreqConversionFactor, ffFixed, 9, 3);
  FrequencySweep:=FALSE;
  FrequencyModOn:= FALSE;
  ModDirectionUp:= TRUE;
  FreqModTimer.Enabled:=FALSE;
  FrequencyMod := 0.5; //Hz
  FrequencyModEdit.Text:=FloatToStrF(FrequencyMod, ffFixed, 9, 3);
  ModPeriod :=1; //seconds
  ModPeriodEdit.Text:=FloatToStrF(ModPeriod, ffFixed, 9, 3);
  FreqModTimer.Interval:=round(1000*ModPeriod);
  FreqPropCoeff:=1.0;
  FreqPropEdit.Text:=FloatToStrF(FreqPropCoeff, ffFixed, 9,3);
  FreqIntTime:=0.01;  //in milliseconds
  FreqIntEdit.Text:=FloatToStrF(FreqIntTime, ffFixed, 9,3);
  FreqDiffTime:=0.001;
  FreqDiffEdit.Text:=FloatToStrF(FreqDiffTime, ffFixed, 9,3);
  AmpPropCoeff:=1.0;
  AmpPropEdit.Text:=FloatToStrF(AmpPropCoeff, ffFixed, 9,3);
  AmpIntTime:=0.01;  //in milliseconds
  AmpIntEdit.Text:=FloatToStrF(AmpIntTime, ffFixed, 9,3);
  AmpDiffTime:=0.001;
  AmpDiffEdit.Text:=FloatToStrF(AmpDiffTime, ffFixed, 9,3);
  AmpPID:=FALSE;
  AmpPIDCheckBox.Checked:=FALSE;
  AmpSetPoint:=1.0;
  AmplitudeSetPointEdit.Text:=FloatToStrF(AmpSetPoint, ffFixed, 9,3);

  QControl := Off;
  QControlCheckBox.Checked:=FALSE;

  SelfExcitation := Off;
  SelfExcitationCheckBox.Checked:=FALSE;
  PhaseOffset:=0;
  PhaseOffsetEdit.Text:=FloatToStrF(PhaseOffset, ffFixed, 9, 3);

  //Initialize the Olimex
  //SendPLLConvFactor(FreqConversionFactor);
  //DataTimer.Enabled:=TRUE;
end;

procedure TPLLForm.FreqDiffEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(FreqDiffEdit.Text);
      if ((Value>0) and (Value<65000)) then
          FreqDiffTime:=Value;
      FreqDiffEdit.Text:=FloatToStrF(FreqDiffTime, ffFixed, 9, 3);
      SetFreqDiffTime;
    end;
end;

procedure TPLLForm.FreqIntEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(FreqIntEdit.Text);
      if ((Value>0) and (Value<65000)) then
          FreqIntTime:=Value;
      FreqIntEdit.Text:=FloatToStrF(FreqIntTime, ffFixed, 9, 3);
      SetFreqIntTime;
    end;
end;

procedure TPLLForm.FreqModControlButtonClick(Sender: TObject);
begin
  if FrequencyModOn then //stop the timer
    begin
      FreqModTimer.Enabled:=FALSE;
      FreqModControlButton.Caption:='Start';
      FreqModControlButton.Color:=clGreen;
      FrequencyModOn:=FALSE;
   end
   else
     begin
       FreqModTimer.Enabled:=TRUE;
       FreqModControlButton.Caption:='Stop';
       FreqModControlButton.Color:=clRed;
       FrequencyModOn:=TRUE;
     end;
end;

procedure TPLLForm.FreqModTimerStartTimer(Sender: TObject);
begin
  ModDirectionUp:=TRUE;
end;

procedure TPLLForm.FreqModTimerStopTimer(Sender: TObject);
begin
  SetPLLFrequency(PLLCenterFrequency);
end;

procedure TPLLForm.FreqModTimerTimer(Sender: TObject);
var ModulatedFrequency: real;
begin
  if ModDirectionUp then ModulatedFrequency:=PLLCenterFrequency+FrequencyMod
    else ModulatedFrequency:=PLLCenterFrequency-FrequencyMod;
  SetPLLFrequency(ModulatedFrequency);
  ModDirectionUp:= not ModDirectionUp;
end;

procedure TPLLForm.FreqPropEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(FreqPropEdit.Text);
      if ((Value>0) and (Value<65)) then
          FreqPropCoeff:=Value;
      FreqPropEdit.Text:=FloatToStrF(FreqPropCoeff, ffFixed, 9, 3);
      SetFreqPropCoeff;
    end;
end;

procedure TPLLForm.FrequencyAveragesSpinEditChange(Sender: TObject);
begin
  FrequencyAverages:=FrequencyAveragesSpinEdit.Value;
end;

procedure TPLLForm.FrequencyModEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(FrequencyModEdit.Text);
      if (Value>0) then FrequencyMod:=Value;
      FrequencyModEdit.Text:=FloatToStrF(FrequencyMod, ffFixed, 9, 3);
    end;
end;

procedure TPLLForm.FrequencyStepEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(FrequencyStepEdit.Text);
      if ((Value>0) and (Value<99999)) then FrequencyStep:=Value;
      FrequencyStepEdit.Text:=FloatToStrF(FrequencyStep, ffFixed, 9, 3);
    end;
end;

procedure TPLLForm.FrequencySweepButtonClick(Sender: TObject);
var j, k
                        : integer;
    CurrentFrequency,
    SumAmplitude,
    SumPhase,
    PLLAmplitude,
    PLLPhase
                        : real;
begin
  if FrequencySweep then //if we are already sweeping
    begin
       FrequencySweepButton.Caption:='Start';
       FrequencySweepButton.Color:=clGreen;
       FrequencySweep:=FALSE;
       PLLModeRadioGroup.Enabled:=TRUE;
       CenterFrequencyEdit.Enabled:=TRUE;
       ConvFactorEdit.Enabled:=TRUE;
       FrequencyModEdit.Enabled:=TRUE;
       ModPeriodEdit.Enabled:=TRUE;
       FreqModControlButton.Enabled:=FALSE;
       FrequencyModOn:=FALSE;
    end
   else //start the scan
     begin
       FrequencySweepButton.Caption:='Stop';
       FrequencySweepButton.Color:=clRed;
       FrequencySweep:=TRUE;
       PLLModeRadioGroup.Enabled:=FALSE;
       CenterFrequencyEdit.Enabled:=FALSE;
       ConvFactorEdit.Enabled:=FALSE;
       FrequencyModEdit.Enabled:=FALSE;
       ModPeriodEdit.Enabled:=FALSE;
       FreqModControlButton.Enabled:=FALSE;
       //Set the plot parameters
       PLLChart.BottomAxis.Range.Max:=StopFrequency;
       PLLChart.BottomAxis.Range.Min:=StartFrequency;
       PLLChart.BottomAxis.Range.UseMax:=TRUE;
       PLLChart.BottomAxis.Range.UseMin:=TRUE;
       PLLAmpLineSeries.Clear;
       PLLPhaseLineSeries.Clear;
       NumbSteps:=round((StopFrequency-StartFrequency)/FrequencyStep);
       SetLength(AmpPhaseData, NumbSteps+1);
       j:=0;
       while ((j<=NumbSteps) and FrequencySweep) do
       //for j:=0 to NumbSteps do //this is the frequency loop
         begin
           CurrentFrequency:=StartFrequency + j*FrequencyStep;
           SetPLLFrequency(CurrentFrequency);
           CurrentFrequencyLabel.Caption:='Current Frequency: ' + FloatToStrF(CurrentFrequency, ffFIxed, 9, 3);
           //Now the loop to read and average the signals
           SumAmplitude:=0;
           SumPhase:=0;
           for k:=0 to FrequencyAverages do
             begin
                 SumAmplitude:=SumAmplitude + ReadPLLAmplitude;
                 SumPhase:=SumPhase + ReadPLLPhase;
             end;
           PLLAmplitude:=SumAmplitude/FrequencyAverages;
           PLLPhase:=SumPhase/FrequencyAverages;
           PLLAmpLineSeries.AddXY(CurrentFrequency, PLLAmplitude, '', clRed);
           PLLPhaseLineSeries.AddXY(CurrentFrequency, PLLPhase, '', clNavy);
           AmpPhaseData[j,0]:=CurrentFrequency;
           AmpPhaseData[j,1]:=PLLAmplitude;
           AmpPhaseData[j,2]:=PLLPhase;
           inc(j);
           Application.ProcessMessages;
         end;
     end;
   //change everthing back
   FrequencySweepButton.Caption:='Start';
   FrequencySweepButton.Color:=clGreen;
   FrequencySweep:=FALSE;
   PLLModeRadioGroup.Enabled:=TRUE;
   CenterFrequencyEdit.Enabled:=TRUE;
   ConvFactorEdit.Enabled:=TRUE;
   FrequencyModEdit.Enabled:=TRUE;
   ModPeriodEdit.Enabled:=TRUE;
end;

procedure TPLLForm.ModPeriodEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(ModPeriodEdit.Text);
      if (Value>0) then ModPeriod:=Value;
      ModPeriodEdit.Text:=FloatToStrF(ModPeriod, ffFixed, 9, 3);
      FreqModTimer.Interval:=round(1000*ModPeriod);
    end;
end;


procedure TPLLForm.PhaseCheckBoxClick(Sender: TObject);

begin
  if PhaseCheckBox.State=cbUnchecked then
   begin
     PLLChart.AxisList[2].Range.UseMax:=TRUE;
     PLLChart.AxisList[2].Range.UseMin:=TRUE;
   end
  else
    begin
      PLLChart.AxisList[2].Range.UseMax:=FALSE;
      PLLChart.AxisList[2].Range.UseMin:=FALSE;
    end;
end;

procedure TPLLForm.PhaseOffsetEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(PhaseOffsetEdit.Text);
      if ((Value>-180) and (Value<180)) then
          PhaseOffset:=Value;
      PhaseOffsetEdit.Text:=FloatToStrF(PhaseOffset, ffFixed, 9, 3);
      SetPhaseOffset;
    end;
end;


procedure TPLLForm.PLLModeRadioGroupClick(Sender: TObject);
begin
  if PLLModeRadioGroup.ItemIndex = 0 then
   begin
    PLLMode:=FALSE;
    EndPLLMode;
    FreqModControlButton.Enabled:=FALSE;
   end
  else
   begin
     PLLMode:=TRUE;
     StartPLLMode;
     FreqModControlButton.Enabled:=TRUE;
   end;
end;

procedure TPLLForm.QControlCheckBoxClick(Sender: TObject);
begin
  if QControlCheckBox.Checked = TRUE then
    EnableQControl
   else DisableQControl;
end;

procedure TPLLForm.SaveCurvesClick(Sender: TObject);
var
  TextFileVersion: TextFile;
  i   : integer;
begin
  if SaveDialog.Execute then
     begin
       AssignFile(TextFileVersion, SaveDialog.FileName);
       Rewrite(TextFileVersion);
       //First write the magic file header
       //Note that writeln on Linux systesms does not write the CR character, so we are ok
       writeln(TextFileVersion, 'SPM  Resonance Curve Data File');
       //next the date
       writeln(TextFileVersion, 'Date = '+DateTimeToStr(Now));
       //First the Approach data
       writeln(TextFileVersion, 'Amplitude and Phase Data');
       writeln(TextFileVersion, 'Frequency(Hz)      Amplitude (arb)     Phase (arb)');
       for i:=0 to NumbSteps do
         writeln(TextFileVersion, FloatToStrF(AmpPhaseData[i,0], ffExponent, 10, 4)
                         + '  '+ FloatToStrF(AmpPhaseData[i,1], ffExponent, 10, 4)
                         + '  '+ FloatToStrF(AmpPhaseData[i,2], ffExponent, 10, 4));

       //close the file and we are done!
       CloseFile(TextFileVersion);
     end;
end;

procedure TPLLForm.SelfExcitationCheckBoxClick(Sender: TObject);
begin
  if SelfExcitationCheckBox.Checked = TRUE then
    EnableSelfExcitation
   else DisableSelfExcitation;
end;

procedure TPLLForm.StartFrequencyEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(StartFrequencyEdit.Text);
      if ((Value>0) and (Value<99999)) then
         if Value<StopFrequency then StartFrequency:=Value;
      StartFrequencyEdit.Text:=FloatToStrF(StartFrequency, ffFixed, 9, 3);
      PLLChart.ExtentSizeLimit.XMax:=StopFrequency-StartFrequency;
    end;
end;

procedure TPLLForm.StopFrequencyEditKeyPress(Sender: TObject; var Key: char);
var
  Value : Real;
begin
  if Key=Chr(13) then
    begin
      Value:=StrToFloat(StopFrequencyEdit.Text);
      if ((Value>0) and (Value<99999)) then
          if Value>StartFrequency then StopFrequency:=Value;
      StopFrequencyEdit.Text:=FloatToStrF(StopFrequency, ffFixed, 9, 3);
      PLLChart.ExtentSizeLimit.XMax:=StopFrequency-StartFrequency;
    end;
end;


initialization
  {$I pllcontrol.lrs}

end.

