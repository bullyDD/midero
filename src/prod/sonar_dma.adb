with Ada.Real_Time;             
with System.Libm_Single;

with STM32.ADC;   
with STM32.Device;                            
with STM32.DMA;                 
with STM32.GPIO;                

with Global_Initialization;
with Hardware_Config;    
with HAL;                        
with System_Configuration;

package body Sonar_DMA is

    use Ada.Real_Time;
    use STM32.ADC;
    use STM32.Device;
    use STM32.DMA;
    use STM32.GPIO;
    use HAL;
    use Hardware_Config;
    use System.Libm_Single;


    Counts        : HAL.UInt16 with Volatile;
    Period        : constant Time_Span := 
            Milliseconds (System_Configuration.Sonar_Period);

    procedure Initialize_ADC;
    procedure Initialize_DMA;

    protected Critical_Distance is
        procedure Set (Reading : HAL.UInt16);
        procedure Get (Reading : out HAL.UInt16);
    private
        Internal_Dist : HAL.UInt16 := 0;
    end Critical_Distance;

    -----------------------
    -- Critical_Distance --
    -----------------------
    protected body Critical_Distance is
        ---------
        -- Set --
        ---------
        procedure Set (Reading : HAL.UInt16) is
        begin
            Internal_Dist := Reading;
        end Set;
        ---------
        -- Get --
        ---------
        procedure Get (Reading : out HAL.UInt16) is
        begin
            Reading := Internal_Dist;
        end Get;

    end Critical_Distance;
   
    ----------------
    -- Controller --
    ----------------

    task Controller_Sonar with
        Priority => System_Configuration.Highest_Priority;

    task body Controller_Sonar is
        Next_Time   : Time;
    begin
        Global_Initialization.Critical_Instant.Wait (Next_Time);

        Detection_Loop:
        loop           
            Critical_Distance.Set (Counts);
            Next_Time := Next_Time + Period;
            delay until Next_Time;

        end loop Detection_Loop;

    end Controller_Sonar;
   
    --------------------
    -- Initialize_DMA --
    --------------------
    procedure Initialize_DMA  is
        Config : DMA_Stream_Configuration;
    begin
        Enable_Clock (Controller);
        Reset (This   => Controller,
                Stream => Stream);
        
        Config.Channel                      := Channel_0;
        Config.Direction                    := Peripheral_To_Memory;
        Config.Memory_Data_Format           := HalfWords;
        Config.Peripheral_Data_Format       := HalfWords;
        Config.Increment_Peripheral_Address := False;
        Config.Increment_Memory_Address     := False;
        Config.Operation_Mode               := Circular_Mode;
        Config.Priority                     := Priority_Very_High;
        Config.FIFO_Enabled                 := False;
        Config.Memory_Burst_Size            := Memory_Burst_Single;
        Config.Peripheral_Burst_Size        := Peripheral_Burst_Single;
        
        Configure        (Controller, Stream, Config);
        Clear_All_Status (Controller, Stream);
        
    end Initialize_DMA;

    --------------------
    -- Initialize_ADC --
    --------------------
    
    procedure Initialize_ADC  is
        All_Regular_Conversions : constant Regular_Channel_Conversions :=
        (1 => (Channel => Sig_Input_Channel, Sample_Time => Sample_480_Cycles));

        procedure Configure_Analog_Input; 
        
        ----------------------------
        -- Configure_Analog_Input --
        ----------------------------
        procedure Configure_Analog_Input is
        begin
            Enable_Clock (Hardware_Config.Signal_Pin);
            Configure_IO (Signal_Pin, 
                    (Mode => Mode_Analog, Resistors => Floating));
        end Configure_Analog_Input;

    begin
        Configure_Analog_Input;
        Enable_Clock (Converter);
        Reset_All_ADC_Units;
        
        Configure_Common_Properties (Mode           => Independent,
                                    Prescalar      => PCLK2_Div_2,
                                    DMA_Mode       => Disabled,
                                    Sampling_Delay => Sampling_Delay_5_Cycles);
        
        Configure_Unit (This       => Converter,
                        Resolution => ADC_Resolution_10_Bits,
                        Alignment  => Right_Aligned);
        
        Configure_Regular_Conversions (This        => Converter,
                                        Continuous  => True,
                                        Trigger     => Software_Triggered,
                                        Enable_EOC  => False,
                                        Conversions => All_Regular_Conversions);
        
        Enable_DMA (Converter);
        Enable_DMA_After_Last_Transfer (Converter);
        
    end Initialize_ADC;

    ------------------
    -- Get_Distance --
    ------------------
    function Get_Distance return Float is
        Direct_Reading : HAL.UInt16;
        Measure : Float;
    begin
        -- Formule obtenue a partir de la documentation technique
        -- D = 29.988 * Temp**(-1.173)

        Critical_Distance.Get (Direct_Reading);
        Measure := (29.988 * System.Libm_Single.Pow (Float (Direct_Reading), -1.173)) * 1000.0;
        -- retourne la distance mesurée en cm
        
        if Measure > 63.0 then
            Measure := 63.0;
        elsif Measure <= 10.0 then
            Measure := 10.0;
        end if;      

        return Measure;
    end Get_Distance;

    ----------------
    -- Initialize --
    -----------------
    procedure Initialize is
    begin
        --  1) Initialize_DMA
        Initialize_DMA;
        
        --  2) Initialize ADC
        Initialize_ADC;
        
        --  3) Enable converter
        Enable (Converter);
        
        --  4) Transfer data from Peripheral To Memory
        Start_Transfer (This        => Controller,
                        Stream      => Stream,
                        Source      => Data_Register_Address (Converter),
                        Destination => Counts'Address,
                        Data_Count  => 1);
        Start_Conversion (Converter);
    end Initialize;

begin
  Initialize;
  null;
end Sonar_DMA;