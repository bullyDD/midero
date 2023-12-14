-- Demo app that run a simple task which periodly polling MCU cortex-m4 ADC
-- to convert analogic data comming from metal sensor connected on GPIO PA5.

with Ada.Real_Time;
with Metal_Detector;    pragma Unreferenced (Metal_Detector);

procedure Demo_Detector_Polling is
   use Ada.Real_Time;
begin
   loop
      delay until Time_Last;
   end loop;
end Demo_Detector_Polling;
