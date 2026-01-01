        ;========================================================
        ; EXPORTS (for Keil Watch)
        ;========================================================
        EXPORT  A
        EXPORT  B
        EXPORT  OPCODE
        EXPORT  RESULT
        EXPORT  FLAGS
        EXPORT  CMP_OUT

        EXPORT  main
        EXPORT  ALU_Step        ; function that executes ALU once


;========================================================
; MAIN SECTION — like your CheckThresholds test loop
;========================================================
        AREA    MAIN_CODE, CODE, READONLY, ALIGN=2

main
loop_main
        BL      ALU_Step        ; run ALU once using A, B, OPCODE
        B       loop_main       ; keep looping so debugger can inspect



;========================================================
; ALU MODULE
;========================================================
        AREA    ALU_CODE, CODE, READONLY, ALIGN=2

;-------------------------------------------------------
; void ALU_Step(void)
;   Uses global A, B, OPCODE
;   Writes RESULT, FLAGS, CMP_OUT
;-------------------------------------------------------
ALU_Step
        PUSH    {R4-R11, LR}

        ;--------------------------------------
        ; Load addresses
        ;--------------------------------------
        LDR     R0, =A
        LDR     R1, =B
        LDR     R2, =OPCODE
        LDR     R6, =RESULT
        LDR     R7, =FLAGS
        LDR     R8, =CMP_OUT

        ; Load actual values
        LDR     R3, [R0]          ; A
        LDR     R4, [R1]          ; B
        LDR     R5, [R2]          ; OPCODE

        ; (NO 16-bit MASK ANYMORE)


;========================================================
; DECODER
;========================================================
        CMP     R5, #0
        BEQ     ALU_ADD
        CMP     R5, #1
        BEQ     ALU_SUB
        CMP     R5, #2
        BEQ     ALU_INC
        CMP     R5, #3
        BEQ     ALU_DEC
        CMP     R5, #4
        BEQ     ALU_ADC
        CMP     R5, #5
        BEQ     ALU_SBB

        CMP     R5, #6
        BEQ     ALU_AND
        CMP     R5, #7
        BEQ     ALU_OR
        CMP     R5, #8
        BEQ     ALU_XOR
        CMP     R5, #9
        BEQ     ALU_NOT
        CMP     R5, #10
        BEQ     ALU_NAND
        CMP     R5, #11
        BEQ     ALU_NOR

        CMP     R5, #12
        BEQ     SHIFT_LSL
        CMP     R5, #13
        BEQ     SHIFT_LSR
        CMP     R5, #14
        BEQ     SHIFT_ASL
        CMP     R5, #15
        BEQ     SHIFT_ASR
        CMP     R5, #16
        BEQ     SHIFT_ROL
        CMP     R5, #17
        BEQ     SHIFT_ROR

        CMP     R5, #18
        BEQ     BARREL_SHIFT

        CMP     R5, #19
        BEQ     BOOTH_MUL

        CMP     R5, #20
        BEQ     COMPARATOR

        CMP     R5, #21
        BEQ     PARITY_CHECK

        B       ALU_EXIT         ; invalid opcode ? do nothing


;========================================================
; 1. ARITHMETIC
;========================================================
ALU_ADD
        ADDS    R9, R3, R4
        B       STORE_RESULT

ALU_SUB
        SUBS    R9, R3, R4
        B       STORE_RESULT

ALU_INC
        ADDS    R9, R3, #1
        B       STORE_RESULT

ALU_DEC
        SUBS    R9, R3, #1
        B       STORE_RESULT

; Add with carry (carry-in from FLAGS bit0)
ALU_ADC
        LDR     R10, [R7]
        AND     R10, R10, #1
        ADCS    R9, R3, R4
        ADC     R9, R9, R10
        B       STORE_RESULT

; Sub with borrow (borrow from FLAGS bit0)
ALU_SBB
        LDR     R10, [R7]
        AND     R10, R10, #1
        SBCS    R9, R3, R4
        SBC     R9, R9, R10
        B       STORE_RESULT


;========================================================
; 2. LOGICAL
;========================================================
ALU_AND
        AND     R9, R3, R4
        B       STORE_RESULT

