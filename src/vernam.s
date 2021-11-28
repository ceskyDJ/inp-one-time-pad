; One-time pad on DLX architecture (2nd project to INP)
; 
; Author: Michal Šmahel xsmahe01
; Registers: xsmahe01-r1-r9-r16-r21-r26-r0

        .data 0x04          ; Data segment address start in memory
login:  .asciiz "xsmahe01"
cipher: .space 9            ; Memory space for storing result (must end with \0)

        .align 2            ; Align to 2^2 B
laddr:  .word login         ; 4B address of input text (for printing)
caddr:  .word cipher        ; 4B address of result cipher (pro printing)

        .text 0x40          ; Code segment address start in memory
        .global main        ; Set main method name (label, resp.)

        ; Count alphabet position of the 1st char
main:   lb r1, login+1
        subi r1, r1, 96

        ; Count alphabet position of the 2nd char
        lb r9, login+2
        subi r9, r9, 96

        ; Prepare counter for cycle
        addi r26, r0, 0

        ; Substitution cycle
cycle:  lb r16, login(r26)
        sgei r21, r16, 97
        beqz r21, done

        ; Odd or even char?
        add r21, r0, r26
        andi r21, r21, 1
        beqz r21, even
        nop

        ; Negative substitution (by subtracting constact)
        sub r16, r16, r9

        ; Resolve underflow (< a --> z - ...)
        slti r21, r16, 97
        beqz r21, ok
        nop
        addi r16, r16, 26
        j ok
        nop

        ; Positive substitution (by adding constant)
even:   add r16, r16, r1

        ; Resolve overflow (> z --> a + ...)
        sgti r21, r16, 122
        beqz r21, ok
        nop
        subi r16, r16, 26

        ; Save result char to the output
ok:     sb cipher(r26), r16

        ; Increment counter
        addi r26, r26, 1

        ; Jump to the start of the cycle
        j cycle

        ; Add zero char (\0) to the end of created string
done:   sb cipher+6, r0

end:    addi r14, r0, caddr ; Set address of output to r14 register (see next line)
        trap 5  ; Print string stored at address from r14 register
        trap 0  ; End of simulation
