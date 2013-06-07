.section .data
   heap_begin:    .long 0
   current_break: .long 0
   str1:          .string "---------\nInicio bss: %p\n"
   str2:          .string "Segmento %d: %.3d bytes ocupados\n"
   str3:          .string "Segmento %d: %.3d bytes livres\n"
   str4:          .string "Segmentos ocupados: %d / %d bytes\n"
   str5:          .string "Segmentos livres: %d / %d bytes\n---------\n"
   .equ UNAVAILABLE, 0  
   .equ AVAILABLE, 1    
   .equ BRK, 45         
   .equ LINUX_SYSCALL, 0x80 
   .equ HEADER_SIZE, 8
   .equ HDR_AVAIL_OFFSET, 0 
   .equ HDR_SIZE_OFFSET, 4 
.section .text
.globl allocate_init
.type allocate_init,@function
allocate_init:
   pushl %ebp                  
   movl  %esp, %ebp

   movl  $BRK, %eax            
   movl  $0, %ebx
   int   $LINUX_SYSCALL

   incl  %eax                  
   
   movl  %eax, current_break   
   movl  %eax, heap_begin     
   
   movl  %ebp, %esp           
   popl  %ebp
   ret

.globl allocate 
.type  allocate,@function
.equ   ST_MEM_SIZE, 8         
allocate:
   pushl %ebp                
   movl  %esp, %ebp
   movl  ST_MEM_SIZE(%ebp), %ecx 
   movl  heap_begin, %eax      
   movl  current_break, %ebx   

   alloc_loop_begin:          
      cmpl  %ebx, %eax          
      je    move_break

      movl  HDR_SIZE_OFFSET(%eax), %edx 
      cmpl  $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) 
      je    next_location        

      cmpl  %edx, %ecx          
      jle   allocate_here         

      next_location:
         addl $HEADER_SIZE, %eax     
         addl %edx, %eax             
         jmp  alloc_loop_begin      

      allocate_here:                      
         movl  $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)  
         addl  $HEADER_SIZE, %eax 
         movl  %ebp, %esp         
         popl  %ebp
         ret

      move_break:                      
         addl  $HEADER_SIZE, %ebx 
         addl  %ecx, %ebx         

         pushl %eax               
         pushl %ecx
         pushl %ebx

         movl  $BRK, %eax         
         int   $LINUX_SYSCALL     
         cmpl  $0, %eax           
         je    error

         popl  %ebx               
         popl  %ecx
         popl  %eax

         movl  $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) 
         movl  %ecx, HDR_SIZE_OFFSET(%eax) 
         addl  $HEADER_SIZE, %eax    
         movl  %ebx, current_break   

         movl  %ebp, %esp            
         popl  %ebp
         ret

      error:
         movl $0, %eax              
         movl %ebp, %esp
         popl %ebp
         ret

.globl deallocate
.type  deallocate,@function
.equ   ST_MEMORY_SEG, 4      

deallocate:
   movl  ST_MEMORY_SEG(%esp), %eax 
   subl  $HEADER_SIZE, %eax   
   movl  $AVAILABLE, HDR_AVAIL_OFFSET(%eax)   
   ret  

.globl imprMapa
.type  imprMapa,@function
imprMapa:
   pushl %ebp
   movl  %esp, %ebp

   subl  $24, %esp    #i           = -4(%ebp)
                      #size        = -8(%ebp)
                      #mem_livre   = -12(%ebp)
                      #segs_livres = -16(%ebp)
                      #mem_ocup    = -20(%ebp)
                      #segs_ocups  = -24(%ebp)

   movl  $1, -4(%ebp);
   movl  heap_begin, %ecx
   movl  %ecx, -8(%ebp)       # ecx jah era!!!! -1
   movl  $0, -12(%ebp);
   movl  $0, -16(%ebp);
   movl  $0, -20(%ebp);
   movl  $0, -24(%ebp);
  
   pushl %ecx
   
   pushl heap_begin 
   pushl $str1
   call  printf
   addl  $8, %esp

   popl %ecx

   while: cmpl %ecx, current_break  
          je end_while
          
      if_unav:  cmpl  $AVAILABLE, HDR_AVAIL_OFFSET(%ecx) 
                je if_avail

                pushl %ecx

                pushl $HDR_SIZE_OFFSET
                pushl -4(%ebp)
                pushl $str3
                call printf
                addl $12, %esp

                popl %ecx

                movl -12(%ebp), %eax
                addl HDR_SIZE_OFFSET(%ecx), %eax
                movl %eax, -12(%ebp)
                addl $1, -16(%ebp)
                jmp fim_if
          
      if_avail: pushl %ecx

                pushl $HDR_SIZE_OFFSET
                pushl -4(%ebp)
                pushl $str2
                call printf
                addl $12, %esp

                popl %ecx

                movl -20(%ebp), %eax
                addl HDR_SIZE_OFFSET(%ecx), %eax
                movl %eax, -20(%ebp)
                addl $1, -24(%ebp)
           
      fim_if: movl HDR_SIZE_OFFSET(%ecx), %eax
              addl $HEADER_SIZE, %eax
              addl %eax, -8(%ebp)

              addl $1, -4(%ebp)
              addl -8(%ebp), %ecx

   end_while:
      pushl -20(%ebp)
      pushl -24(%ebp)
      pushl $str4
      call printf
      addl $12, %esp
     
      pushl -12(%ebp)
      pushl -16(%ebp)
      pushl $str5
      call printf
      addl $12, %esp

      addl  $24, %esp
      popl %ebp

      ret
