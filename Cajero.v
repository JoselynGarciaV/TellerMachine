
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Cajero(
input clk, // Entrada de reloj
input [11:0] in_switch, // Switches para los montos
input [3:0] button, // Botones
input [3:0] casillas, //entrada de las casillas
output reg [6:0] catodo, // 7segmentos
output reg [7:0] enable, // Habilitar 7 segmentos
output reg [3:0] LEDS
);

reg [3:0] state=0;  //Estados

reg [3:0] display = 0;
reg [27:0] frecMux = 0; // Multiplexar

reg [11:0] dinero_actual = 2500;// monto a desplegar
reg [11:0] monto_ingresado = 0; //Registro que se recibe de los switches 
reg [11:0] numero_desple=0;

integer r = 0 ;
integer tiempo = 0;
integer activate = 0;

reg [3:0] units = 0; //registro para almacenar las unidades
reg [3:0] tens = 0;  //registro para almacenar las decenas
reg [3:0] hundreds = 0;  //registro para almacenar las centenas
reg [3:0] thousands = 0;  // registro para almacenar los miles




always @(posedge clk)
begin 

if(r < numero_desple)
begin
    units = units+1;
    if(units > 9)
    begin
        units=0;
        tens= tens + 1;
    end
    if(tens>9)
    begin
        tens = 0;
        hundreds = hundreds +1;
    end
    if(hundreds > 9)
    begin
        hundreds = 0;
        thousands = thousands+1;
    end
    r = r+1;
end


monto_ingresado = in_switch;

 //Para multiplexar
 frecMux = frecMux + 1 ;
    if(frecMux == 200000)
        begin
            display = units;
            enable = 8'b11111110;
        end
    if(frecMux == 400000)
        begin
            display = tens;
            enable = 8'b11111101;
        end
    if(frecMux == 600000)
        begin
            display = hundreds;
            enable = 8'b11111011;
        end
        
    if(frecMux == 800000)
        begin
            frecMux = 0;
            display = thousands;
            enable = 8'b11110111;
        end


// Para desplegar los valores de contraseña y montos 
case (display)
       4'b0000 : catodo = 7'b0000001;
       4'b0001 : catodo = 7'b1001111;
       4'b0010 : catodo = 7'b0010010;
       4'b0011 : catodo = 7'b0000110;
       4'b0100 : catodo = 7'b1001100;
       4'b0101 : catodo = 7'b0100100;
       4'b0110 : catodo = 7'b0100000;
       4'b0111 : catodo = 7'b0001111;
       4'b1000 : catodo = 7'b0000000;
       4'b1001 : catodo = 7'b0001100;
       default : catodo = 7'b0000001;
       

endcase
        
        


  
                  
case(state)
        0: //Estado Cero, ingresa contraseña y verifica  
        begin
        
            if(button [3] == 1)// reset
            begin
                dinero_actual = 2500;
                units = 0;
                tens = 0;
                hundreds =0;
                thousands =0;
                r = 0 ;
                tiempo = 0;
                numero_desple = 0;
                state=0;            
            end
            //Verifica contraseña
            if ((in_switch == 12'b000000001100) && (button[0]==1))
            begin
                numero_desple = 12;//solo despliega el 12
            end
            
            if((in_switch == 12'b000000001100) && (tiempo < 700000000) && (numero_desple==12) )// se mantiene por 7 segundos la contraseña
            tiempo = tiempo + 1;
            
            if((in_switch == 12'b000000001100) && (tiempo == 700000000))
            begin
                units = 0;
                tens = 0;
                hundreds = 0;
                thousands = 0;
                numero_desple = dinero_actual; // despliega los 2500
                r = 0;
                tiempo = 0;
            end
            
            if ((in_switch == 12'b000000000000) && (button[1]==1) && (numero_desple == dinero_actual) ) //Todos los switches deben estar en cero y activar el botón de añadir
            begin
                state = 1;
                units = 0;
                tens = 0;
                hundreds = 0;
                thousands = 0;
                r = 0;
                numero_desple=0;
            end
            
            if ((in_switch == 12'b000000000000) && (button[2]==1) && (numero_desple == dinero_actual) ) //Todos los switches deben estar en cero y activar el botón de añadir
            begin
                state = 2;
                units = 0;
                tens = 0;
                hundreds = 0;
                thousands = 0;
                r = 0;
                numero_desple=0;
            end     
        end
        
        //Sumar monto
        1:
        begin
        if(button [3] == 1)// reset
            begin
                dinero_actual = 2500;
                units = 0;
                tens = 0;
                hundreds =0;
                thousands =0;
                r = 0 ;
                tiempo = 0;
                numero_desple = 0;
                state=0;            
            end
            
            numero_desple = monto_ingresado;
            tiempo = tiempo + 1;
            if(tiempo == 200000000)//refresca el valor ingresado cada 2 segundos
                begin
                    units=0;
                    tens=0;
                    hundreds = 0;
                    thousands = 0;
                    r = 0;
                    tiempo = 0;
                end
            if((monto_ingresado + dinero_actual) > 4096 && (button [0]==1))
            begin
                units=0;
                tens=0;
                hundreds = 0;
                thousands = 0;
                r = 0;
                numero_desple=1;//error numero sobrepasa cantidad
                
                state=4;
            end
            if ((monto_ingresado + dinero_actual) <= 4096 && (button [0]==1))
            begin
                state=3;
                dinero_actual= monto_ingresado + dinero_actual; //actualiza el dinero
            end
        end
        
        2:
        begin
        if(button [3] == 1)// reset
            begin
                dinero_actual = 2500;
                units = 0;
                tens = 0;
                hundreds =0;
                thousands =0;
                r = 0 ;
                tiempo = 0;
                numero_desple = 0;
                state=0;            
            end
            
            numero_desple = monto_ingresado;
            tiempo = tiempo + 1;
            if(tiempo == 200000000)//refresca el valor ingresado cada 2 segundos
                begin
                    units=0;
                    tens=0;
                    hundreds = 0;
                    thousands = 0;
                    r = 0;
                    tiempo = 0;
                end
            if((monto_ingresado > dinero_actual) && (button [0]==1))
            begin
                units=0;
                tens=0;
                hundreds = 0;
                thousands = 0;
                r = 0;
                numero_desple=2;//error numero sobrepasa cantidad
                
                state=4;
            end
            if ((monto_ingresado <= dinero_actual) && (button [0]==1))
            begin
                state=3;
                dinero_actual= dinero_actual - monto_ingresado; //actualiza el dinero
            end
        end
        
        3://estado de las casillas
            begin
            if(units>0 && activate==0)
                LEDS[0]=1;
            if (tens>0 && activate==0)
                LEDS [1] = 1;
            if(hundreds > 0 &&  activate==0)
                LEDS [2] = 1;
            if(thousands > 0 &&  activate==0)
                LEDS[3] = 1;
            
            if(LEDS[0]==1 && casillas[0]==1)
            begin
            LEDS[0]=0;
            activate = 1;
            end
            
            if(LEDS[1]==1 && casillas[1]==1)
            begin
            LEDS[1]=0;
            activate = 1;
            end
            
            if(LEDS[2]==1 && casillas[2]==1)
            begin
            LEDS[2]=0;
            activate = 1;
            end
            
            if(LEDS[3]==1 && casillas[3]==1)
            begin
            LEDS[3]=0;
            activate = 1;
            end
            
            if(casillas == 4'b0000 && LEDS== 4'b0000 && activate==1)
            begin
                state = 0;//vuelve al estado cero
                units=0;
                tens=0;
                hundreds=0;
                thousands=0;
                r=0;
                numero_desple=0;
                activate=0;
            end
        
        
        end
        
        
        4: //estado de error 
        if(button[0]==1 && in_switch== 12'b000000000000)
        begin
            state = 0;//vuelve al estado cero
            units=0;
            tens=0;
            hundreds=0;
            thousands=0;
            r=0;
            numero_desple=0;
        end
   
endcase

 

        
        
        
        


        
end//End always
endmodule
