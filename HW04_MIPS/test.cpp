#include <iostream>
#include <fstream>
#include <time.h>
#include <cstdlib>
#include <bitset>
#include <iomanip>
using namespace std;

fstream input, output, reg_value;
// registers' address
const int reg1_addr = 17, reg2_addr = 18, reg3_addr = 8, reg4_addr = 23, reg5_addr = 31, reg6_addr = 16;
// opcode
const int opcode_R = 0, opcode_I = 8;
// funct
const int funct_1 = 32, funct_2 = 36, funct_3 = 37, funct_4 = 39, funct_5 = 0, funct_6 = 2;

unsigned int registers[6] = {0, 0, 0, 0, 0, 0};
// input
unsigned int opcode, Rs_addr, Rt_addr, Rd_addr, shamt, funct, immediate;
unsigned int output_reg[4];
// processing
unsigned int Rs_value, Rt_value, wrt_value;
int wrt_addr;
// output
unsigned int instruction_fail, out[4];

int last_wrt_register = 0;

int data_num;

void address()
{
    do
    {
        switch (rand() % 7)
        {
        case 0:
            Rs_addr = reg1_addr;
            break;
        case 1:
            Rs_addr = reg2_addr;
            break;
        case 2:
            Rs_addr = reg3_addr;
            break;
        case 3:
            Rs_addr = reg4_addr;
            break;
        case 4:
            Rs_addr = reg5_addr;
            break;
        case 5:
            Rs_addr = reg6_addr;
            break;
        default:
            Rs_addr = rand() % 32;
            break;
        }
    } while (Rs_addr == last_wrt_register);
    if (opcode == opcode_R)
    {
        do
        {
            switch (rand() % 7)
            {
            case 0:
                Rt_addr = reg1_addr;
                break;
            case 1:
                Rt_addr = reg2_addr;
                break;
            case 2:
                Rt_addr = reg3_addr;
                break;
            case 3:
                Rt_addr = reg4_addr;
                break;
            case 4:
                Rt_addr = reg5_addr;
                break;
            case 5:
                Rt_addr = reg6_addr;
                break;
            default:
                Rt_addr = rand() % 32;
                break;
            }
        } while (Rt_addr == last_wrt_register);
        switch (rand() % 7)
        {
        case 0:
            Rd_addr = reg1_addr;
            break;
        case 1:
            Rd_addr = reg2_addr;
            break;
        case 2:
            Rd_addr = reg3_addr;
            break;
        case 3:
            Rd_addr = reg4_addr;
            break;
        case 4:
            Rd_addr = reg5_addr;
            break;
        case 5:
            Rd_addr = reg6_addr;
            break;
        default:
            Rd_addr = rand() % 32;
            break;
        }
    }
    else if (opcode == opcode_I)
    {
        switch (rand() % 7)
        {
        case 0:
            Rt_addr = reg1_addr;
            break;
        case 1:
            Rt_addr = reg2_addr;
            break;
        case 2:
            Rt_addr = reg3_addr;
            break;
        case 3:
            Rt_addr = reg4_addr;
            break;
        case 4:
            Rt_addr = reg5_addr;
            break;
        case 5:
            Rt_addr = reg6_addr;
            break;
        default:
            Rt_addr = rand() % 32;
            break;
        }
    }
}

void getRegValue(unsigned int &address, unsigned int &value)
{
    switch (address)
    {
    case reg1_addr:
        value = registers[0];
        break;
    case reg2_addr:
        value = registers[1];
        break;
    case reg3_addr:
        value = registers[2];
        break;
    case reg4_addr:
        value = registers[3];
        break;
    case reg5_addr:
        value = registers[4];
        break;
    case reg6_addr:
        value = registers[5];
        break;
    default:
        value = 0;
        instruction_fail = 1;
        break;
    }
}

void wrtRegValue(unsigned int address, unsigned int value)
{
    switch (address)
    {
    case reg1_addr:
        registers[0] = value;
        break;
    case reg2_addr:
        registers[1] = value;
        break;
    case reg3_addr:
        registers[2] = value;
        break;
    case reg4_addr:
        registers[3] = value;
        break;
    case reg5_addr:
        registers[4] = value;
        break;
    case reg6_addr:
        registers[5] = value;
        break;
    default:
        instruction_fail = 1;
        break;
    }
}

