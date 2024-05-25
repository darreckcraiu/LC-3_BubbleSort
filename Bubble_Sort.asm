;CIS-11 Group Project: Bubble Sort Algorithm

.ORIG X3000

;There is one stack but it will serve 2 purposes. While the program is collecting input from the user, the stack will be
;used to hold digits that are entered by the user. After the input has all been handled, the stack will be empty and ready
;to be used to output the final results of the program

;CODE FOR INPUT. USER NEEDS TO BE ABLE TO ENTER ANY NUMBER FROM 0 TO 999
	LEA R0, PROMPT 	;load PROMPT into R0
	PUTS 		;display string from R0 to console

	AND R1, R1, #0	;clear R1
	ADD R1, R1, #8	;R1 will hold 8 and will be our iteration count for INPUTLOOP

INPUTLOOP ;this loop will repeat 8 times so that 8 numbers can be recieved and processed

	AND R2, R2, #0	;clear R2
	ADD R2, R2, #3	;store 3 into R2. This will be the iteration count for NUMLOOP
  NUMLOOP ;this loop will run either 3 times(for 3 digits) or until the user inputs ENTER
	GETC		  ;get an input from the user and store in R0
	ADD R5, R0, #-10  ;to check if ENTER was the input. R5 is being used so that R0 stays untouched
	BRnp INPUT_GOOD   ;if enter was NOT the input, continue to INPUT_GOOD

	;if no digits were inputted before ENTER was, then the loop must be restart without decrementing the counter b/c the user hasnt entered a number yet
	;if at least one digit was inputted before ENTER was, then we can just branch all the way to NUMDONE. That takes place on the next 3 lines of code

	ADD R6, R2, #-3	;to check the loop counter(R2). R6 is used so that R2 stays untouched
	BRz NUMLOOP 	;if the counter was 3, branch to the beginning of the loop again
	BR NUMDONE 	;if not, branch to NUMDONE

       INPUT_GOOD
	OUT		;display the character that was entered to the console so the user can see what they entered
	ST R0, TEMP	;store the value entered into TEMP
	ADD R5, R5, #0  ;to check again if the key that was inputted was ENTER
	BRz NUMDONE 	;branch to NUMDONE since the user is done entering the number

			;if \n was not entered, now we can move on and validate that this input is a digit
	JSR VALIDATE 	;this subroutine will check if the value in TEMP is a digit. If it is not a digit, the program will halt here. Value is returned in R3
	JSR PUSH 	;R3 will be pushed onto the stack

	ADD R2, R2, #-1	;decrement R2(which is the loop counter for NUMLOOP that was initalized with a value of 3
	BRz NUMDONE 	;if R2 == 0, branch to NUMDONE because all 3 digits were entered

  BR NUMLOOP 	;if the program did not branch to NUMDONE on the previous line of code, that means the user is still inputting digits. So branch back up again to NUMLOOP to take another digit

	NUMDONE ;branch here when the user has finshed entering the digit(s) of the number. Now we can move on to calculate the actual value of the number based on the digits that were input. We will then store it into the array.
	  
	;at this point, the digits for a full number have been entered and pushed onto the stack. Now we must calculate the correct number using
	;the digits, and then store that number into the array.

	LD R4, STACK_COUNT 	;load the stack count into R4. This value tells us how many times to call POP b/c the current stack count is equivalent to the number of digits that were input by the user
	AND R5, R5, #0		;R5 will hold the number that we are calculating. After we're done, we will store its value into the array

	;this structure below is basically a switch statement
	
	;this next chunk of code is determining which "case" of the switch statement to jump to. This is decided by the number of digits(which is value of STACK_COUNT which is held in R4 right now)
	ADD R6, R4, #-3		
	BRz THREE_DIGITS 	;R6 is used to check the count for each of these checks so that the value in R4 stays untouched
	LD R4, STACK_COUNT
	ADD R6, R4, #-2
	BRz TWO_DIGITS
	LD R4, STACK_COUNT
	ADD R6, R4, #-1
	BRz ONE_DIGIT

	;this next chunk of code is like the body of a switch statement. The program jumps to one of the 3 labels based on the chunk of code above^^^^
       THREE_DIGITS 	;jump here if we are dealing with 3 digits that need to be popped. This is like a "case" line in a switch statement
	JSR POP 	;pop the top of the stack. This number is our third digit. It is returned in R3
	ADD R5, R5, R3	;add R3 to R5
	JSR POP 	;pop the second digit. It is returned in R3
	JSR TIMES_10 	;will multiply R3 by ten since this number is in the "tens" place when in decimal form. The value will be returned in R3
	ADD R5, R5, R3	;add R3 to R5
	JSR POP 	;pop the first digit. It is returned in R3
	JSR TIMES_100 	;will multiply R3 by 100 since this number is in the "hundreds" place when in decimal form. The value will be returned in R3
	ADD R5, R5, R3	;add R3 to R5
	BR DONE_POPPING ;this is like a "break" statement in a switch statement. Since we do not need to perform the other chunks of code below this one, we "break" and branch to DONE_POPPING
       TWO_DIGITS	;jump here if its 2 digits to be popped
	JSR POP 	;pop the second digit. It is returned in R3
	ADD R5, R5, R3	;add R3 to R5
	JSR POP 	;pop the first digit. It is returned in R3
	JSR TIMES_10 	;will multiply R3 by ten
	ADD R5, R5, R3	;add R3 to R5
	BR DONE_POPPING ;"break" and branch to DONE_POPPING
       ONE_DIGIT	;jump here if there is only 1 digit to be popped
	JSR POP ;pop the one digit. It is returned in R3
	ADD R5, R5, R3	;add R3 to R5
	;we don't need a "break" statement here b/c the next line of code already is DONE_POPPING

  DONE_POPPING 	;jump here when R5 has been calculated in the previous "switch" statement
		;at this point, we finally have the number the user inputted and it is in R5. Now we just need to add it to the array
		;the subscript that we will be assigning the value to is dependent on the current count in R1. Remember that R1 holds the loop counter for INPUTLOOP(which was initalized with a value of 8)

	NOT R3, R1 	;we will do 8 - count = subscript. This statement and the next are getting the negative version of the counter(R1) and storing it in R3 so that R1 stays untouched
	ADD R3, R3, #1	;to get the negative version of the counter and store it in R3
	ADD R3, R3, #8 	;add 8 and -count to get the subscript of the array that we will be assigning a value to

	LD R4, NUMBERS_ARRAY 	;load the address of the first element in the array. This is also the same as array[0] in C++
	ADD R3, R3, R4		;add the subscript we just calculated to the address and the result is the memory location we will store to. That location is stored in R3
	STR R5, R3, #0		;store the value in R5 into the location pointed to by R3. The number was just stored in array[subscript]

	;this next chunk of the code is the last chunk of code in the INPUTLOOP loop. It outputs the \n character on the console so that the console skips a line so the user can see that the next number will be ready to input
	AND R0, R0, #0		;  load the value ...
	ADD R0, R0, #10 	;   ... of 10 into R0 and output it to the console ... 
	OUT			;	... this will skip a line in the console since the ASCII value of \n is 10

	;at this point, the user has entered a number and we have calculated the correct value of it and stored that value into our array
	;these last 2 lines decrement out INPUTLOOP loop counter and then checks if it's equal to 0. If it IS NOT, then we branch all the way up to the beginning of the loop again to start on inputting a new number.
	;if it IS, then that means we have successfully taken all 8 numbers from the user and can break out of the loop and move on with the algorithm
	ADD R1, R1, #-1	;decrement R1 
	BRp INPUTLOOP	;while R1 is still greater than 0, branch again to the beginiing of INPUTLOOP

