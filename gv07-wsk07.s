.section .data
   heap_begin:    .long 0
   current_break: .long 0
   pointer:       .long 0
   str:           .string "Entrei\n"
   str1:          .string "---------\nInicio bss: %p\n"
   str2:          .string "Segmento %d: %.3d bytes livres\n"
   str3:          .string "Segmento %d: %.3d bytes ocupados\n"
   str4:          .string "Segmentos livres: %d / %d bytes\n"
   str5:          .string "Segmentos ocupados: %d / %d bytes\n---------\n"
   .equ UNAVAILABLE, 0  
   .equ AVAILABLE, 1    
   .equ BRK, 45         
   .equ LINUX_SYSCALL, 0x80 
   .equ HEADER_SIZE, 12
   .equ HDR_AVAIL_OFFSET, 0 
   .equ HDR_SIZE_OFFSET, 4 
   .equ HDR_PTR_OFFSET, 8 
.section .text
.globl allocate_init
.type allocate_init,@function
allocate_init:
   pushl %ebp                  
   movl  %esp, %ebp
  
#salvando os registradores
   pushl %ebx
   pushl %ecx
   pushl %edx
# 
   
   movl $BRK, %eax            
   movl $0, %ebx
   int  $LINUX_SYSCALL

   incl %eax
   movl %eax, current_break   
   movl %eax, heap_begin  
   movl %eax, pointer 

#restaurando registradores         
   popl %edx
   popl %ecx
   popl %ebx
#  
   
   movl %ebp, %esp           
   popl %ebp
   ret

.globl reallocate 
.type  reallocate,@function
reallocate:
   pushl %ebp                
   movl  %esp, %ebp

#salvando os registradores
   pushl %eax
   pushl %ebx
   pushl %ecx
   pushl %edx
#
   movl 12(%ebp),%ebx

   pushl %ebx
   call deallocate
   addl $4,%esp
   
   pushl 8(%ebp)
   call allocate
   addl $4,%esp

   popl %edx
   popl %ecx
   popl %ebx

   popl %ebp
   movl %ebp, %esp
   ret

.globl allocate 
.type  allocate,@function
.equ   ST_MEM_SIZE, 8         
allocate:
   pushl %ebp                
   movl  %esp, %ebp
   subl  $8,%esp
#salvando os registradores
   pushl %ebx
   pushl %ecx
   pushl %edx
#  

#chamando allocate_init   
   movl heap_begin, %eax
   cmpl $0, %eax
   je   aloc
   
   jmp fim_aloc
   aloc:
      call allocate_init
   fim_aloc:   
#

   movl ST_MEM_SIZE(%ebp), %ecx 
   movl heap_begin, %eax      
   movl current_break, %ebx   

   alloc_loop_begin:          
      cmpl %ebx, %eax          
      je   move_break

      movl HDR_SIZE_OFFSET(%eax), %edx
      cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) 
      je   next_location        

      cmpl %edx, %ecx          
      jle  allocate_here         

      next_location:
         addl $HEADER_SIZE, %eax     
         addl %edx, %eax             
         jmp  alloc_loop_begin      

      allocate_here:       
         subl %ecx, %edx
         
         cmpl $HEADER_SIZE, %edx
         jle  else2 

#         movl %eax, -8(%ebp)

#         movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)  
#         movl %ecx, HDR_SIZE_OFFSET(%eax)

#         addl HDR_SIZE_OFFSET(%eax), %eax
#         addl $HEADER_SIZE, %eax
               
#         subl $HEADER_SIZE, %edx
         
#         movl %edx, HDR_SIZE_OFFSET(%eax)
#         movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
#         movl -8(%ebp),%edx
#         movl %edx,HDR_PTR_OFFSET(%eax)
       
#         movl %eax,-4(%ebp)
          
#         addl HDR_SIZE_OFFSET(%eax),%eax
#         addl $HEADER_SIZE,%eax
             
#         movl -4(%ebp),%edx
#         movl %edx,HDR_PTR_OFFSET(%eax)
           
#         movl -8(%ebp),%eax
#         jmp  end
        
        else2:
            movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
            addl $HEADER_SIZE, %eax

        end:

#restaurando registradores         
         popl %edx
         popl %ecx
         popl %ebx
