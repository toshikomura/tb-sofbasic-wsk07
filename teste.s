.section .data
   heap_begin:    .long 0
   current_break: .long 0
   pointer:       .long 0
   .equ UNAVAILABLE, 0  
   .equ AVAILABLE, 1    
   .equ BRK, 45         
   .equ LINUX_SYSCALL, 0x80 
   .equ HEADER_SIZE, 12
   .equ HDR_AVAIL_OFFSET, 0 
   .equ HDR_SIZE_OFFSET, 4 
   .equ HDR_PTR_OFFSET, 8 
.section .text
.globl realloc
.type realloc,@function

   pushl %ebp
   movl %esp,%ebp
   
   pushl %ebx
   pushl %ecx
   pushl %edx

   subl $12,%esp

   movl 12(%ebp),%ebx #tamanho novo
   movl 8(%ebp),%eax  #pointeiro
   movl HDR_SIZE_OFFSET(%eax),-4(%ebp) #tamanho do atual
   movl HDR_SIZE_OFFSET(%eax),-8(%ebp) #inicializando tamanho
   movl %eax,-12(%ebp) #salvando ponteiro
   movl %eax,%ecx
   
   loop:
      addl HDR_SIZE_OFFSET(%ecx),%ecx
      addl $12,%ecx
      cmpl current_break,%ecx
      je else
      movl HDR_AVAIL_OFFSET(%ecx),%edx
      cmpl $UNAVAILABLE,%edx
      je else
      movl HDR_SIZE_OFFSET(%ecx),%edx
      addl -8(%ebp),%edx
      addl $12,%edx
      movl %edx,-8(%ebp)
      cmpl %edx,%ebx
      jg loop
         subl  %ebx,%edx
         
         cmpl  $HEADER_SIZE,%edx
         jl else2 #o tamanho he menor entao nao faz nada
         #aqui atualiza o tam da cxa
            
         movl  $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)  
         movl  %ecx, HDR_SIZE_OFFSET(%eax)
         
         addl  HDR_SIZE_OFFSET(%eax), %eax
         addl  $HEADER_SIZE, %eax
               
         subl  $HEADER_SIZE, %edx

         movl  %edx, HDR_SIZE_OFFSET(%eax)
         movl  $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
         movl  -12(%ebp),%edx
         movl  %edx,HDR_PTR_OFFSET(%eax)
               
         movl  %eax,-4(%ebp)
         addl  HDR_SIZE_OFFSET(%eax),%eax
         addl  $HEADER_SIZE,%eax
               
         movl  -4(%ebp),%edx
         movl  %edx,HDR_PTR_OFFSET(%eax)
             
         movl  -8(%ebp),%eax
         jmp end
         
        else2:
            movl  $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
            movl  %ecx,HDR_SIZE_OFFSET(%eax)
            addl  $HEADER_SIZE, %eax

        end:
         #restaurar os registradores e retornar
   
   else:
      movl %eax,%ecx
      if:

      movl HDR_PTR_OFFSET(%ecx),%ecx
      cmpl $0,%ecx
      je fim:
      movl HDR_AVAIL_OFFSET(%ecx),%edx
      cmpl $AVAILABLE,%edx
      jne fim
      movl HDR_SIZE_OFFSET(%ecx),%edx
      addl -8(%ebp),%edx
      movl %edx,-8(%ebp)
      cmpl %edx,%ebx
      jg if

      #igual ao do allocate_here
      #mas precisa copiar pra baixo

      jmp fim
   
   fim:
      cmpl %eax,pointer
      je fim2
      addl HEADER_SIZE,%ebx
      pushl %eax
      pushl %ebx
      pushl %ecx
      pushl %edx
         
         movl $BRK,%eax
         int $LINUX_SYSCALL
         cmpl $0,%eax
         je erro

      popl %eax
      popl %edx
      popl %ecx
      popl %ebx

      movl current_break,%edx  
      movl $UNAVAILABLE,HDR_AVAIL_OFFSET(%edx)
      movl %ebx,4(%edx)
      movl pointer,8(%edx)
      movl %edx,pointer
      addl %ebx,current_break
      
      movl %eax,%ebx
      addl HDR_SIZE_OFFSET(%eax),%ebx
      addl $12,%ebx #final
      addl $12,%eax #comeco
      
      laco:
         cmpl %ebx,%eax
         je fi
         movl (%eax),%ecx
         movl %ecx,(%edx)
         incl %eax
         incl %edx
         jmp loop
      

      fim2:
         subl -4(%ebp),%ebx
         pushl %eax
         pushl %ebx
         pushl %ecx
         pushl %edx
         
         movl $BRK,%eax
         int $LINUX_SYSCALL
         cmpl $0,%eax
         je erro

         popl %eax
         popl %edx
         popl %ecx
         popl %ebx

         addl -4(%ebp),%ebx
         movl %ebx,HDR_SIZE_OFFSET(%eax)
      fi:
      
      movl pointer,%eax
      addl $12,%esp
      popl %edx
      popl %ecx
      popl %ebx

      movl %ebp,%esp
      popl %ebp
      ret