;NEXT SECTION OF CODE STARTS HERE

	

	HALT



;;;;;;;;;;;;;;;;;;;;;
;;;;;SUBROUTINES;;;;;
;;;;;;;;;;;;;;;;;;;;;

VALIDATE ;takes the ASCII value stored in TEMP determines if it is a digit. Returns the digit in R3. If it's not a digit, halts the program.
	ST R1, SAVE_R1	
	ST R2, SAVE_R2 ;save registers

	LD R1, TEMP		;load TEMP into R1. This is the value to be validated
	ADD R1, R1, #-16
	ADD R1, R1, #-16
	ADD R1, R1, #-16   	;subtract 48 from the value to get its true value

	BRn INVALID_DIGIT 	;if the value is negative it is invalid
	ADD R1, R1, #-9		;subtract 9 from R1. If the outcome is positive, the number is larger than 9 which makes it invalid
	BRp INVALID_DIGIT
	
	;if the digit IS valid. Add 9 back to it in order to revert to the true value. We will return this value in R3
	ADD R1, R1, #9	;add 9 to it
	AND R3, R3, #0
	ADD R3, R1, R3	;clear R3 and store R1 into it

	LD R1, SAVE_R1
	LD R2, SAVE_R2	;reload registers
	RET		;return to main

        INVALID_DIGIT	;if the digit is determined to be invalid 
	LEA R0, INVALID	;load the INVALID string into R0
	PUTS		;display from R0
	HALT		;stop the program
