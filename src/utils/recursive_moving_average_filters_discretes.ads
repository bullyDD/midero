
with Sequential_Bounded_Buffers;

generic

   type Sample is range <>;
   --  The type used for the input samples and output averages.

   type Accumulator is range <>;
   --  The type used for the running total of inputs. The intent is that this
   --  type has a larger range than that of type Sample, so that a larger total
   --  can be accommodated.

   --  For both types, null ranges are not allowed. We check that with the
   --  Compile_Time_Error pragmas below.

package Recursive_Moving_Average_Filters_Discretes is

    pragma Compile_Time_Error
        (Sample'First > Sample'Last,
        "Sample range must not be null");

    pragma Compile_Time_Error
        (Accumulator'First > Accumulator'Last,
        "Accumulator range must not be null");

    subtype Filter_Window_Size is Integer range 1 .. Integer'Last / 2;

    type RMA_Filter (Window_Size : Filter_Window_Size) is tagged limited private;

    procedure Insert (This : in out RMA_Filter;  New_Sample : Sample);
    --  Updates the new average value based on the value of New_Sample

    function Value (This : RMA_Filter) return Sample with Inline;
    --  simply returns the average value previously computed by Insert

    procedure Reset (This : out RMA_Filter) with
        Post'Class => Value (This) = 0;

    private

    package Sample_Data is new Sequential_Bounded_Buffers (Element => Sample, Default_Value => 0);
    use Sample_Data;

    type RMA_Filter (Window_Size : Filter_Window_Size) is tagged limited record
        Samples        : Sample_Data.Ring_Buffer (Window_Size);
        Averaged_Value : Sample := 0;
        Total          : Accumulator := 0;
    end record;

end Recursive_Moving_Average_Filters_Discretes;
