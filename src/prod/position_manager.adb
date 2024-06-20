with Ada.Numerics;  
with Ada.Real_Time; 

with Global_Initialization;
with Hardware_Config;
with Recursive_Moving_Average_Filters_Discretes;

package body Position_Manager is
    
    use Ada.Numerics;
    use Ada.Real_Time;

    Period          : constant Time_Span  := 
            Milliseconds (System_Configuration.Engine_Monitor_Period);
    Sample_Interval : constant Float      
            := Float (System_Configuration.Engine_Monitor_Period) / 1000.0;

    Counts_Per_Revolution      : constant Nonnegative_Float := 
            Float (Encoder_Counts_Per_Revolution);

    Wheel_Circumference        : constant Nonnegative_Float := 
            Pi * Wheel_Diameter * Gear_Ratio;

    Distance_Per_Encoder_Count : constant Nonnegative_Float := 
            Wheel_Circumference / Counts_Per_Revolution;

    Current_Speed : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;


    Total_Distance_Traveled : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;
  
    function Safely_Subtract (Left, Right : Motor_Encoder_Counts) return Motor_Encoder_Counts;
    --  Computes Left - Right without actually overflowing. The result is either
    --  the subtracted value, or, if the subtraction would overflow, the 'First
    --  or 'Last for type Motor_Encoder_Counts.

    type Sample_Array is array (Positive range 1 .. 4) of Motor_Encoder_Counts;
    Samples : Sample_Array;

    type Distances is array (Positive range 1 .. 4) of Nonnegative_Float;

    -----------
    -- Speed --
    -----------

    function Speed return Float is
    begin
        return Current_Speed;
    end Speed;

    --------------
    -- Odometer --
    --------------

    function Odometer return Float is
    begin
        return Total_Distance_Traveled;
    end Odometer;

    -------------------
    -- Encoder_Noise --
    -------------------

    package Encoder_Noise_Filter is new Recursive_Moving_Average_Filters_Discretes
        (Sample      => Motor_Encoder_Counts,
        Accumulator => Long_Long_Integer);

    use Encoder_Noise_Filter;
    Noise_Filter      : Encoder_Noise_Filter.RMA_Filter (Window_Size => 5); -- arbitrary size


    procedure Get_Samples (M1, M2, M3, M4 : in out Basic_Motor) is
    begin
        Noise_Filter.Reset;
        
        Samples (1) := M1.Encoder_Count;
        Samples (2) := M2.Encoder_Count;
        Samples (3) := M3.Encoder_Count;
        Samples (4) := M4.Encoder_Count;

        for I in 1 .. 4 loop
            Noise_Filter.Insert (Samples(I));
        end loop;
    end Get_Samples;


    protected Critical_Position is
        procedure Set_Position (Val : Nonnegative_Float; Last : Positive :=1);
        procedure Get_Position (Val : out Nonnegative_Float; Last : Positive :=1);
    private
        Distances_Traveled : Distances;
    end Critical_Position;

    -----------------------
    -- Critical_Position --
    -----------------------

    protected body Critical_Position is

        ------------------
        -- Set_Position --
        ------------------

        procedure Set_Position (Val: Nonnegative_Float; Last : Positive := 1) is
        begin
            Distances_Traveled (Last) := Val;
        end Set_Position;

        ------------------
        -- Get_Position --
        ------------------

        procedure Get_Position (Val : out Nonnegative_Float; Last : Positive := 1) is
        begin
            Val := Distances_Traveled (Last);
        end Get_Position;

    end Critical_Position;

    --------------------
    -- Engine_Monitor --
    --------------------

    task body Engine_Monitor  is
        Next_Release      : Time;
        Current_Count     : Motor_Encoder_Counts := 0;
        Previous_Count    : Motor_Encoder_Counts;
        Encoder_Delta     : Motor_Encoder_Counts;
        Interval_Distance : Nonnegative_Float;
        Current_Distance  : Nonnegative_Float;

    begin
        Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);

        loop
            Previous_Count := Current_Count;

            for I in 1 .. 4 loop
            
                Noise_Filter.Insert (Samples (I));
            
                Current_Count := Noise_Filter.Value;

                Encoder_Delta := Safely_Subtract (Current_Count, Previous_Count);

                Interval_Distance := abs (Float (Encoder_Delta) * Distance_Per_Encoder_Count);
                Current_Speed := Interval_Distance / Sample_Interval;    -- package global variable

                Current_Distance := Total_Distance_Traveled;
                Current_Distance := Current_Distance + Interval_Distance;
                Total_Distance_Traveled := Current_Distance; -- package global variable
                Critical_Position.Set_Position (Total_Distance_Traveled, I);

            end loop;
            
            Next_Release := Next_Release + Period;
            delay until Next_Release;
        end loop;
    end Engine_Monitor;


    --------------------------
    -- Get_Current_Position --
    --------------------------

    function Get_Current_Position (Last : Positive :=1) return Nonnegative_Float is
        Position : Nonnegative_Float;
    begin
        Critical_Position.Get_Position (Position, Last);
        return Position;
    end Get_Current_Position;


    ---------------------
    -- Safely_Subtract --
    ---------------------

    function Safely_Subtract
            (Left, Right : Motor_Encoder_Counts)
    return Motor_Encoder_Counts
    is
        Result : Motor_Encoder_Counts;
    begin
        if Right > 0 then
            if Left >= Motor_Encoder_Counts'First + Right then
                Result := Left - Right;
            else -- would overflow
                Result := Motor_Encoder_Counts'First;
            end if;
        else -- Right is negative or zero
            if Left <= Motor_Encoder_Counts'Last + Right then
                Result := Left - Right;
            else -- would overflow
                Result := Motor_Encoder_Counts'Last;
            end if;
        end if;

        return Result;
    end Safely_Subtract;

end Position_Manager;