void operation()
{
    unsigned int value = 0;
    if (opcode == opcode_R)
    {
        instruction_fail = 0;
        getRegValue(Rs_addr, Rs_value);
        getRegValue(Rt_addr, Rt_value);
        if (instruction_fail == 0)
        {
            last_wrt_register = Rd_addr;
            switch (funct)
            {
            case funct_1:
                value = Rs_value + Rt_value;
                wrtRegValue(Rd_addr, value);
                break;
            case funct_2:
                value = Rs_value & Rt_value;
                wrtRegValue(Rd_addr, value);
                break;
            case funct_3:
                value = Rs_value | Rt_value;
                wrtRegValue(Rd_addr, value);
                break;
            case funct_4:
                value = ~(Rs_value | Rt_value);
                wrtRegValue(Rd_addr, value);
                break;
            case funct_5:
                value = Rt_value << shamt;
                wrtRegValue(Rd_addr, value);
                break;
            case funct_6:
                value = Rt_value >> shamt;
                wrtRegValue(Rd_addr, value);
                break;
            default:
                instruction_fail = 1;
                last_wrt_register = 0;
                break;
            }
        }
    }
    else if (opcode == opcode_I)
    {
        instruction_fail = 0;
        getRegValue(Rs_addr, Rs_value);
        if (instruction_fail == 0)
        {
            value = Rs_value + immediate;
            wrtRegValue(Rt_addr, value);
            last_wrt_register = Rt_addr;
        }
    }
    else
        instruction_fail = 1;
}

void function()
{
    switch (rand() % 7)
    {
    case 0:
        funct = funct_1;
        break;
    case 1:
        funct = funct_2;
        break;
    case 2:
        funct = funct_3;
        break;
    case 3:
        funct = funct_4;
        break;
    case 4:
        funct = funct_5;
        break;
    case 5:
        funct = funct_6;
    default:
        funct = rand() % 64;
        break;
    }
}

int main()
{
    input.open("input.txt", ios::out);
    output.open("output.txt", ios::out);
    reg_value.open("reg.txt", ios::out);

    srand(time(NULL));
    cin >> data_num;
    input << data_num << endl;

    for (int i = 0; i < data_num; i++)
    {
        // input
        // output_reg
        for (int j = 0; j < 4; j++)
        {
            switch (rand() % 6)
            {
            case 0:
                output_reg[j] = reg1_addr;
                break;
            case 1:
                output_reg[j] = reg2_addr;
                break;
            case 2:
                output_reg[j] = reg3_addr;
                break;
            case 3:
                output_reg[j] = reg4_addr;
                break;
            case 4:
                output_reg[j] = reg5_addr;
                break;
            case 5:
                output_reg[j] = reg6_addr;
                break;
            }
        }
        // instruction
        switch (rand() % 3)
        {
        case 0:
            opcode = opcode_R;
            break;
        case 1:
            opcode = opcode_I;
            break;
        default:
            opcode = rand() % 64;
            break;
        }
        address();
        function();
        shamt = rand() % 32;
        immediate = rand();

        // processing
        operation();

        // output
        if (instruction_fail)
        {
            out[0] = 0;
            out[1] = 0;
            out[2] = 0;
            out[3] = 0;
        }
        else
        {
            getRegValue(output_reg[0], out[0]);
            getRegValue(output_reg[1], out[1]);
            getRegValue(output_reg[2], out[2]);
            getRegValue(output_reg[3], out[3]);
        }

        bitset<6> bin_opcode(opcode);
        bitset<5> bin_Rs(Rs_addr);
        bitset<5> bin_Rt(Rt_addr);
        bitset<5> bin_Rd(Rd_addr);
        bitset<5> bin_shamt(shamt);
        bitset<6> bin_funct(funct);
        bitset<16> bin_immediate(immediate);
        bitset<5> bin_output_reg_0(output_reg[0]);
        bitset<5> bin_output_reg_1(output_reg[1]);
        bitset<5> bin_output_reg_2(output_reg[2]);
        bitset<5> bin_output_reg_3(output_reg[3]);
        // for input.txt
        switch (opcode)
        {
        case opcode_R:
            input << bin_opcode << bin_Rs << bin_Rt << bin_Rd << bin_shamt << bin_funct << " ";
            break;
        case opcode_I:
            input << bin_opcode << bin_Rs << bin_Rt << bin_immediate << " ";
            break;
        default:
            input << bin_opcode << bin_Rs << bin_Rt << bin_immediate << " ";
            break;
        }
        input << bin_output_reg_3 << bin_output_reg_2 << bin_output_reg_1 << bin_output_reg_0 << endl;
        // for output.txt
        output << instruction_fail << " ";
        output << right << setw(10) << fixed << out[0] << " ";
        output << right << setw(10) << fixed << out[1] << " ";
        output << right << setw(10) << fixed << out[2] << " ";
        output << right << setw(10) << fixed << out[3] << endl;
        // output registers value
        for (int i = 0; i < 6; i++)
        {
            reg_value << right << setw(10) << fixed << registers[i] << " ";
        }
        reg_value << endl;
    }

    input.close();
    output.close();
    reg_value.close();
    cout << "finshed!" << endl;
    return 0;
}