PUSH ;pushes the number in R3 onto the stack. If the stack is full, a stack overflow error occurs and the program is halted.
	ST R1, SAVE_R1	
	ST R2, SAVE_R2 ;save registers

	AND R4, R4, #0		;clear R4 for use in the subroutine

	LD R1, STACK_COUNT	;load the current stack count into R2
	ADD R1, R1, #-8		;to check the stack count
	BRz STACK_OVERFLOW	;if the stack count is 8, an overflow will occur
	LD R1, STACK_COUNT	;load stack count back into R1
	NOT R1, R1	
	ADD R1, R1, #1		;to get the negative of the stack count
	LD R2, STACK_BASE	;load the base address of the stack into R1
	ADD R4, R1, R2		;add STACK_BASE to STACK_COUNT and store in R4. This is the address to store R3 to

	STR R3, R4, #0		;store the number in R3 to the location pointed to by R4. It has now been pushed onto the stack
	LD R1, STACK_COUNT	;load the stack count back into R2
	ADD R1, R1, #1		;increment stack count
	ST R1, STACK_COUNT	;store new stack count

	LD R1, SAVE_R1
	LD R2, SAVE_R2	;reload registers
	RET		;return to main

        STACK_OVERFLOW		;this means the stack count is 8 which means this PUSH call will overflow the stack 
	LEA R0, OVERFLOW 	;load the OVERFLOW string into R0
	PUTS		 	;display from R0
	HALT		 	;stop the program
POP ;pop off the value at the top of the stack and return it in R3
	ST R1, SAVE_R1	
	ST R2, SAVE_R2
	ST R4, SAVE_R4 ;save registers

	LD R1, STACK_COUNT	;load the stack count into R1
	NOT R1, R1	
	ADD R1, R1, #1		;to get the negative of the stack count. 
	LD R2, STACK_BASE	;load the base address of the stack into R2

	ADD R4, R1, R2		;add STACK_BASE to STACK_COUNT and store in R4. 
	ADD R4, R4, #1		;Add 1 again to the sum. This is the address to POP from. The next line will use it to POP from the stack and store the value in R3
	LDR R3, R4, #0		;load the value being pointed to by R4 into R3 

	LD R1, STACK_COUNT 	;load STACKCOUNT to be decremented and stored back again with its new, decremented value
	ADD R1, R1, #-1	
	ST R1, STACK_COUNT	
	
	LD R1, SAVE_R1
	LD R4, SAVE_R4
	LD R2, SAVE_R2	;reload registers
	RET		;return to main
TIMES_100 ;takes the value in R3 and returns that value * 100 in R3
	ST R1, SAVE_R1	
	ST R2, SAVE_R2 ;save registers	
	
	ADD R3, R3, #0		;to check if R3 is 0. 
	BRz SKIP_TIMES_100 	;if it is, then skip the code below and just return with 0 still in R3

	LD R1, HUNDRED		;load the value of 100(x64) into R1
	AND R2, R2,#0		;clear R2
	TIMES_100_LOOP		;this loop will add 100 to itself multiple times. The loop counter is R3
	ADD R2, R2, R1		;add R1 to itself and store in R2
	ADD R3, R3, #-1		;decrement R3
	BRp TIMES_100_LOOP	;repeat again if R3 is greater than 0
	ADD R3, R2, #0		;copy R2 over to R3. Will return with the new value in R3

       SKIP_TIMES_100
	LD R1, SAVE_R1
	LD R2, SAVE_R2	;reload registers
	RET		;return to main
TIMES_10 ;takes the value in R3 and returns that value * 10 in R3
	ST R1, SAVE_R1	
	ST R2, SAVE_R2 ;save registers	
	
	ADD R3, R3, #0		;to check if R3 is 0. 
	BRz SKIP_TIMES_10 	;if it is, then skip the code below and just return with 0 still in R3

	LD R1, TEN		;load the value of 10(xA) into R1
	AND R2, R2,#0		;clear R2
	TIMES_10_LOOP		;this loop will add 10 to itself multiple times. The loop counter is R3
	ADD R2, R2, R1		;add R1 to itself and store in R2
	ADD R3, R3, #-1		;decrement R3
	BRp TIMES_10_LOOP 	;repeat again if R3 is greater than 0
	ADD R3, R2, #0		;copy R2 over to R3. Will return with the new value in R3

       SKIP_TIMES_10
	LD R1, SAVE_R1
	LD R2, SAVE_R2	;reload registers
	RET		;return to main


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;VARIABLES/LABELS;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

TEMP	.FILL x0
SAVE_R1	.FILL x0
SAVE_R2	.FILL X0
SAVE_R4	.FILL X0

HUNDRED	.FILL x64 	;just the value of 100 in hex. It is used with the TIMES_100 sub routine
TEN	.FILL xA  	;just the value of 10 in hex. It is used with the TIMES_10 sub routine

NUMBERS_ARRAY 	  .FILL x4050 	;the address of the first element in the array that will hold the 8 numbers
NUMBERS_ARRAY_END .FILL x4057 	;the address of the last element in of the array that will hold the 8 numbers

STACK_COUNT 	.FILL x0	;to keep track of how many things are on the stack
STACK_BASE 	.FILL x4107	;the base adress of the stack

PROMPT		.STRINGZ "Please input 8 numbers from 0-999. Press enter after each number: \n" ;display on program start
INVALID 	.STRINGZ "\nINVALID INPUT ... HALTING PROGRAM\n"				;display on invalid input from user
OVERFLOW 	.STRINGZ "\nSTACK OVERFLOW ERROR ... HALTING PROGRAM\n"				;display on stack overflow error

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;END;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

.END