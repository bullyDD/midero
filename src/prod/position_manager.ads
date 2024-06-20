with Motor_Prod;
with System_Configuration;


package Position_Manager is

    pragma Elaborate_Body;

    use Motor_Prod;

    subtype Nonnegative_Float is Float range 0.0 .. Float'Last;

    function Get_Current_Position (Last : Positive :=1) return Nonnegative_Float;
    
    function Speed return Float with Inline, Volatile_Function;
    --  in cm/sec

    function Odometer return Float with Inline, Volatile_Function;
    --  in centimeters

    procedure Get_Samples (M1, M2, M3, M4 : in out Basic_Motor);

    Wheel_Diameter : constant := 6.6; -- centimeters
    Gear_Ratio : constant := 1.0;

private

    task Engine_Monitor with
        Storage_Size => 1 * 1024,
        Priority     => System_Configuration.Engine_Monitor_Priority;

end Position_Manager;