ALU_OR
        ORR     R9, R3, R4
        B       STORE_RESULT

ALU_XOR
        EOR     R9, R3, R4
        B       STORE_RESULT

ALU_NOT
        MVN     R9, R3
        B       STORE_RESULT

ALU_NAND
        AND     R9, R3, R4
        MVN     R9, R9
        B       STORE_RESULT

ALU_NOR
        ORR     R9, R3, R4
        MVN     R9, R9
        B       STORE_RESULT


;========================================================
; 3. SHIFTS / ROTATES (B[3:0] = shift amount)
;========================================================
SHIFT_LSL
        AND     R4, R4, #0xF
        LSL     R9, R3, R4
        B       STORE_RESULT

SHIFT_LSR
        AND     R4, R4, #0xF
        LSR     R9, R3, R4
        B       STORE_RESULT

SHIFT_ASL
        AND     R4, R4, #0xF
        LSL     R9, R3, R4
        B       STORE_RESULT

SHIFT_ASR
        AND     R4, R4, #0xF
        ASR     R9, R3, R4
        B       STORE_RESULT

; Rotate left: (A<<n) | (A>>(16-n))
SHIFT_ROL
        AND     R4, R4, #0xF
        CMP     R4, #0
        BEQ     ROL_ZERO

        MOVS    R10, #16
        SUB     R10, R10, R4     ; 16-n -> R10
        LSL     R9, R3, R4       ; temp1 = A<<n
        LSR     R11, R3, R10     ; temp2 = A>>(16-n)
        ORR     R9, R9, R11
        B       STORE_RESULT

ROL_ZERO
        MOV     R9, R3
        B       STORE_RESULT

; Rotate right using ROR
SHIFT_ROR
        AND     R4, R4, #0xF
        CMP     R4, #0
        BEQ     ROR_ZERO

        ROR     R9, R3, R4
        B       STORE_RESULT

ROR_ZERO
        MOV     R9, R3
        B       STORE_RESULT


;========================================================
; 4. BARREL SHIFTER
;========================================================
BARREL_SHIFT
        AND     R4, R4, #0xF
        LSL     R9, R3, R4
        B       STORE_RESULT


;========================================================
; 5. MULTIPLY (placeholder instead of full Booth)
;========================================================
BOOTH_MUL
        MUL     R9, R3, R4
        B       STORE_RESULT


;========================================================
; 6. COMPARATOR (CMP_OUT: 0001>, 0010==, 0100<)
;========================================================
COMPARATOR
        CMP     R3, R4
        BEQ     CMP_EQ
        BHI     CMP_GT
        BLO     CMP_LT

CMP_GT
        MOV     R9, #1
        STR     R9, [R8]
        B       ALU_EXIT

CMP_EQ
        MOV     R9, #2
        STR     R9, [R8]
        B       ALU_EXIT

CMP_LT
        MOV     R9, #4
        STR     R9, [R8]
        B       ALU_EXIT


;========================================================
; 7. PARITY CHECK (1 = even, 0 = odd) on A
;========================================================
PARITY_CHECK
        MOV     R10, R3
        MOV     R11, #0

PARITY_LOOP
        TST     R10, #1
        EOR     R11, R11, #1
        LSR     R10, R10, #1
        CMP     R10, #0
        BNE     PARITY_LOOP

        STR     R11, [R6]        ; store parity in RESULT
        B       ALU_EXIT


;========================================================
; STORE RESULT + FLAGS
;========================================================
STORE_RESULT
        ; ***** MASK REMOVED: full 32-bit result stored *****
        STR     R9, [R6]

        MRS     R10, APSR
        STR     R10, [R7]

        B       ALU_EXIT


;========================================================
; EXIT FROM FUNCTION
;========================================================
ALU_EXIT
        POP     {R4-R11, PC}



;========================================================
; DATA SECTION (same style as ALERT_DATA)
;========================================================
        AREA    ALU_DATA, DATA, READWRITE, ALIGN=2

A           DCD     0x1234      ; you can edit in Watch
B           DCD     0x00F3
OPCODE      DCD     0           ; default: ADD
RESULT      DCD     0
FLAGS       DCD     0
CMP_OUT     DCD     0

        END
