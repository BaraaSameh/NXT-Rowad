using System;

namespace Task1C_
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(" hello ");
            double num1, num2;
            char op;

            // Get first number with validation
            while (true)
            {
                Console.Write("Enter first number: ");
                if (double.TryParse(Console.ReadLine(), out num1))
                {
                    if (num1 < 0)
                    {
                        Console.WriteLine("Negative numbers are not allowed.");
                        continue;
                    }
                    break;
                }
                else
                {
                    Console.WriteLine("Invalid input. Please enter a valid number.");
                }
            }

            // Get operator with validation
            while (true)
            {
                Console.Write("Enter operator (+, -, *, /): ");
                string opInput = Console.ReadLine();
                if (!string.IsNullOrEmpty(opInput) && "+-*/".Contains(opInput))
                {
                    op = opInput[0];
                    break;
                }
                else
                {
                    Console.WriteLine("Invalid operator input. Please enter one of +, -, *, /.");
                }
            }

            // Get second number with validation
            while (true)
            {
                Console.Write("Enter second number: ");
                if (double.TryParse(Console.ReadLine(), out num2))
                {
                    if (num2 < 0)
                    {
                        Console.WriteLine("Negative numbers are not allowed.");
                        continue;
                    }
                    if (num2 == 0 && op == '/')
                    {
                        Console.WriteLine("Cannot divide by zero.");
                        continue;
                    }
                    break;
                }
                else
                {
                    Console.WriteLine("Invalid input. Please enter a valid number.");
                }
            }

            // Calculation
            try
            {
                double result = op switch
                {
                    '+' => num1 + num2,
                    '-' => num1 - num2,
                    '*' => num1 * num2,
                    '/' => num1 / num2,
                    _ => throw new InvalidOperationException("Invalid operator")
                };
                Console.WriteLine($"{num1} {op} {num2} = {result}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}