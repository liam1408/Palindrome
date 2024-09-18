# hex pairs converter
Instrctions: 
Input String: The program receives a string of characters (make sure the input prompt is appropriate) with a maximum length of 37 characters (in practice, 36). The characters are pairs of hexadecimal digits (each pair representing a byte) separated by the $ character. After the last pair, the ENTER key is pressed. The string is stored in the data segment in an array named stringhex (allocate 37 bytes for this array). Perform a syscall using 8 to handle the input.

Validation Procedure: The program checks the validity of the input using a procedure called valid_is, which takes the address of the stringhex array as a parameter. If the input is valid, the procedure returns a value between 1 and 12 in register v0, indicating the number of valid hexadecimal pairs. If the input is invalid, the procedure returns the value 0.

Valid Input Conditions:

Contains no more than 36 characters, consisting of pairs of hexadecimal digits (A-F only in uppercase) separated by $ characters and ending with a $ character, followed by either a null terminator (ASCII code 0) or a newline (ASCII code 10) as per syscall 8 definitions.
The string must contain at least one pair of hexadecimal digits.
Only one $ character is allowed consecutively.
There should be exactly two digits between each $.
Example of Valid Input: EF$DE$23$56$76$AA$76$07$

In this case, the value 8 would be returned in v0, indicating that 8 pairs of hexadecimal digits were entered.

Example of Invalid Input: EEE$23$$34$QA$7$a2$2$AA$122$FF

If the input is invalid (v0 = 0), an error message "input wrong" should appear, and the user will be prompted to enter the string again with an appropriate message.

Conversion Procedure: If the input is valid, call a procedure named convert, which takes three parameters: the address of the stringhex array, the address of an array named NUM, and the number of hexadecimal pairs. The procedure converts each pair of characters in the stringhex array into a numerical value of one byte and stores them in the NUM array in the order they appear.

(Note: Allocate an array named NUM with a size of 12 bytes in the variables segment.)

Unsigned Sorting Procedure: After conversion, call a procedure named sortunsign, which takes three parameters: the address of an array named unsign, the address of the NUM array, and the number of bytes in NUM that need to be sorted. The procedure sorts the elements of NUM into the unsign array using an unsigned representation method, from largest to smallest.

(Note: Allocate an array named unsign with a size of 12 bytes in the variables segment.)

Signed Sorting Procedure: Then, call a procedure named sortsign, which takes three parameters: the address of an array named sign, the address of the NUM array, and the number of bytes in NUM that need to be sorted. The procedure sorts the elements of NUM into the sign array using two’s complement signed representation, from largest to smallest.

(Note: Allocate an array named sign with a size of 12 bytes in the variables segment.)

Print Unsigned Procedure: After sorting, call a procedure named printunsign, which takes two parameters: the address of the unsign array and the number of bytes to print. The procedure prints an appropriate message followed by the elements of the unsign array in decimal format with two spaces between each number. (Note: The range of numbers is from 0 to 255. Do not use syscall 1 for printing.)

Print Signed Procedure: Finally, call a procedure named printsign, which takes two parameters: the address of the sign array and the number of bytes to print. The procedure prints an appropriate message followed by the elements of the sign array in decimal format with two spaces between each number. (Note: The range of numbers is from -128 to 127. A minus sign should be printed for negative numbers. Do not use syscall 1 for printing.)


