# Base-System-Converter

**Overview**

This MIPS assembly program provides functionality to convert numbers between decimal (base 10) and any other numbering system (e.g., binary, octal, hexadecimal) and vice versa. The program is designed to demonstrate basic assembly-level operations such as arithmetic, loops, and string manipulation.


---

**Features**

1. Decimal to Any Base Conversion
   Converts a given decimal number into a specified base (2-16).


2. Any Base to Decimal Conversion
   Converts a number in a specified base (2-16) back to decimal.




---

**Input Requirements**

1. Decimal to Base Conversion:

   Input: A positive decimal number.

   Target Base: Base to which the number will be converted (2-16).



2. Base to Decimal Conversion:

   Input: A number in the specified base (as a `string`).

   Base: The base of the input number (2-16).





---

**Output**

The converted number will be displayed as a `string`.

Supports both uppercase and lowercase alphabets for bases greater than 10.



---

**Usage Instructions**

1. Assemble the program using a MIPS assembler _**MARS**_.


2. Run the program and follow the prompts:

   Enter the number and the base for conversion.

   Select conversion type (Decimal to Base or Base to Decimal).



3. View the result on the console.




---

**Example**

Input:

Decimal: 255

Target Base: 16


Output:

Result: `FF`


Input:

Number: FF

Base: 16


Output:

Decimal: `255`
