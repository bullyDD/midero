package Sonar_DMA is

    pragma Elaborate_Body;

    -- Initialize ADC and DMA for the given controller and
    -- transfer data from Peripheral To Memory
    procedure Initialize;

    -- Returns the measured distance from sharpIR sensor.
    -- Distance in centimeters
    function Get_Distance return Float;
    
end Sonar_DMA;