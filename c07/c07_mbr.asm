         ;�����嵥7-1
         ;�ļ�����c07_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2011-4-13 18:02
         
         jmp near start
	
 message db '1+2+3+...+100='
        
 start:
         mov ax,0x7c0           ;�������ݶεĶλ���ַ 
         mov ds,ax

         mov ax,0xb800          ;���ø��Ӷλ�ַ����ʾ������
         mov es,ax

         ;������ʾ�ַ��� 
         mov si,message          
         mov di,160*8
         mov cx,start-message	;����ѭ���Ĵ���
     @g:
         mov al,[si]
         mov [es:di],al		;��al��ֵ�ŵ��μĴ���di��ƫ�ƴ�����ʼ��ʱ��diΪ160*8 ����ӡ��bios��Ϣ֮��
	 ; ����di��ֵ�����ø�ʽ
         inc di
         mov byte [es:di],0x07

         ;��������di��ֵ��Ϊ��һ�η���Ų�ط�
         inc di
         ;����si��ֵ��ȡ����һ���ַ�
         inc si
         loop @g

         ;���¼���1��100�ĺ� 
         xor ax,ax	;��ax����
         mov cx,1	;��ʼ��cx�Ĵ���Ϊ1
     @f:
         add ax,cx	;ax = ax + cx
         inc cx
         cmp cx,100	;��cx��100���Ƚ�
         jle @f		;���С�ڵ���100����ת���൱��cxҪ����101�Ų�����ת���������cx��ֵ��101

         ;���¼����ۼӺ͵�ÿ����λ 
         xor cx,cx              ;��cx����
         mov ss,cx		;���ö�ջ�εĶλ���ַ
         mov sp,cx		;stack pointer����ջָ��

         mov bx,10		;��bx��ֵΪ10
         ;xor cx,cx		;�о���һ�����࣬��Ϊ֮ǰ��cx��ֵ֮�󣬲�û�в�����cx,���Ի���0
     @d:
         inc cx			;ÿѭ��һ�Σ�����һ��cx��ֵ��Ϊ�˷�����ʾ��ʱ������ѭ������
         xor dx,dx		;����dx
         div bx			;���г������㣬������ax,��������bx,�̷���dx,��������ax
         or dl,0x30		;��dl��0x30�����������Ϊʲô���Ǽ��أ���任��add dl,0x30Ч��һ��	
         push dx		;����������õ����̷���dx
         cmp ax,0
         jne @d			;��ax��0���бȽϣ����������0����ת

         ;������ʾ������λ 
     @a:
         pop dx			;����dx
         mov [es:di],dl		;��dl���ŷ���message֮��
         inc di			;����di,ָ��esջ�ڵ���һ��ƫ��
         mov byte [es:di],0x07	;�����ַ���ʾ�ĸ�ʽ
         inc di			;����di,ָ����һ��ƫ��
         loop @a
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa