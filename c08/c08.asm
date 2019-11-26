         ;�����嵥8-2
         ;�ļ�����c08.asm
         ;�ļ�˵�����û����� 
         ;�������ڣ�2011-5-5 18:17
         
;===============================================================================
;�����ͷ������������������ܳ��ȣ��������ʼ��ַ��
SECTION header vstart=0                     ;�����û�����ͷ���� 
    ;dd data dword ռ4���ֽڵĳ���
    ;dw data word ռ2���ֽڵĳ���
    program_length  dd program_end          ;���峤�ȣ����ڿ�ͷ��ͨ��[0x00]�����ܳ���,���program_end��ʾ�������Ŷ����ڳ���Ľ�β��
    
    ;startλ�ڶ�code_1�ڣ����ǲ�������ʼλ��
    code_entry      dw start                ;ƫ�Ƶ�ַ[0x04]
                    dd section.code_1.start ;�ε�ַ[0x06] 
    ;�䶨λ��ĳ���
    realloc_tbl_len dw (header_end-code_1_segment)/4 ;���ض�λ�������[0x0a]
    
    ;���ض�λ��           
    code_1_segment  dd section.code_1.start ;[0x0c]
    code_2_segment  dd section.code_2.start ;[0x10]
    data_1_segment  dd section.data_1.start ;[0x14]
    data_2_segment  dd section.data_2.start ;[0x18]
    stack_segment   dd section.stack.start  ;[0x1c]
    
    header_end:                
    
;===============================================================================
SECTION code_1 align=16 vstart=0         ;��������1��16�ֽڶ��룩 
put_string:                              ;��ʾ��(0��β)��
                                         ;���룺DS:BX=����ַ
         mov cl,[bx]
         or cl,cl                        ;cl=0 ?
         ;cmp cl,0
         ;cmp cl,999
         jz .exit                        ;�ǵģ����������� 
         call put_char
         inc bx                          ;��һ���ַ� 
         jmp put_string

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;��ʾһ���ַ�
                                         ;���룺cl=�ַ�ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;����ȡ��ǰ���λ��
         mov dx,0x3d4			 ;�����Ĵ����˿�0x3d4
         mov al,0x0e			 ;�ṩ���ĸ�8λ
         out dx,al
         mov dx,0x3d5			 ;��д�Ĵ���
         in al,dx                        ;��8λ������al�� 
         
         mov ah,al			 ;��al�е����ݷŵ�ah��

         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;��õĵ�8λ����al�У�ahû�б仯��������ax�ͱ�ʾ���λ�� 
         mov bx,ax                       ;BX=������λ�õ�16λ��

	 ;����س��ͻ��з�
         cmp cl,0x0d                     ;�س����������������ת��put_0a
         jnz .put_0a                     ;���ǡ������ǲ��ǻ��е��ַ� 
         mov ax,bx                       ;�˾����Զ��࣬��ȥ���󻹵ø��飬�鷳 
         mov bl,80                       
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

 .put_0a:
         cmp cl,0x0a                     ;���з���������ǻ��з�����ת��put_other
         jnz .put_other                  ;���ǣ��Ǿ�������ʾ�ַ� 
         add bx,80
         jmp .roll_screen

 .put_other:                             ;������ʾ�ַ�
         mov ax,0xb800
         mov es,ax
         shl bx,1
         mov [es:bx],cl

         ;���½����λ���ƽ�һ���ַ�
         shr bx,1
         add bx,1

 .roll_screen:
         cmp bx,2000                     ;��곬����Ļ�����û�о��������ù�꣬��������ˣ��͹�����Ļ
         jl .set_cursor

         mov ax,0xb800
         mov ds,ax
         mov es,ax
         cld
         mov si,0xa0
         mov di,0x00
         mov cx,1920
         rep movsw
         mov bx,3840                     ;�����Ļ���һ��
         mov cx,80
 .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         mov bx,1920

	;�������ù��λ��
 .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         
         mov dx,0x3d5
         mov al,bh
         out dx,al
         
         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         
         mov dx,0x3d5
         mov al,bl
         out dx,al

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret

;-------------------------------------------------------------------------------
  start:
  	 ;��MBR��ת��Ӧ�ó�������Ҫ�л������μĴ������Ա�����Լ�������
  	 ;���ݶ�CS�м�����������ص��������ڴ�phy_base����
         ;��ʼִ��ʱ��DS��ESָ���û�����ͷ����
         mov ax,[stack_segment]           ;���õ��û������Լ��Ķ�ջ 
         mov ss,ax
         mov sp,stack_end		  ;ջ����256����ַ��0~255��������൱��mov sp,255
         ;mov sp,255
         
         mov ax,[data_1_segment]          ;���õ��û������Լ������ݶ�,��������ds���ʳ����ͷ����
         mov ds,ax

         mov bx,msg0
         call put_string                  ;��ʾ��һ����Ϣ 

         push word [es:code_2_segment]	  ;ѹ�����ʼ��ַ
         mov ax,begin
         push ax                          ;����ֱ��push begin,80386+��ѹ��ε�ƫ�Ƶ�ַ
         
         retf                             ;ת�Ƶ������2ִ�� 
         
  continue:
         mov ax,[es:data_2_segment]       ;�μĴ���DS�л������ݶ�2 
         mov ds,ax
         
         mov bx,msg1
         call put_string                  ;��ʾ�ڶ�����Ϣ 

         jmp $ 

;===============================================================================
SECTION code_2 align=16 vstart=0          ;��������2��16�ֽڶ��룩

  begin:
         push word [es:code_1_segment]    ;ѹ���1�Ļ���ַ
         mov ax,continue
         push ax                          ;����ֱ��push continue,80386+
         
         retf                             ;ת�Ƶ������1����ִ�У�ģ��η��أ�ʵ�ֶ�ת��
         
;===============================================================================
SECTION data_1 align=16 vstart=0

    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         ;0x0d��ʾ�س�,0x0a��ʾ����
         db 0x0d,0x0a,0x0d,0x0a
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         ;db 999
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0

;===============================================================================
SECTION data_2 align=16 vstart=0

    msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         ;db 999
         db 0

;===============================================================================
SECTION stack align=16 vstart=0		;��section.stack.start��ʾ��ջ�Ŀ�ʼ
           
         resb 256			;����256�ֽڣ����ǲ�����ʼ�����ǣ��ǻ���ַ��0~255

stack_end:  				;�øñ�ű�ʾ��ջ�Ľ���

;===============================================================================
;���ﲻ����vstart,���������ʵ��ַ��Ҫ���������ļ���ͷ����ʼ����
SECTION trail align=16
program_end:
