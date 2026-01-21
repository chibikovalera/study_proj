import json
import math

def convert_weights_to_verilog(json_path):
    """Конвертирует веса из JSON в параметры для Verilog модуля"""
    
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    neurons = data['neurons']
    
    print("// Автоматически сгенерированные веса из arrow_weights.json")
    print("// Используйте эти параметры при инстанцировании нейронов\n")
    
    labels = ["вверх", "влево-вверх", "влево-вниз", "влево", 
              "вниз", "вправо-вверх", "вправо-вниз", "вправо"]
    
    for i, neuron in enumerate(neurons):
        k = neuron['k']
        b = neuron['b']
        label = labels[i] if i < len(labels) else f"нейрон_{i}"
        
        # Преобразуем список в двоичную строку
        binary_str = ''.join(str(bit) for bit in k)
        
        # Разбиваем на 16 строк по 16 бит для читаемости
        verilog_binary = '256\'b'
        for row in range(16):
            if row > 0:
                verilog_binary += '\n                 '
            verilog_binary += binary_str[row*16:(row+1)*16]
        
        print(f"// Нейрон {i}: \"{label}\"")
        print(f"Neuron #(")
        print(f"    .k({verilog_binary}),")
        print(f"    .b(8'd{b}),")
        print(f"    .number(4'd{i})")
        print(f") neuron{i} (")
        print(f"    .x(pixel_vector),")
        print(f"    .clk(clk),")
        print(f"    .start(start_neuron[{i}]),")
        print(f"    .out(neuron_out[{i}]),")
        print(f"    .ready(neuron_ready[{i}])")
        print(f");\n")

# Использование
if __name__ == "__main__":
    convert_weights_to_verilog("arrow_weights.json")