#        

         addl $8,%esp
         movl %ebp, %esp         
         popl %ebp
         ret

      move_break:                      
         addl $HEADER_SIZE, %ebx 
         addl %ecx, %ebx         

         pushl %eax               
         pushl %ecx
         pushl %ebx

         movl $BRK, %eax         
         int  $LINUX_SYSCALL     
         cmpl $0, %eax           
         je   error

         popl %ebx               
         popl %ecx
         popl %eax


         movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax) 
         movl %ecx, HDR_SIZE_OFFSET(%eax) 
         
         movl heap_begin,%ecx
         cmpl %ecx,current_break
         jne  else
         
         movl $0, HDR_PTR_OFFSET(%eax)
         jmp  fim
         
         else:
         movl pointer,%ecx
         movl %ecx,HDR_PTR_OFFSET(%eax)
         movl current_break,%ecx
         movl %ecx,pointer

         fim:

         addl $HEADER_SIZE, %eax
         movl %ebx,current_break

#restaurando registradores
         popl %edx
         popl %ecx
         popl %ebx
#
         
         addl $8,%esp
         movl %ebp, %esp            
         popl %ebp
         ret

      error:
         movl $0, %eax    
         
#restaurando registradores
         popl %edx
         popl %ecx
         popl %ebx
#         

         addl $8,%esp
         movl %ebp, %esp
         popl %ebp
         ret

.globl concate 
.type  concate,@function
concate:
   
   pushl %ebp                
   movl  %esp, %ebp

#salvando os registradores
   pushl %ebx
   pushl %ecx
   pushl %edx
#
   movl heap_begin,%eax
   movl heap_begin,%ebx

while3:
   cmpl current_break,%eax
   je final

   cmpl $AVAILABLE,HDR_AVAIL_OFFSET(%eax)
   jne fim_while

   addl HDR_SIZE_OFFSET(%eax),%eax
   addl $HEADER_SIZE,%eax
   
   cmpl $AVAILABLE,HDR_AVAIL_OFFSET(%eax)
   jne fim_while

   movl HDR_SIZE_OFFSET(%eax),%ecx
   addl HDR_SIZE_OFFSET(%ebx),%ecx
   addl $HEADER_SIZE,%ecx
   movl %ecx,HDR_SIZE_OFFSET(%ebx)
   addl HDR_SIZE_OFFSET(%eax),%eax
   addl $HEADER_SIZE,%eax
   movl %ebx,HDR_PTR_OFFSET(%eax)

   fim_while:
   addl HDR_SIZE_OFFSET(%eax),%eax
   addl $HEADER_SIZE,%eax
   movl %eax,%ebx
   
   jmp while3
   
   final:
   
   popl %edx
   popl %ecx
   popl %ebx

   movl %ebp, %esp
   popl %ebp
   ret

   
.globl deallocate
.type  deallocate,@function
.equ   ST_MEMORY_SEG, 8      
deallocate:
   pushl %ebp                
   movl  %esp, %ebp
    
#salvando os registradores
   pushl %eax
   pushl %ebx
   pushl %ecx
   pushl %edx
#  
   movl ST_MEMORY_SEG(%ebp), %eax 
   subl $HEADER_SIZE, %eax   
   movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax) 
   
   movl pointer, %ebx
   movl HDR_AVAIL_OFFSET(%ebx),%ecx
   
   loop:
      cmpl $AVAILABLE,%ecx
      jne  f
      movl %ebx,current_break
            
      pushl %eax               
      pushl %ecx
      pushl %ebx

      movl $BRK, %eax         
      int  $LINUX_SYSCALL     

      popl %ebx               
      popl %ecx
      popl %eax
     
      cmpl $0,HDR_PTR_OFFSET(%ebx)
      je   f

      movl HDR_PTR_OFFSET(%ebx),%ebx
      movl %ebx,pointer
      movl HDR_AVAIL_OFFSET(%ebx),%ecx
      
      jmp loop

   f:
   
   call concate
   call concate
      
#restaurando registradores
   popl %edx
   popl %ecx
   popl %ebx
   popl %eax
#         

   movl %ebp, %esp
   popl %ebp
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

#salvando os registradores
   pushl %eax
   pushl %ebx
   pushl %ecx
   pushl %edx
# 

   movl $1, -4(%ebp);
   movl heap_begin, %ecx
   movl %ecx, -8(%ebp)       # ecx jah era!!!! -1
   movl $0, -12(%ebp);
   movl $0, -16(%ebp);
   movl $0, -20(%ebp);
   movl $0, -24(%ebp);
  
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

                pushl HDR_SIZE_OFFSET(%ecx)
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

                pushl HDR_SIZE_OFFSET(%ecx)
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
              movl -8(%ebp), %ecx
              jmp while

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
      
#restaurando registradores
         popl %edx
         popl %ecx
         popl %ebx
         popl %eax
#   
      
      addl  $24, %esp
      popl %ebp

      ret
      

